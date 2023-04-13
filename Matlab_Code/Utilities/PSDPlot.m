function [] = PSDPlot(Data,FigNum,Select)

if Select.All == true
    Select.Endev = true;
    Select.Force = true;
    Select.Modal = true;
end

if Select.Endev == true
    figure(FigNum(1))
    for i=1:7
        %loglog(data(k).Pfpsd, data(k).Ppsd(i,:))
        semilogx(Data.Pfpsd, Data.Pfpsd'.*Data.Ppsd(i,:),LineWidth=1.5)

        hold all
    end
    xlabel("St")
    ylabel("PSD (Pressure)")
    xlim([1e-3,1e0])
end


if Select.Force == true
    legi = {'Drag','SideForce','Lift'};
    figure(FigNum(2));

    for i=1:3
        % Force
        subplot(3,1,i)
        %loglog(data(k).Ffpsd, data(k).Fpsd(i,:))
        semilogx(Data.Ffpsd, Data.Ffpsd'.*Data.Fpsd(i,:),LineWidth=1.5);
        hold all
        xlim([1e-3, 1e0])
        ylabel("PSD ("+legi(i)+")")
    end
    xlabel("St")
end


if Select.Modal == true
    figure(FigNum(3))
    for i=1:2
        %     loglog(data(k).Pfpsd, data(k).Pmpsd(i,:))
        semilogx(Data.Pfpsd, Data.Pfpsd'.*Data.Pmpsd(i,:),LineWidth=1.5)
        hold all
    end
    xlim([1e-3, 1e0])
    xlabel("St")
    ylabel("Modal PSD (Pressure)")
    legend('UD: Uncontrolled','LR: Uncontrolled','UD: Controlled','LR: Controlled','interpreter','latex')
end

if Select.CoP == true
    figure(FigNum(4))
        %     loglog(data(k).Pfpsd, data(k).Pmpsd(i,:))
    semilogx(Data.Cfpsd, Data.Cfpsd'.*Data.Cpsd,LineWidth=1.5)
        hold all
    xlim([1e-3, 1e0])
    xlabel("St")
    ylabel("CoP PSD")
    legend('CoP: Uncontrolled','CoP: Controlled-Early','CoP: Controlled-Late','interpreter','latex')
end

% figure(FigNum)
% if Type == "loglog"
%     loglog(Dataf, DataPSD)
% elseif Type == "semilog"
%     semilogx(Dataf, Dataf'.*DataPSD)
% else
%     error("Invalid option. Please choose loglog or semilog")
% end
% set(gca,'TickLabelInterpreter','latex');
end