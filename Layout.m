%% Finding the layout via a bitmap image

cfg = [];
cfg.image = 'PXL_20230209_092305893.jpg'; %this file exists in the directory: OPM-MEG\20230210-RO\helmet
layout_pos1 = ft_prepare_layout(cfg);

%Now I visualise my result
cfg = [];
cfg.layout = layout_pos1;   % this is the layout structure that I created before
ft_layoutplot(cfg);

save layout_pos1.mat layout_pos1; %Before I save the the 'layout_pos1', I add the correct names for my sensors 



%% Visualizing pos1 using a recording specific layout

filename = {
  '20230208_103319_0916_Coil_tests1_MedianNerve_wCoils_11mA_3Hz_StimBreakStim2min_Pos1_raw.fif'
  '20230208_105231_0916_Coil_tests1_MedianNerve_wCoils_11mA_3Hz_StimBreakStim2min_Pos2_raw.fif'
  '20230208_110830_0916_Coil_tests1_MedianNerve_wCoils_11mA_3Hz_StimBreakStim2min_Pos3_raw.fif'
  '20230208_111535_0916_Coil_tests1_MedianNerve_wCoils_11mA_3Hz_RestingStateEyesOpen_raw.fif'
  '20230208_111912_0916_Coil_tests1_MedianNerve_wCoils_11mA_3Hz_RestingStateEyesClosed_raw.fif'
  };


% MN right hand stimulation
% the two resting state sessions are in pos3
% fieldline alpha 1.5 adjustable MEG helmet
% using the helmet with 107 slots


cfg = [];
cfg.dataset = filename{1};
cfg.preproc.demean = 'yes';
cfg.ylim = [-1 1]*1e-11;
ft_databrowser(cfg)


hdr = ft_read_header(filename{1});

event = ft_read_event(filename{1});


cfg = [];
cfg.dataset = filename{1};
cfg.trialdef.eventtype = 'Input-1';
cfg.trialdef.prestim = 0.1;
cfg.trialdef.poststim = 0.3;
cfg = ft_definetrial(cfg);



cfg.detrend = 'yes';
cfg.baselinewindow = [-inf 0];
data = ft_preprocessing(cfg);



cfg = [];
cfg.method = 'summary';
data_clean = ft_rejectvisual(cfg, data);


cfg = [];
timelock = ft_timelockanalysis(cfg, data_clean);




load('layout_pos1');

cfg = [];
cfg.layout = layout_pos1;
cfg.showoutline = 'yes'; % add outlines
cfg.channel = 2:9;
ft_multiplotER(cfg, timelock); %by clicking on the interactive image, I find the sensor-level topography of certain sensors