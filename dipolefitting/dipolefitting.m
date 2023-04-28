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

%%


% cfg = [];
% cfg.dataset = filename{1};
% cfg.ploteventlabels = 'no';
% cfg.preproc.demean = 'yes';
% cfg.ylim = [-1 1]*1e-11;
% ft_databrowser(cfg)

%% every one of the 3 filenames has each own trial distribution, that's why I read the hdr and event for each channel separately->ft_read_event just reads the event and is not used later in the ft_definetrial()

hdr = ft_read_header(filename{1});
event = ft_read_event(filename{1});

cfg = [];
cfg.trialdef.eventtype = 'Input-1';
cfg.trialdef.prestim = 0.1;
cfg.trialdef.poststim = 0.3;

cfg.dataset = filename{1};
cfg = ft_definetrial(cfg);
cfg.detrend = 'yes';
cfg.baselinewindow = [-inf 0];
data_pos1 = ft_preprocessing(cfg);

%%
hdr = ft_read_header(filename{2});
event = ft_read_event(filename{2});

cfg = [];
cfg.trialdef.eventtype = 'Input-1';
cfg.trialdef.prestim = 0.1;
cfg.trialdef.poststim = 0.3;

cfg.dataset = filename{2};
cfg = ft_definetrial(cfg);
cfg.detrend = 'yes';
cfg.baselinewindow = [-inf 0];
data_pos2 = ft_preprocessing(cfg);


%%
hdr = ft_read_header(filename{3});
event = ft_read_event(filename{3});


cfg = [];
cfg.trialdef.eventtype = 'Input-1';
cfg.trialdef.prestim = 0.1;
cfg.trialdef.poststim = 0.3;

cfg.dataset = filename{3};
cfg = ft_definetrial(cfg);
cfg.detrend = 'yes';
cfg.baselinewindow = [-inf 0];
data_pos3 = ft_preprocessing(cfg);

%%

chassis = {1 2 3 4 5 6 7 8};
sensor = {338 119 323 111 62 336 22 246};
pos1 = {'FL30'   'FL21' 'FL20' 'FL23' 'FL36' 'FL35' 'FL34' 'FL84'};
pos2 = {'FL30_2' 'FL38' 'FL37' 'FL28' 'FL27' 'FL19' 'FL18' 'FL84_2'};
pos3 = {'FL30_3' 'FL22' 'FL29' 'FL39' 'FL45' 'FL44' 'FL43' 'FL84_3'};

montage_pos1 = [];
montage_pos1.labelold = {
  '00:01-BZ_OL'
  '00:02-BZ_OL'
  '00:03-BZ_OL'
  '00:04-BZ_OL'
  '00:05-BZ_OL'
  '00:06-BZ_OL'
  '00:07-BZ_OL'
  '00:08-BZ_OL'
  }';
montage_pos1.labelnew = pos1;
montage_pos1.tra = eye(8);

montage_pos2 = [];
montage_pos2.labelold = {
  '00:01-BZ_OL'
  '00:02-BZ_OL'
  '00:03-BZ_OL'
  '00:04-BZ_OL'
  '00:05-BZ_OL'
  '00:06-BZ_OL'
  '00:07-BZ_OL'
  '00:08-BZ_OL'
  }';
montage_pos2.labelnew = pos2;
montage_pos2.tra = eye(8);

montage_pos3 = [];
montage_pos3.labelold = {
  '00:01-BZ_OL'
  '00:02-BZ_OL'
  '00:03-BZ_OL'
  '00:04-BZ_OL'
  '00:05-BZ_OL'
  '00:06-BZ_OL'
  '00:07-BZ_OL'
  '00:08-BZ_OL'
  }';
montage_pos3.labelnew = pos3;
montage_pos3.tra = eye(8); %changes the 8 old labels to the 8 new ones

data_pos1 = ft_apply_montage(data_pos1, montage_pos1); %it changes data_pos1.label with the new labels we want
data_pos2 = ft_apply_montage(data_pos2, montage_pos2);
data_pos3 = ft_apply_montage(data_pos3, montage_pos3);



%% I removed trials with high variance

cfg = [];
cfg.method = 'summary';
data_pos1_clean = ft_rejectvisual(cfg, data_pos1);
data_pos2_clean = ft_rejectvisual(cfg, data_pos2);
data_pos3_clean = ft_rejectvisual(cfg, data_pos3);

%%

cfg = [];
timelock_pos1 = ft_timelockanalysis(cfg, data_pos1_clean);
timelock_pos2 = ft_timelockanalysis(cfg, data_pos2_clean);
timelock_pos3 = ft_timelockanalysis(cfg, data_pos3_clean);

%%

cfg = [];
timelock = ft_appendtimelock(cfg, timelock_pos1, timelock_pos2, timelock_pos3);

timelock.avg = timelock.trial;
timelock = rmfield(timelock, 'trial'); %remove field 'trial'




%%

load fieldlinealpha1.mat %3D helmet
%ft_plot_sens(fieldlinealpha1, 'label', 'yes', 'axes', 1, 'orientation', 1)


load fieldlinealpha1_helmet.mat %2D helmet. It is loaded in the workspace with the name 'layout'
%cfg = [];
%cfg.layout = layout;   
%ft_layoutplot(cfg);

%%
missing = setdiff(layout.label, timelock.label);
missing = missing(startsWith(missing, 'FL')); 


timelock_full = timelock;
timelock_full.label = cat(1, timelock.label, missing);
timelock_full.avg = cat(1, timelock.avg, nan(numel(missing), numel(timelock.time))); %make NaN the values for the missing channels

% timelock_full = rmfield(timelock_full, {'dof', 'var'});


%%

cfg = [];
cfg.layout = layout;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, timelock_full);


%%
timelock_full.avg(isnan(timelock_full.avg)) = 0; %make all NaNs equal to zero

cfg = [];
cfg.layout = 'fieldlinealpha1_helmet.mat';
cfg.colormap = '-RdBu';
ft_movieplotER(cfg, timelock_full);



%% Label the missing channels of the fieldlinealpha1

fieldlinealpha1.chantype( ismember(fieldlinealpha1.label, missing)) = {'missing'};
fieldlinealpha1.chantype(~ismember(fieldlinealpha1.label, missing)) = {'megmag'};

fieldlinealpha1 = ft_convert_units(fieldlinealpha1, 'cm');

ft_plot_sens(fieldlinealpha1, 'label', 'no', 'axes', 1, 'orientation', 1) % , 'chantype', 'megmag')
hold on


%% Sphere as a headmodel

singlesphere = []
singlesphere.r = 0.1*10^2
singlesphere.o = [0.01*10^2 0 0]
singlesphere.unit = 'cm';



[x,y,z] = sphere;
x = x * singlesphere.r + singlesphere.o(1);
y = y * singlesphere.r + singlesphere.o(2);
z = z * singlesphere.r + singlesphere.o(3);
h=surf(x,y,z);
set(h, 'FaceAlpha', 0.5);
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');

%% Equivalent Current Dipole

%1st dipole
cfg=[];
cfg.numdipoles=1;
cfg.latency = [0.018 0.022];
cfg.unit = 'cm';
cfg.gridsearch = 'yes';
cfg.grad             = fieldlinealpha1;
cfg.senstype        = 'meg';            % sensor type
cfg.channel         = 'megmag'; % which channels to use
cfg.headmodel = singlesphere;
source = ft_dipolefitting(cfg, timelock_full);

hold on
ft_plot_dipole(source.dip.pos, mean(source.dip.mom(1:3,:),2), 'color', 'b')


%2nd dipole
cfg=[];
cfg.numdipoles=1;
cfg.latency = [0.120 0.130];
cfg.unit = 'cm';
cfg.gridsearch = 'yes';
cfg.grad             = fieldlinealpha1;
% cfg.senstype        = 'meg';            % sensor type
% cfg.channel         = 'megmag'; % which channels to use
cfg.headmodel = singlesphere;
second_source = ft_dipolefitting(cfg, timelock_full);

hold on
ft_plot_dipole(second_source.dip.pos, mean(second_source.dip.mom(1:3,:),2), 'color', 'g')

