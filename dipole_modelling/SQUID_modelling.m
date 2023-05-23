%% SQUID modelling

% first I need to run 'dipolefitting_SQUID.m'.
% Also in this script I use the function 'ni2_topoplot()' from the NI2 course

load 'C:\Users\user\Documents\Courses\2nd Semester\Neuroimaging II\Matlab\fieldtrip\template\gradiometer\neuromag306.mat';
neuromag306 = ft_convert_units(neuromag306, 'cm');
% ft_plot_sens(neuromag306, 'label', 'no', 'axes', 0, 'orientation', 0, 'chantype', 'megmag', 'marker','o');

headmodel=singlesphere;
headmodel.type='singlesphere';


dippos=source.dip.pos; 
dipmom=source.dip.mom;




%% Modify the structure of neuromag306 to contain only the 102 megmag sensors!

indices = find(ismember(neuromag306.chantype, 'megmag'));
neuromag102=struct();
neuromag102.balance=neuromag306.balance;
neuromag102.chanori = neuromag306.chanori(indices,:);
neuromag102.chanpos = neuromag306.chanpos(indices,:); 
neuromag102.chantype = neuromag306.chantype(indices);  
neuromag102.chanunit = neuromag306.chanunit(indices);
% neuromag102.coilori = neuromag306.coilori(indices,:);
% neuromag102.coilpos = neuromag306.coilpos(indices,:);
neuromag102.label = neuromag306.label(indices);
neuromag102.coordsys = neuromag306.coordsys;
neuromag102.unit = neuromag306.unit;


%% Calculate leadfield


cfg                  = [];
cfg.sourcemodel.pos    = dippos;
cfg.grad             = neuromag306;
cfg.headmodel        = singlesphere;
cfg.channel         = 'megmag';
cfg.unit             = 'cm';
leadfield = ft_prepare_leadfield(cfg);


%% Plot modelled topography

%N20 component
leadfield_vector=leadfield.leadfield{1}*dipmom(:,3);
ni2_topoplot(neuromag102,leadfield_vector);


%% Plot movie of sensor-level topography from t=0.018 - 0.022

Vmodel=leadfield.leadfield{1, 1}*dipmom; 
figure;
ni2_topomovie(neuromag102, Vmodel, source.time);

%Conclusion:   ''This dipole ROTATES from diagonal between +x (to nose) and +y (to left ear) [at t=0.018] to +x [at P22]''. While I
%would expect: ''This dipole ROTATES from diagonal between +x (to nose) and +y (to left ear) [at N20] to +z [at P22]''


%% What I did above is already done by ft_dipolefitting():

figure;
ni2_topomovie(neuromag102, source.Vmodel, source.time);



%% Visualise real data (aka Vdata) and compare with Vmodel
load 'C:\Users\user\Documents\Courses\Internship\MN_Stimulation\3rd Analysis - SQUID - ECD\timelock_SQUID.mat'
load 'C:/Users/user/Documents/Courses/2nd Semester/Neuroimaging II/Matlab/fieldtrip/template/layout/neuromag306mag_helmet.mat';

cfg=[];
cfg.layout=layout;
cfg.marker = 'labels';
cfg.colormap='-RdBu';
cfg.xlim=[0.020 0.020];
topo=ft_topoplotER(cfg,timelock) %timelock is the ''Vdata''


%% Compare Vdata with Vmodel for N20 component

Vmodel=leadfield.leadfield{1, 1}*dipmom;
Vmodel_N20=Vmodel(:,3);

i = find(ismember(neuromag306.chantype, 'megmag'));
Vdata_N20=timelock.avg(11-2+i,121);



%% Pearson's correlation coefficient r

R=corr(Vdata_N20,Vmodel_N20)

%% R-squared (coefficient of determination) 

R_squared = 1 - sum((Vdata_N20 - Vmodel_N20).^2) / sum((Vdata_N20 - mean(Vdata_N20)).^2)

