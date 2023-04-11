clear
clc
fileID = fopen('C:\Users\aabud\PycharmProjects\pythonProject1\2023_3_22_Reward_17_30\reward.txt','r');
formatSpec = '%f %f';
sizeA = [3 Inf];
A = fscanf(fileID,formatSpec,sizeA);
No_Steps = 512;

baseline_drag_initial(1:573)=4.346
baseline_drag_final(1:573)=4.343

figure(1);
plot(A(1,1:88),A(3,1:88)./No_Steps);
hold on;
plot(A(1,89:213)+89,A(3,89:213)./No_Steps);
hold on;
plot(A(1,214:276)+214,A(3,214:276)./No_Steps);
hold on;
plot(A(1,277:end)+277,A(3,277:end)./No_Steps);
hold on;
plot(1:573,baseline_drag_initial)
hold on;
plot(1:573,baseline_drag_final)
xlabel('Episodes')
ylabel('Drag')

figure(2);
plot(A(1,:),A(2,:));
xlabel('Episodes')
ylabel('Total Episode Reward')


