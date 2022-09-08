function params = get_parameters

% all analysis parameters/paths

rootdrive = ''; % insert location of data


%% paths/reference tables
params.figDataPath         = fullfile(rootdrive,'FigureData');
params.F.preprocessingPath = fullfile(rootdrive,'Ferret data','Preprocessing');
params.F.extDataPath       = fullfile(rootdrive,'Ferret data');
params.F.processedDataPath = fullfile(rootdrive,'Ferret data','ProcessedData');
params.F.refPath           = fullfile(rootdrive,'metadata');
params.F.refFn             = 'ferretReference.mat';
params.F.IDs               = {'KIW','EMU','BEA','ANI'};
params.F.IDsides           = {'KIWL','KIWR','EMUL','BEAL','BEAR','ANIL','ANIR'};

% KIW = F1
% EMU = F2
% BEA = F3
% ANI = F4

params.R.preprocessingPath = fullfile(rootdrive,'Rat data','Preprocessing');
params.R.extDataPath       = fullfile(rootdrive,'Rat data');
params.R.processedDataPath = fullfile(rootdrive,'Rat data','ProcessedData');
params.R.refPath           = fullfile(rootdrive,'Rat data','reference');
params.R.refFn             = 'ratReference.mat';
params.R.ID                = {'DBLU','ERED','DRED'};
params.R.IDsides           = {'DBLUR','EREDR','DREDR'};

% DBLU = R1
% ERED = R2
% DRED = R3


%% data extraction and cleaning
% ferret
% trials cleaning - removing trial where ferrets set off too soon
params.F.trials.holdSpeedThreshWin = 0.2; % 200ms pre stimulus
params.F.trials.holdSpeedThresh    = 10; %cm/s

%% trial extraction params
params.trial_ext.holdshift = 0.05; % seconds before stim
params.trial_ext.R_rwd_ylim = 45;  

%% spectral analysis
% ferret theta filter
params.F.theta_bandwidth = [2 8]; % Hz
params.F.theta_filtOrder = 1000;  % samples

% rat theta filter
params.R.theta_bandwidth = [4 14]; % Hz
params.R.theta_filtOrder = 500;    % samples

% common to both species
params.SR = 1000;
params.speedThresh.moving     = 10;      % cm/s - speed threshold, speed > thresh for when looking at signals during movement
params.speedThresh.immobile   = 5;       % cm/s - speed threshold, speed < thresh for when looking at signals during movement
params.speedThresh.movControl = [15 25]; % cm/s - speed limits within which "control" parameters for neural signals are calculated (ie for comparison with data within trials)

% peak-trough analysis
params.PT_thresh_pc = 0.25; % percent of median amp that is used to calc range over which local extrema are found


% xcorr/fft analysis
params.xcorr.win_samples = 1000;        % samples
params.xcorr.win_seconds = 0.999;      % seconds
params.xcorr.gauss_order = 2;           % for fft guassian fitting
params.xcorr.freqResolution = 0.1; % Hz
params.xcorr.F.freq_range = [2 14]; % Hz
params.xcorr.R.freq_range = [4 14]; % Hz


%% Channel mapping
%  mapping channels (linear probe animals: 1 is top of probe, 32 is bottom of probe; tetrode animal mapping based on tetrode wiring)
params.F.linear32.W.map0 = 1:32; % default for when mapping unknown
params.F.linear32.W.map1 = [18 16 20 14 17 15 19 13 31 1 29 3 32 2 27 5 30 4 25 7 28 6 23 9 26 8 21 11 24 10 22 12];  % with neuronexus print upside down on omnetics connector
params.F.linear32.W.map2 = [15 17 13 19 16 18 14 20 2 32 4 30 1 31 6 28 3 29 8 26 5 27 10 24 7 25 12 22 9 23 11 21];  % with neuronexus print upside down on omnetics connector, MCS flipped 180 deg


params.F.linear32.T.map0 = 1:32; % default for when mapping unknown
params.F.linear32.T.map1 = [2,1,4,3,6,5,8,7,10,9,12,11,14,13,16,15,18,17,20,19,22,21,24,23,26,25,28,27,30,29,32,31]; % adapter orientation 1, cable orientation 1
params.F.linear32.T.map2 = [5,6,7,8,1,2,3,4,13,14,17,18,9,10,21,22,11,12,25,26,15,16,29,30,19,20,31,32,23,24,27,28]; % adapter orientation 2 "flipped", cable orientation 1;

% NOTE! in ferret tethered maps above, data on channel 1 is incorrect due to error during recording (is a duplicate of chan 15 instead)

% With map 1 (for both W and T): RHS_tetrode_order = [4, 1, 2, 3] ; LHS_tetrode_order = [8, 5, 6, 7] ;
params.F.tetrode16.W.map0 = 1:16;
params.F.tetrode16.W.map1 = [15, 13, 11, 9, 7, 5, 3, 1, 2, 4, 6, 8, 10, 12, 14 ,16]; 
params.F.tetrode16.T.map1 = 1:16;

% rat has only one map
params.R.linear32.T.map1 = 1:32;


%% Channel assignments 
% refers to mapped channels, top of probe is channel 1
% estimated based on depth profile of theta, and ripple power in the rats
% pyramidal layer
params.pCL.KIWL  = 6; 
params.pCL.KIWR  = [];
params.pCL.EMUL  = []; 
params.pCL.BEAL  = 12; 
params.pCL.BEAR  = 15; 
params.pCL.ANIL  = [];     
params.pCL.ANIR  = [];    
params.pCL.DBLUR = 17;
params.pCL.EREDR = 16;  
params.pCL.DREDR = [];

% stratum oriens (for probes that cross the CL is CL-2)
params.oCL.KIWL  = 4; 
params.oCL.KIWR  = 7;  
params.oCL.EMUL  = 15; 
params.oCL.BEAL  = 10; 
params.oCL.BEAR  = 13; 
params.oCL.ANIL  = [];     
params.oCL.ANIR  = [];    
params.oCL.DBLUR = 15;
params.oCL.EREDR = 14;  
params.oCL.DREDR = 20;

% stratum radiatum/lacunosum moleculare
params.rCL.KIWL  = 10;
params.rCL.KIWR  = []; 
params.rCL.EMUL  = [];
params.rCL.BEAL  = 16;
params.rCL.BEAR  = 19;  
params.rCL.ANIL  = [];     
params.rCL.ANIR  = [];    
params.rCL.DBLUR = 21;
params.rCL.EREDR = 20;  
params.rCL.DREDR = [];

% channels for atropine analysis
params.atr.ANIL = 12;
params.atr.ANIR = 15;
params.atr.KIWR = 16;

%%  plotting parameters
params.F.plotorder_animal = {'KIW','EMU','BEA','ANI'};
params.F.plotorder_animal_lbl = {'F1','F2','F3','F4'};
params.F.plotorder_animal_linprobe = {'KIW','EMU','BEA'};
params.F.plotorder_animal_linprobe_lbl = {'F1','F2','F3'};
params.F.plotorder_recside_linprobe = {'KIWL','KIWR','EMUL','BEAL','BEAR'};
params.F.plotorder_recside_linprobe_lbl = {'F1_{L}','F1_{R}','F2_{L}','F3_{L}','F1_{R}'};

params.R.plotorder_animal = {'DBLU','ERED','DRED'};
params.R.plotorder_animal_lbl = {'R1','R2','R3'};
params.R.plotorder_animal_linprobe = {'DBLU','ERED','DRED'};
params.R.plotorder_animal_linprobe_lbl = {'R1','R2','R3'};
params.R.plotorder_recside_linprobe = {'DBLUR','EREDR','DREDR'};
params.R.plotorder_recside_linprobe_lbl = {'R1_{R}','R2_{R}','R3_{R}'};

params.plotting.bgax_tick_col = [0.0000000001 0.0000000001 0.0000000001]; 
params.plotting.ax_letter_col = [0.000000000001 0.000000000001 0.000000000001]; 

params.lbl.KIW  = 'F1';
params.lbl.KIWL = 'F1_{L}';  % for use with tex interpreter
params.lbl.KIWR = 'F1_{R}';
params.lbl.EMU  = 'F2';
params.lbl.EMUL = 'F2_{L}';
params.lbl.BEA  = 'F3';
params.lbl.BEAL = 'F3_{L}';
params.lbl.BEAR = 'F3_{R}';
params.lbl.ANI  = 'F4';
params.lbl.ANIL = 'F4_{L}';
params.lbl.ANIR = 'F4_{R}';

params.lbl.DBLU  = 'R1';
params.lbl.DBLUR = 'R1';
params.lbl.ERED  = 'R2';
params.lbl.EREDR = 'R2';
params.lbl.DRED  = 'R3';
params.lbl.DREDR = 'R3';

params.col.F     = [0.9,0.6,0];
params.col.R     = [0.35, 0.7, 0.9];
params.col.KIW   = [0.9,0.8,0]; 
params.col.KIWL  = [0.9,0.8,0];
params.col.KIWR  = [0.9,0.8,0]; 
params.col.EMU   = [0.9,0.6,0];
params.col.EMUL  = [0.9,0.6,0];
params.col.BEA   = [0.9,0.3,0];  
params.col.BEAL  = [0.9,0.3,0];
params.col.BEAR  = [0.9,0.3,0];  
params.col.ANI   = [0.9,0,0]; 
params.col.ANIL  = [0.9,0,0];     
params.col.ANIR  = [0.9,0,0];    
params.col.DBLU  = [0.35,0.3,0.9];
params.col.DBLUR = [0.35,0.3,0.9];
params.col.ERED  = [0.35,0.7,0.9];  
params.col.EREDR = [0.35,0.7,0.9];  
params.col.DRED  = [0, 0.9, 1];
params.col.DREDR = [0, 0.9, 1];

params.col.atr  = [0 125 50]./255;
params.col.imm  = [0.6 0.6 0.6];
params.col.hold = [0.3 0.3 0.3]; 
params.col.rwd  = [111,12,90]/255;


params.mkr.F     = '';
params.mkr.R     = '';
params.mkr.KIW   = '<'; 
params.mkr.KIWL  = '<'; 
params.mkr.KIWR  = '>';
params.mkr.EMU   = 'o';
params.mkr.EMUL  = 'o';
params.mkr.BEA   = '^';   
params.mkr.BEAL  = '^';
params.mkr.BEAR  = 'v';   
params.mkr.ANI   = 's'; 
params.mkr.ANIL  = 's';    
params.mkr.ANIR  = 'd';    
params.mkr.DBLU  = '^';
params.mkr.DBLUR = '^';
params.mkr.ERED  = 'o';
params.mkr.EREDR = 'o';
params.mkr.DRED  = 's';
params.mkr.DREDR = 's';  

params.mkr.CL = '+';
params.mkr.DG = 'd';