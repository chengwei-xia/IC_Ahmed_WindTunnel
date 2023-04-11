clear all; close all
set(0,'DefaultTextInterpreter','latex')

PathName = 'C:\Users\aabud\Desktop\Experiment_March_2023\Saved Data\';
FileNameESP ='ESPData_SecondRun.dat';
FileNameRT ='RTData_SecondRun.dat';

nchanESP = 64;
FsESP = 100;

nchanRT = 26;
FsRT = 50;

%% read ESP

fid = fopen([PathName,FileNameESP],'r','a');
DataESP = fread(fid,[nchanESP,inf],'float32');
DataESP=DataESP(:,10000:end);
fclose(fid);

[np,nt] = size(DataESP);

tESP = 0:1/FsESP:((nt-1)/FsESP);

disp('Loaded ESP data')

figure(1);clf;hold all
for i=1:64
    plot(tESP,DataESP(i,:))
end

%% read RT

fid = fopen([PathName,FileNameRT],'r','a');
DataRT = fread(fid,[nchanRT,inf],'float64');
DataRT=DataRT(:,5000:end);
fclose(fid);
%for i=1:7
%    DataRT(i,:)=detrend(DataRT(i,:));
%end
[np,nt] = size(DataRT);

tRT = 0:1/FsRT:((nt-1)/FsRT);

disp('Loaded RT data')

figure(2);clf;hold all
for i=1:7
    plot(tRT,DataRT(i,:))
end

%% Detrend 

DataESP_mean = mean(DataESP,2);
DataRT_mean = mean(DataRT,2);

figure(44);clf;hold all
plot(DataRT_mean,'k*-')
plot(DataESP_mean,'bo-')

DataESP_RMS = std(DataESP,0,2);
DataRT_RMS = std(DataRT,0,2);

figure(44);clf;hold all
plot(DataRT_RMS,'k*-')
plot(DataESP_RMS,'bo-')



DataESP_fluct = DataESP-DataESP_mean;
DataRT_fluct  = DataRT-DataRT_mean;


k=6;
i=8;
j=16;

figure(3);clf;hold all;

plot(tESP,DataESP_fluct(i,:))
plot(tESP,DataESP_fluct(j,:))
plot(tRT-2,DataRT_fluct(k,:))
legend('ESP1','ESP2','EDV')