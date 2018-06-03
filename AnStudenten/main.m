clear all;
close all;
clc;

format long;


%% Definition der globalen Variablen

dateiName = 'iKorrSV21.txt';                        % Satellit 21

iKorr(1:36000,1:4) = 0;
subframe(1:300,1:5) = 0;
 
message = struct(...
                    'GPSWoche', 0, ...
                    'af0', 0, ...
                    'af1', 0, ...
                    'af2', 0, ...
                    'TGD', 0, ...
                    'Toe', 0, ...
                    'Cic', 0, ...
                    'Crs', 0, ...
                    'Cus', 0, ...
                    'Cuc', 0, ...
                    'Cis', 0, ...
                    'sqrtA', 0, ...
                    'deltaN', 0, ...
                    'M0', 0, ...
                    'e', 0, ...
                    'omega0', 0, ...
                    'omega', 0, ...
                    'omegaDot', 0, ...
                    'iDot', 0);

                
%% Einlesen der I-Korrelationen und Umwandlung in Bits
[iKorr] = einlesen(dateiName, iKorr);


%% Detektion der SubFrames
[subframe] = detektFrames(iKorr, subframe);


%% Lese Information
% [message] = leseMessage(subframe, message);


% Week Gps (10 bits) subframe(1)
WK = subframe(61:70,5);
WK = flipud(WK);
t = zeros(length(WK),1)';
for i =1:length(WK)
    if WK(i)==1
        t(i) = WK(i)*2^(i-1);
    else 
        t(i) = WK(i);
    end
end
WeekGPS = sum(t)+1024;

% Time ref. (16 bits) subframe(2)
toe = subframe(271:286,1);
toe = flipud(toe);
t = zeros(length(toe),1)';
for i =1:length(toe)
    if toe(i)==1
        t(i) = toe(i)*2^(i-1);
    else 
        t(i) = toe(i);
    end
end
toe = sum(t)*(2^4);

% Cic (16* bits) subframe(3)
Cic = subframe(61:76,2);
Cic_original = Cic;
for i=1:length(Cic)
    if Cic(1,1)==1
        if Cic(i) == 1
        Cic(i) = 0;
        else Cic(i) = 1;
        end
        
    else Cic(:)= Cic(:);
    end
end
Cic = flipud(Cic);
t = zeros(length(Cic),1)';
for i =1:length(Cic)
    if Cic(i)==1
        t(i) = Cic(i)*2^(i-1);
    else 
        t(i) = Cic(i);
    end
end
% applying the MSB rule (firt 8(the first half) multiple with the scale) 
% LSB means (the last half of the bits muliple with the scale)
if Cic_original(1,1)==1
    Cic = -[t(1:8)*(2^(-29)) t(9:16)];
    Cic = sum(Cic);
else Cic = [t(1:8)*(2^(-29)) t(9:16)];
    Cic = sum(Cic);
end
%% Read from RINEX file
fileNav = fopen([pwd '/INSA33601.10n']);
% structure of SV 
SV(1:37) = struct(...
                        'navData', ...
                                struct(...
                                    'year',0,...                            % [year]
                                    'month',0,...                           % [month]
                                    'day',0,...                             % [day]    
                                    'hour',0,...                            % [h]
                                    'minute',0,...                          % [min]
                                    'second',0,...                          % [sec]
                                    'af0',0,...                             % [sec]
                                    'af1',0,...                             % [sec/sec]    
                                    'af2',0,...                             % [sec/sec^2]
                                    'IODE',0,...                            % [-]
                                    'Crs',0,...                             % [m]
                                    'DeltaN',0,...                          % [rad/sec]
                                    'M0',0,...                              % [rad]
                                    'Cuc',0,...                             % [rad]
                                    'e',0,...                               % [eccentricity]
                                    'Cus',0,...                             % [rad]
                                    'sqrtA',0,...                           % [rad]
                                    'TOE',0,...                             % [sec of GPS week], time of ephemeris
                                    'Cic',0,...                             % [rad]
                                    'OMEGA0',0,...                          % [rad]
                                    'Cis',0,...                             % [rad]
                                    'i0',0,...                              % [rad]
                                    'Crc',0,...                             % [m]
                                    'omega',0,...                           % [rad]
                                    'OMEGA_DOT',0,...                       % [rad/sec]
                                    'IDOT',0,...                            % [rad]
                                    'CodesOnL2Channel',0,...                % [m]
                                    'GPSWeek',0,...                         % [-]
                                    'GPSWeek2',0,...                        % [-]
                                    'SVaccuracy',0,...                      %
                                    'SVhealth',0,...                        %
                                    'TGD',0,...                             % [sec], time group delay
                                    'IODCIssueOfData',0,...                 %
                                    'TransmissionTimeOfMessage',0,...       % [sec]
                                    'Spare1',0,...                          %
                                    'Spare2',0,...                          %
                                    'Spare3',0,...
                                    'Ek',0, ...
                                    'Ek_dot',0),...
                        'obs',zeros(3600, 10),...                           % [year, month, day, hour, minute, second, C1[m], L1[cycle], D1[Hz], SN1[dBHz]]   
                        'POSITION',zeros(3600,3));                          % [X[m], Y[m], Z[m]], ECEF coordinates 
                    

numEpochs = 0;
% reading the navigation message file
[SV] = readNav(SV, fileNav);

GPSWeek_RINEX = SV(21).navData.GPSWeek;
Toe_RINEX = SV(21).navData.TOE;
Cic_RINEX = SV(21).navData.Cic;