function result = main(dataFile)
% MATLAB conversion entry for ALNS/main.py
if nargin < 1
    result = truck_uav_alns_main();
else
    result = truck_uav_alns_main(dataFile);
end
end
