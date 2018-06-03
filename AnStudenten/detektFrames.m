function [subframe] = detektFrames(iKorr, subframe);
 
    preamble = [1; -1; -1; -1; 1; -1; 1; 1];

    %% Korrelation der Bit-Information mit der Preamble
    for j= 1:1800
        mean = 0;

        for i=1:8
            mean = mean + preamble(i,1) * iKorr(j+i,4);
        end;

        corr(j,1) = j;
        corr(j,2) = mean;
    end;

    figure(3)
    plot(corr(:,1), corr(:,2))
    axis([0 1800 -9 9])
    xlabel('Verschiebung [bit]', 'fontsize', 20);
    set(gca,'fontsize',18,'FontName','arial');
    grid on;

    %% Bestimme Start der Subframes
    cnt = 1;
    for i=1:1200
    
        if( (corr(i,2)==8) && (corr(i+300,2)==8))
            startSubFrame(cnt,1) = i;
        
            status = 1;
        
            cnt = cnt + 1;
        end;
    
        if( (corr(i,2)==-8) && (corr(i+300,2)==-8))
            startSubFrame(cnt,1) = i;
        
            status = 0;
        
            cnt = cnt + 1;
        end;
    
    end;

    startSubFrame(cnt,1) = startSubFrame(cnt-1,1)+300;


    %% Durchfuehrung des "Parity Check"
    cnt = 1;
    cnt2 = 1;
    cnt30 = 0;

    for j=1:5
        cnt2 = 1;
        for i=1:30:300       
            for k=1:32          
                partframe(k,1) = iKorr(startSubFrame(1,1)+k-2 + cnt30, 4);
                cnt = cnt + 1;
            end;
        
            cnt30 = cnt30 + 30;
        
            status = parityCheck(partframe);
        
            if((status == 1))
                for k=1:30
                    if(partframe(k+2,1) == -1)
                        subframe(i+k-1,j) = 0;
                    else
                        subframe(i+k-1,j) = 1;
                    end;
                end;
            elseif((status == -1)) 
                for k=1:30                
                    if(partframe(k+2,1) == -1)
                        subframe(i+k-1,j) = 1;
                    else
                        subframe(i+k-1,j) = 0;
                    end;        
                end;
            end;
            
            cnt2 = cnt2 + 1;
                
        end;
    end;
    
end