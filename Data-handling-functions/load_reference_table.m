function ref = load_reference_table(species, varargin)

%
% inputs:
% species = 'R', 'F'
% ID = specific ID ('KIW','BEA,'ANI','EMU','DRED','ERED','DBLU'),
%      'linearprobe' or 'all'
% recside = 'L', 'R', 'all'
% level =  'L3', 'L4', 'L5', 'L6', 'L5|6', 'all'
% modality = 'A', 'V', 'A|V', 'AV', 'ATR', 'A|V|ATR','allbutAV', 'sedated', 'all'
% incl = 'neu' ,'beh','neu|beh', 'neu&beh', 'check', 'check|neu', 'all'
%

% set default parameters
defaultID       = 'all';
defaultRectype  = 'all';
defaultRecside  = 'all';
defaultLevel    = 'all';
defaultModality = 'all';
defaultIncl     = 'all';

% parse inputs
p = inputParser;
addRequired(p,'species')
addParameter(p,'ID',defaultID);
addParameter(p,'rectype',defaultRectype);
addParameter(p,'recside',defaultRecside);
addParameter(p,'level',defaultLevel)
addParameter(p,'modality',defaultModality)
addParameter(p,'incl',defaultIncl)

parse(p,species,varargin{:});

% set parameters
ID        = p.Results.ID;
rectype   = p.Results.rectype;
recside   = p.Results.recside;
level     = p.Results.level;
modality  = p.Results.modality;
incl_type = p.Results.incl;

% report if wrong tag entered
expected_species  = {'R','F'};
expected_IDs      = {'KIW','BEA','ANI','EMU','DRED','ERED','DBLU','all','linearprobe'};
expected_rectypes = {'T','W','all'};
expected_recsides = {'L','R','all'};
expected_levels   =  {'L3', 'L4', 'L5', 'L6', 'L5|6', 'all'};
expected_modality = { 'A', 'V', 'A|V', 'AV', 'ATR', 'A|V|ATR','allbutAV', 'sedated', 'sleep', 'all'};
expected_incl     = {'neu' ,'beh','neu|beh', 'neu&beh','check', 'check|neu', 'all'};

if ~ismember(expected_species,species)
    disp('LOAD_REFERENCE ERROR: Species input is not recognised')
    disp(expected_species)
    ref = [];
    return
elseif ~ismember(expected_IDs,ID)
    disp('LOAD_REFERENCE ERROR: ID input is not recognised. Valid inputs:')
    disp(expected_IDs)
    ref = [];
    return
    elseif ~ismember(expected_rectypes,rectype)
    disp('LOAD_REFERENCE ERROR: rectype input is not recognised. Valid inputs:')
    disp(expected_rectypes)
    ref = [];
    return
elseif ~ismember(expected_levels,level)
    disp('LOAD_REFERENCE ERROR: Level input is not recognised. Valid inputs:')
    disp(expected_levels)
    ref = [];
    return
elseif ~ismember(expected_recsides,recside)
    disp('LOAD_REFERENCE ERROR: Level input is not recognised. Valid inputs:')
        disp(expected_recsides)
ref = [];
    return
elseif ~ismember(expected_modality,modality)
    disp('LOAD_REFERENCE ERROR: Modality input is not recognised. Valid inputs:')  
        disp(expected_modality)
ref = [];
    return
elseif ~ismember(expected_incl,incl_type)
    disp('LOAD_REFERENCE ERROR: Inclusion type input is not recognised. Valid inputs:')
    disp(expected_incl)
    ref = [];
    return
end

params = get_parameters;
refFp  = get_full_path(params.(species).refPath,params.(species).refFn);

load(refFp,'reference')

ref = select_from_reference(reference,ID,rectype,recside, level, modality, incl_type);


end

function ref = select_from_reference(reference,ID,rectype, recside,level, modality, incl_type)

        idx = getIndices(reference);
      
        if contains(reference.Species{1},'R')
         % no rats have these conditions, but code needs fields to run
            idx.RecSide.isL = false;
            idx.RecType.isW = false;
            idx.Modality.isatropine = false;
            idx.Modality.issedated = false;
        end
    
    switch ID
        case 'all'
            id_idx = true(size(reference,1),1);
        case 'DRED'
            id_idx = idx.ID.isDRED;
        case 'DBLU'
            id_idx = idx.ID.isDBLU;
        case 'ERED'
            id_idx = idx.ID.isERED;
        case 'KIW'
            id_idx = idx.ID.isKIW;
        case 'EMU'
            id_idx = idx.ID.isEMU;
        case 'BEA'
            id_idx = idx.ID.isBEA;
        case 'ANI'
            id_idx = idx.ID.isANI;
        case 'linearprobe'
            if contains(reference.Species{1},'R')
                id_idx =  true(size(reference,1),1);
            else
                id_idx = idx.ID.isKIW | idx.ID.isEMU | idx.ID.isBEA;
            end
    end
    
    switch recside
        case 'L'
            recside_idx = idx.RecSide.isL;
        case 'R'
            recside_idx = idx.RecSide.isR;
        case 'all'
            recside_idx = idx.RecSide.isL | idx.RecSide.isR | idx.RecSide.isNA;
    end
    
    switch rectype
        case 'T'
            rectype_idx = idx.RecType.isT;
        case 'W'
            rectype_idx = idx.RecType.isW;
        case 'all'
            rectype_idx = idx.RecType.isT| idx.RecType.isW | idx.RecType.isNA;
    end
    
    switch level
        case 'all'
            level_idx = true(size(reference,1),1);
        case 'L3'
            level_idx = idx.Level.is3;
        case 'L4'
            level_idx = idx.Level.is4;
        case 'L5'
            level_idx = idx.Level.is5;
        case 'L6'
            level_idx = idx.Level.is6;
        case 'L5|6'
            level_idx = idx.Level.is5 | idx.Level.is6;
    end
           
    switch modality
        case 'all'
            mod_idx = true(size(reference,1),1);
        case 'A'
            mod_idx = idx.Modality.isA;
        case 'V'
            mod_idx = idx.Modality.isV;
        case 'A|V'
            mod_idx = idx.Modality.isA | idx.Modality.isV;
        case 'AV'
            mod_idx = idx.Modality.isAV;
        case 'A|V|AV'
            mod_idx = idx.Modality.isA | idx.Modality.isV | idx.Modality.isAV;
        case 'ATR'
            mod_idx = idx.Modality.isatropine;
        case 'A|V|ATR'
            mod_idx = idx.Modality.isA | idx.Modality.isV | idx.Modality.isatropine;
        case 'sedated'
            mod_idx = idx.Modality.issedated;
        case 'allbutAV'
            mod_idx = idx.Modality.isA | idx.Modality.isV | idx.Modality.isatropine | idx.Modality.issedated;
    end
    
    switch incl_type
        
        case 'neu'
            Tidx = idx.Incl_Neural.is1;
        case 'beh'
            Tidx = idx.Incl_Behaviour.is1;
        case 'neu|beh'
            Tidx = idx.Incl_Neural.is1 | idx.Incl_Behaviour.is1;
        case 'neu&beh'
            Tidx = idx.Incl_Neural.is1 & idx.Incl_Behaviour.is1;
        case 'check'
            Tidx = idx.Incl_Neural.is2;
        case 'check|neu'
            if isfield(idx.Incl_Neural,'is2')
                Tidx = idx.Incl_Neural.is1 | idx.Incl_Neural.is2;
            else
                Tidx = idx.Incl_Neural.is1;
            end
        case 'all'
            Tidx = true(size(reference,1),1);
    end
    
    IDX =  id_idx & recside_idx & rectype_idx & level_idx & mod_idx & Tidx;
    
    ref = reference(IDX,:);
    

end
