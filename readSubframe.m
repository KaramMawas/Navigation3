function [ message ] = readSubframe(subframe, message )
% READSUBFRAME extract messages from each frame.
%   Detailed explanation goes here

        % extract Weeknumber from subframe 1 [001 - col 5]
        WkNo = num2str(subframe(61:70,5)');
        message.GPSWoche = bin2dec(WkNo);
        
        % extract toe from subframe 2 [010 - col 1] 16bits, and 2's
        % complement
        toe = num2str(subframe(271:286,1)');
        message.Toe = bin2dec(toe);
        
        
        % extract cic from subframe 3 [011 - col 2]      
        a = subframe(61:76,2)';
        
        if  (a(1) == 0) % if the word is unsigned, use LSB(last 8 bits directly and multiply with scale)
            cic = num2str(a(9:16));
            message.cic = bin2dec(cic) * 2^-29;
       
        end
        %         elseif(a(1) == 1) 
%             cic = (bitcmp(bin2dec(num2str(a)))) + 1;%      
        
        message.Cic = cic
end

