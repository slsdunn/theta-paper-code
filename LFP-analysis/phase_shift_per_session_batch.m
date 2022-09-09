function phase_shift_per_session_batch(species,savename)
try
    
stop_table_warnings
    
params   = get_parameters;
ref      = load_reference_table(species,'incl','neu','level','L5|6','ID','linearprobe');
savepath = params.(species).processedDataPath;

out.phaseShift = table;
nrow = 1;

for n = 1: size(ref,1)
    
    sessionref = ref(n,:);
    
    mdata = load_metadata(sessionref);
  
    cdata = load_neural_mapped(sessionref,mdata,'all','cleansignal');
    t_neu = load_neural_timeline(sessionref);
    [speed,~] = load_tracking_speed(sessionref,mdata,t_neu);
   
    nanidx    = isnan(speed);
    excl_idx1 = or(nanidx,speed < params.speedThresh.moving);  % exclude speeds less than moving threshold
    excl_idx2 = or(nanidx,speed > params.speedThresh.immobile); % exclude speeds greater them immobility threshold
    
    flt = filter_signal(cdata,1000,'BP',params.(species).theta_bandwidth, params.(species).theta_filtOrder);

    [~,iphase,~,~, ~] = calculate_peak_trough_signal_parameters(flt.signal,params.PT_thresh_pc,t_neu);

    
    iphasemov = iphase;
    iphasemov(excl_idx1,:) = NaN;

    iphaseimm = iphase;
    iphaseimm(excl_idx2,:) = NaN;

    badchanidx = all(isnan(flt.signal));
    
    [phases_mov,~,samppoints_mov] = calc_phase_difference_down_probe(iphasemov,badchanidx, 1000);
    if isempty(phases_mov)
        continue
    end
    [phases_imm,~,samppoints_imm] = calc_phase_difference_down_probe(iphaseimm,badchanidx, 1000);
    
    phases_mov = deg2rad(phases_mov);
    phdiff_mov = circ_dist(phases_mov,repmat(phases_mov(:,1),1,size(cdata,2)));
    meanphdiff_mov = unwrap(circ_mean(phdiff_mov));
    
    phases_imm = deg2rad(phases_imm);
    phdiff_imm = circ_dist(phases_imm,repmat(phases_imm(:,1),1,size(cdata,2)));
    meanphdiff_imm = unwrap(circ_mean(phdiff_imm));
    
    out.phaseShift.ID(nrow,1)            = sessionref.ID(1);
    out.phaseShift.RecSide(nrow,1)       = sessionref.RecSide(1);
    out.phaseShift.IDside(nrow,1)        = sessionref.IDside(1);
    out.phaseShift.ExtFile(nrow,1)       = sessionref.ExtractedFile(1);
    out.phaseShift.RecType(nrow,1)       = sessionref.RecType(1);
    out.phaseShift.MapID(nrow,1)         = mdata.mapID;
    out.phaseShift.Level(nrow,1)         = sessionref.Level;
    out.phaseShift.Modality(nrow,1)      = sessionref.Modality(1);
    out.phaseShift.PhasesMov(nrow,1)     = {phases_mov};
    out.phaseShift.PhaseDiffMov(nrow,1)  = {meanphdiff_mov};
    out.phaseShift.SampPointsMov(nrow,1) = {samppoints_mov};
    out.phaseShift.PhasesImm(nrow,1)     = {phases_imm};
    out.phaseShift.PhaseDiffImm(nrow,1)  = {meanphdiff_imm};
    out.phaseShift.SampPointsImm(nrow,1) = {samppoints_imm};
      
    nrow = nrow + 1;    
    
    
    disp([num2str(n) '/' num2str(size(ref,1))])
    disp([sessionref.ID{1} '- ' sessionref.ExtractedFile{1}])


end


out.pms.immSpeedThresh   = params.speedThresh.immobile;
out.pms.movSpeedThresh   = params.speedThresh.moving;
out.pms.filename         = savename;
out.pms.params           = params;
    
save(fullfile(savepath,savename),'-struct','out')


catch err
    parseError(err)
    keyboard
end
end

%r =  circ_dist(out.phases,repmat(out.phases(:,1),1,32));
%errorbar(1:32,unwrap(circ_mean(r)),unwrap(circ_std(r)))

function [ph,dph, samplepoints] = calc_phase_difference_down_probe(signal,badchanidx, nsamplepoints)

filledh = 0;
nfill = 1;
samplepoints = [];
attempts = 0;
nchan = length(badchanidx);


% remove places where all channels NaN, store xvec so sample points refer
% to uncompressed trace
xvec   = 1:size(signal,1);
nanidx = all(isnan(signal),2);
xvec(nanidx)     = [];
signal(nanidx,:) = [];

% tag channel as bad if >90% is missing
pcmissing = sum(isnan(signal))/size(signal,1);
badchanidx(pcmissing>0.9) = 1;


while filledh == 0
    
    if attempts > 2000000     % give up if can't do it
        disp('calc_phase_diff had to give up')
        ph = [];
        dph = [];
        samplepoints = [];
        return
    end
    
    samplepoint = round(rand(1,1)*size(signal,1));
    if samplepoint == 0
        continue
    end
    if ismember(samplepoints,samplepoint)
        continue
    end
    h1 = signal(samplepoint,:);
    hnantest = h1;
    hnantest(badchanidx) = [];
    if any(any(isnan(hnantest)))
        attempts = attempts + 1;
        continue
    else
        h(nfill,:) = h1;
        samplepoints(nfill) = xvec(samplepoint);
        nfill = nfill + 1;
        attempts = attempts + 1;
    end
    if nfill > nsamplepoints
        filledh = 1;
    end
end

ph = h;
dph = ph - repmat(ph(:,1),1,nchan);

end
