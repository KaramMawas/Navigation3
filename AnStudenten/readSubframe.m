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
        
        % extract toe from subframe 3 [011 - col 2]
        cic = num2str(subframe(61:76,2)') ;    
        message.Cic = bitcmp(bin2dec(cic),'uint16');
end

