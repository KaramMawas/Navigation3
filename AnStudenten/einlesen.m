function [iKorr] = einlesen(dateiName, iKorr)

    %% Einlesen
    iKorr = load(dateiName);

    figure(1)
    plot(iKorr(:,1)/1000, iKorr(:,2));
    xlabel('Zeit [s]', 'fontsize', 20);
    set(gca,'fontsize',18,'FontName','arial');
    grid on;

    % Umwandlung der I-Korrelationen in -1 und +1 Werte
    for i=1:36000
        if(iKorr(i,2) > 0)
            iKorr(i,3) = 1;
        elseif (iKorr(i,2) < 0)
            iKorr(i,3) = -1;
        end
    end;

    figure(2)
    plot(iKorr(:,1)/1000, iKorr(:,2), 'b');
    hold on
    plot(iKorr(:,1)/1000, iKorr(:,3), 'r');
    xlabel('Zeit [s]', 'fontsize', 20);
    set(gca,'fontsize',18,'FontName','arial');
    grid on;

    %% Bit Detektion
    % Unterabtastung der Bit-Information, entsprechend der 50Hz
    cnt = 1;
    for i=1:20:36000
        if(iKorr(i,2) > 0)
            iKorr(cnt,4) = 1;
        elseif (iKorr(i,2) < 0)
            iKorr(cnt,4) = -1;
        end
        cnt = cnt + 1;
    end;
    
end