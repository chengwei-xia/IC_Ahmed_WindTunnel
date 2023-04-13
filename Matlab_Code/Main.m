%% Main

% Previous Edited: 2014-11-05 (George)
% Last Edited: 2023-03-30 (Chengwei)


clear
clc
set(0,'DefaultTextInterpreter','latex')
set(0,'DefaultAxesFontSize',14)

%------------ Data Path ----------------
PathName = '/Users/chengweixia/Documents/Exp_Data_2023/30_Mar_RNNPPO1/';
FileNameESP ='ESPData_30_03_Run7_Base.dat';
FileNameRT ='RTData_30_03_Run7_Base.dat';
%---------------------------------------

%------------ Code path -----------------------
% Either cd or add to Matlab path: '.../Exp_Matlab_2023' and '.../Exp_Matlab_2023/Utilities'
%cd('/Users/chengweixia/Documents/Exp_Matlab_2023')
addpath('/Users/chengweixia/Documents/Exp_Matlab_2023','/Users/chengweixia/Documents/Exp_Matlab_2023/Utilities/','-end')
%----------------------------------------------


%------------ Data ----------------------------
% 1-7   : Endevco
% 8-10  : Force (Fx,Fy,Fz)
% 11-14 : Power
% 15-18 : Voltage
% 19-22 : Action
%----------------------------------------------

%----- Endevco ---------
%
%   7-----1-----2
%   |           |
%   6           3
%   |           |
%   5-----X-----4        (X is the broken sensor)
%
%-----------------------

s = [1 2 3;
     3 4 5
     7 6 5
     1 8 7]; %side index

% Parameters

Chan_Force  = 8; % Channel number of the first force measurement
N_Endev     = 7;
N_Force     = 3;

fscale      = 0.216/15; % Nondimensionlize frequency to St, with respect to the width of the body
fscale_z    = 0.160/15; % Nondimensionlize with the height of the body
nwindow     = 2^8; % Length of the window used in pwelch 
                   % Smaller window provides smoother psd but larger window provides larger frequency range
movavg_window = 1000;

nchanESP = 64;
FsESP = 100;
nchanRT = 26;
FsRT = 100;

k = 2; % Index of "data"

AnalyseTraining = false;
TrainingSet = []; % Step numbers of training data, removing RL reset phases and UDP restart intervals


%% Read ESP

fid = fopen([PathName,FileNameESP],'r','a');
DataESP = fread(fid,[nchanESP,inf],'float32');
DataESP=DataESP(:,:);
fclose(fid);

[np,nt] = size(DataESP);

tESP = 0:1/FsESP:((nt-1)/FsESP);

disp('Loaded ESP data')

%% Read RT

fid = fopen([PathName,FileNameRT],'r','a');
DataRT = fread(fid,[nchanRT,inf],'float64');
if AnalyseTraining == true
    DataRT = DataRT(:,TrainingSet);
else
DataRT=DataRT(:,:);
end
fclose(fid);

[np,nt] = size(DataRT);
Time = (1:nt)/FsRT;

tRT = 0:1/FsRT:((nt-1)/FsRT);

disp('Loaded RT data')

% figure(2);clf;hold all
% for i=1:7
%     plot(tRT,DataRT(i,:))
% end

%% Plot time-series

figure(1);hold all
plot(DataRT(8,1:end))
%plot(DataESP(2,:))

%% Plot Actions

figure(111);hold all
for i = 1:4
plot(Time,DataRT(22+i,1:end))
end
set(gca,'TickLabelInterpreter','latex');
set(gca,'Linewidth',1);
set(gca,'Fontsize',16);
xlabel("Time")
ylabel("Actions")
%plot(DataESP(2,:))

%% Plot Moving Average

MovA_P = movmean(DataRT(1:N_Endev,:),movavg_window,2);
MovA_F = movmean(DataRT(Chan_Force:Chan_Force+N_Force,:),movavg_window,2);
figure(6); clf; hold all
for j = 1:N_Endev
plot(Time,MovA_P(j,:),'LineWidth',2);
end
set(gca,'TickLabelInterpreter','latex');
set(gca,'Linewidth',1);
set(gca,'Fontsize',16);
xlabel("Time")
ylabel("Moving Average - Pressure")
xlim([0,Time(end)])
figure(7); clf; hold all
for i = 1:N_Force
plot(Time,MovA_F(i,:),'LineWidth',2);
end
legend('Drag','SideForce','Lift','interpreter','latex','Location','best')
set(gca,'TickLabelInterpreter','latex');
set(gca,'Linewidth',1);
set(gca,'Fontsize',16);
xlabel("Time")
ylabel("Moving Average - Force")
xlim([0,Time(end)])

%% Mean-RMS

data(k).Pmean = mean(DataRT(1:N_Endev  ,:),2);
data(k).Fmean = mean(DataRT(Chan_Force:Chan_Force+N_Force-1,:),2);

data(k).Prms = std(DataRT(1:N_Endev  ,:),0,2);
data(k).Frms = std(DataRT(Chan_Force:Chan_Force+N_Force-1,:),0,2);

figure(2);clf;hold all
plot(data(k).Pmean)
title('Pmean')
figure(3);clf;hold all
plot(data(k).Prms)
title('Prms')
figure(4);clf;hold all
plot(data(k).Fmean)
title('Fmean')
figure(5);clf;hold all
plot(data(k).Frms)
title('Frms')


%% PSD

data(k).Ppsd = zeros(N_Endev,nwindow/2+1);
data(k).Fpsd = zeros(N_Force,nwindow/2+1);

% Pressure
for i=1:N_Endev

    [data(k).Ppsd(i,:),data(k).Pfpsd] = pwelch(detrend(DataRT(i,:)),hanning(nwindow),0.5*nwindow,nwindow,FsRT*fscale);
 
end

% Force
for i=1:N_Force

    [data(k).Fpsd(i,:),data(k).Ffpsd] = pwelch(detrend(DataRT(Chan_Force+i-1,:)),hanning(nwindow),0.5*nwindow,nwindow,FsRT*fscale);
 
end

%% Modal decomposition

% Mode 1: UpDown
tmp = sum(DataRT([7,2],:),1) - sum(DataRT([5,4],:),1) ;
[data(k).Pmpsd(1,:),data(k).Pfpsd] = pwelch(detrend(tmp),hanning(nwindow),0.5*nwindow,nwindow,FsRT*fscale);

% Mode 3: LeftRight
tmp = sum(DataRT([2,3,4],:),1) - sum(DataRT([7,6,5],:),1) ;
[data(k).Pmpsd(2,:),data(k).Pfpsd] = pwelch(detrend(tmp),hanning(nwindow),0.5*nwindow,nwindow,FsRT*fscale);

% % Mode 3: Diagonal
% tmp = sum(ai([7,8,1,2],:)) - sum(ai([3,4,5,6],:)) ;
% [data(k).Pmpsd(3,:),data(k).Pfpsd] = pwelch(detrend(tmp),hanning(nwindow),0.5*nwindow,nwindow,FsRT*fscale);



%% Plot PSD Figures

Select.All = false;
Select.Endev = true;
Select.Force = true;
Select.Modal = true;
Select.CoP = false;
FigNum = [12,13,14];

PSDPlot(data(2),FigNum,Select)
hold all

%% Plot Mean-rms Pressure

% figure;
% 
% for i=1:4
%     subplot(211)
%     plot(data(2).Pmean(s(i,:))-data(1).Pmean(s(i,:)),'-o')
%     hold all
%     
%     subplot(212)
%     plot(data(2).Prms(s(i,:))-data(1).Prms(s(i,:)),'-o')
%     hold all
% 
% end
% xlim([0 4])

%% Plot Forces
% greyC = [0.7,0.7,0.7]; %define grey color
% 
% ytmpl{1}  = 'Mean Force (N)';
% ytmp(1,:) = data(2).Fmean(1:3)-data(1).Fmean(1:3);
% 
% ytmpl{2}  =' RMS Force (N)';
% ytmp(2,:) = data(2).Frms(1:3);
% 
% ytmpl{3}  = 'Mean Torque (N)';
% ytmp(3,:) = data(2).Fmean(4:6)-data(1).Fmean(4:6);
% 
% ytmpl{4}  = 'RMS Torque (Nm)';
% ytmp(4,:) = data(2).Frms(4:6);
% 
% 
% 
% figure(17);clf
% for i=1:4
% subplot(2,2,i)
% bar(ytmp(i,:),0.6,'FaceColor',greyC)
% text(1:3,ytmp(i,:)',num2str(ytmp(i,:)','%0.3f'),'HorizontalAlignment','center','VerticalAlignment','bottom')
% xlabel('Component')
% ylabel(ytmpl{i}),set(gca,'XTickLabel',{'x','y','z'}) 
% end

%% Drag Coefficient
Temp = 23.3;
Pinf = 0.5*1.2041*15^2; %rho_air = 1.2041 (20C) -> Pinf = 101.7 Pa
Ab = 0.160*0.216;       % area base
At = 0.58*0.216;        % area top
As = 0.58*0.160;        % area side

Cd =    data(2).Fmean(1)/(Pinf*Ab);%(data(2).Fmean(1)-data(1).Fmean(1))/(Pinf*Ab)  % Grandemange: 0.274, Ahmed: 0.25
Cl =    data(2).Fmean(3)/(Pinf*At);%(data(2).Fmean(3)-data(1).Fmean(3))/(Pinf*At)  % Grandemange: 0.038
Cs =    data(2).Fmean(2)/(Pinf*As);%(data(2).Fmean(2)-data(1).Fmean(2))/(Pinf*As)  % should be zero


%% Plot ESP Contour
figure(17);hold all
Nx = 8;
Ny = 8;
resX = 8;
resY = 8;
plotESP_Ahmed(mean(DataESP,2), Nx, Ny, resX, resY)
xlabel("Y")
ylabel("Z")

%% Plot CoP

[CoPx,CoPy] = EvalCoP( DataESP ); % x is the width and y is the height here
data(k).Cpsd = zeros(1,nwindow/2+1);

[data(k).Cpsd(1,:),data(k).Cfpsd] = pwelch(detrend(CoPx(1,:)),hanning(nwindow),0.5*nwindow,nwindow,FsESP*fscale);

time = (1:size(CoPx,2))*1/FsESP;
figure(18);clf;hold all
plot(time,CoPx)
set(gca,'TickLabelInterpreter','latex');
set(gca,'Linewidth',1);
set(gca,'Fontsize',16);
xlabel("Time")
ylabel("CoP")
%plot(CoPy)

%% Plot PSD of CoP
Select.All = false;
Select.Endev = false;
Select.Force = false;
Select.Modal = false;
Select.CoP = true;
FigNum = [0 0 0 19];

PSDPlot(data(2),FigNum,Select)
hold all

%% Plot PDF of CoP

% histograms of CoP
figure(20);clf;hold all
histogram(CoPx,100)
set(gca,'TickLabelInterpreter','latex');
set(gca,'Linewidth',1);
set(gca,'Fontsize',16);
xlabel("CoP")
ylabel("PDF")
