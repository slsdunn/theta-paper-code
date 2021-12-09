function supfigure_xcorr_GLM


stop_table_warnings;
params = get_parameters;

T = readtable(fullfile(params.figDataPath,'figure6trials.csv'));
rs = cell2mat(T.Recside);
T.IDside = strcat(T.ID, rs(:,1));

Thold = T(contains(T.Epoch,'Hold'),:);
Trun = T(contains(T.Epoch,'Run'),:);
Trwd = T(contains(T.Epoch,'Rwd'),:);


%% peakrange
respVar = 'Peakrangenorm';
predictorVars = {'Speed','Modality','TaskType','Difficulty','Correct'};

% hold
figure
axn(1) = subplot(2,3,1,'next','add');
axn(2) = subplot(2,3,2,'next','add');
axn(3) = subplot(2,3,3,'next','add');
axn(4) = subplot(2,3,4,'next','add');
axn(5) = subplot(2,3,5,'next','add');
axn(6) = subplot(2,3,6,'next','add');

EOI = 'Hold';

COI = 'ori';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(1:3),Thold,respVar,predictorVars,COI,EOI,params);

COI = 'rad';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(4:6),Thold,respVar,predictorVars,COI,EOI,params);

% run
figure
axn(1) = subplot(2,3,1,'next','add');
axn(2) = subplot(2,3,2,'next','add');
axn(3) = subplot(2,3,3,'next','add');
axn(4) = subplot(2,3,4,'next','add');
axn(5) = subplot(2,3,5,'next','add');
axn(6) = subplot(2,3,6,'next','add');

EOI = 'Run';

COI = 'ori';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(1:3),Trun,respVar,predictorVars,COI,EOI,params);

COI = 'rad';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(4:6),Trun,respVar,predictorVars,COI,EOI,params);

% rwd
figure
axn(1) = subplot(2,3,1,'next','add');
axn(2) = subplot(2,3,2,'next','add');
axn(3) = subplot(2,3,3,'next','add');
axn(4) = subplot(2,3,4,'next','add');
axn(5) = subplot(2,3,5,'next','add');
axn(6) = subplot(2,3,6,'next','add');

EOI = 'Rwd';

COI = 'ori';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(1:3),Trwd,respVar,predictorVars,COI,EOI,params);

COI = 'rad';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(4:6),Trwd,respVar,predictorVars,COI,EOI,params);


%% freq
respVar = 'Freq';
predictorVars = {'Speed','Modality','TaskType','Difficulty','Correct'};

% hold
figure
axn(1) = subplot(2,3,1,'next','add');
axn(2) = subplot(2,3,2,'next','add');
axn(3) = subplot(2,3,3,'next','add');
axn(4) = subplot(2,3,4,'next','add');
axn(5) = subplot(2,3,5,'next','add');
axn(6) = subplot(2,3,6,'next','add');

EOI = 'Hold';

COI = 'ori';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(1:3),Thold,respVar,predictorVars,COI,EOI,params);

COI = 'rad';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(4:6),Thold,respVar,predictorVars,COI,EOI,params);

% run
figure
axn(1) = subplot(2,3,1,'next','add');
axn(2) = subplot(2,3,2,'next','add');
axn(3) = subplot(2,3,3,'next','add');
axn(4) = subplot(2,3,4,'next','add');
axn(5) = subplot(2,3,5,'next','add');
axn(6) = subplot(2,3,6,'next','add');

EOI = 'Run';

COI = 'ori';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(1:3),Trun,respVar,predictorVars,COI,EOI,params);

COI = 'rad';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(4:6),Trun,respVar,predictorVars,COI,EOI,params);

% rwd
figure
axn(1) = subplot(2,3,1,'next','add');
axn(2) = subplot(2,3,2,'next','add');
axn(3) = subplot(2,3,3,'next','add');
axn(4) = subplot(2,3,4,'next','add');
axn(5) = subplot(2,3,5,'next','add');
axn(6) = subplot(2,3,6,'next','add');

EOI = 'Rwd';

COI = 'ori';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(1:3),Trwd,respVar,predictorVars,COI,EOI,params);

COI = 'rad';
out.(EOI).(COI).(respVar) = plot_dev_analysis(axn(4:6),Trwd,respVar,predictorVars,COI,EOI,params);



end 

function out = plot_dev_analysis(axn,T,respVar,predictorVars,COI,EOI,params)

title(axn(1),{['predicting ' respVar ' in ' EOI ' window']; COI})

ids = [params.R.plotorder_recside_linprobe params.F.plotorder_recside_linprobe];
for n = 1:numel(ids)
    id = ids{n};
    Tin = T(contains(T.IDside,id)&contains(T.Chan,COI),:);
    if isempty(Tin)
        continue
    end
    [out.(id).dev,out.(id).dev_ns,out.(id).dev_ft] =  run_deviance_analysis(axn,Tin,predictorVars,respVar);
end
end