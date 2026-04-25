function problem = pdptw(name, requests, depot, vehicleCapacity)
% MATLAB conversion of PDPTW class constructor
problem.name = name;
problem.requests = requests;
problem.depot = depot;
problem.capacity = vehicleCapacity;

locations = depot;
for i = 1:numel(requests)
    locations(end+1) = requests(i).pickUpLoc; %#ok<AGROW>
    locations(end+1) = requests(i).deliveryLoc; %#ok<AGROW>
end
problem.locations = locations;

n = numel(locations);
problem.distMatrix = zeros(n,n);
for i = 1:n
    for j = 1:n
        problem.distMatrix(locations(i).nodeID+1, locations(j).nodeID+1) = round(hypot(locations(i).xLoc - locations(j).xLoc, locations(i).yLoc - locations(j).yLoc));
    end
end
end

function problem = pdptw_readInstance(fileName)
% MATLAB conversion of PDPTW.readInstance
fid = fopen(fileName, 'r');
if fid < 0
    error('Cannot open instance file: %s', fileName);
end
C = textscan(fid, '%s', 'Delimiter', '
');
fclose(fid);
lines = C{1};

requests = struct('pickUpLoc', {}, 'deliveryLoc', {}, 'ID', {});
unmatchedPickups = containers.Map('KeyType','char','ValueType','any');
unmatchedDeliveries = containers.Map('KeyType','char','ValueType','any');
nodeCount = 0;
requestCount = 1;
servStartTime = 0;

for idx = 2:max(1, numel(lines)-6)
    line = lines{idx};
    n = 13;
    parts = cell(1, ceil(strlength(string(line))/n));
    p = 1;
    for c = 1:n:strlength(string(line))
        chunk = extractBetween(string(line), c, min(c+n-1, strlength(string(line))));
        parts{p} = strtrim(char(chunk));
        p = p + 1;
    end
    if numel(parts) < 9
        continue;
    end
    lID = parts{1};
    x = str2double(erase(parts{3}, '.0'));
    y = str2double(erase(parts{4}, '.0'));

    if startsWith(lID, 'D')
        depot = location(0, x, y, 0, 0, 0, 0, servStartTime, 0, nodeCount); %#ok<NASGU>
        nodeCount = nodeCount + 1;
    elseif startsWith(lID, 'C')
        lType = parts{2};
        demand = str2double(erase(parts{5}, '.0'));
        startTW = str2double(erase(parts{6}, '.0'));
        endTW = str2double(erase(parts{7}, '.0'));
        servTime = str2double(erase(parts{8}, '.0'));
        partnerID = parts{9};

        if strcmp(lType, 'cp')
            if isKey(unmatchedDeliveries, partnerID)
                deliv = unmatchedDeliveries(partnerID);
                remove(unmatchedDeliveries, partnerID);
                pickup = location(deliv.requestID, x, y, demand, startTW, endTW, servTime, servStartTime, 1, nodeCount);
                nodeCount = nodeCount + 1;
                req = request(pickup, deliv, deliv.requestID);
                requests(end+1) = req; %#ok<AGROW>
            else
                pickup = location(requestCount, x, y, demand, startTW, endTW, servTime, servStartTime, 1, nodeCount);
                nodeCount = nodeCount + 1;
                requestCount = requestCount + 1;
                unmatchedPickups(lID) = pickup;
            end
        elseif strcmp(lType, 'cd')
            if isKey(unmatchedPickups, partnerID)
                pickup = unmatchedPickups(partnerID);
                remove(unmatchedPickups, partnerID);
                deliv = location(pickup.requestID, x, y, demand, startTW, endTW, servTime, servStartTime, -1, nodeCount);
                nodeCount = nodeCount + 1;
                req = request(pickup, deliv, pickup.requestID);
                requests(end+1) = req; %#ok<AGROW>
            else
                deliv = location(requestCount, x, y, demand, startTW, endTW, servTime, servStartTime, -1, nodeCount);
                nodeCount = nodeCount + 1;
                requestCount = requestCount + 1;
                unmatchedDeliveries(lID) = deliv;
            end
        end
    end
end

if exist('depot','var') == 0
    error('Depot not found in instance file: %s', fileName);
end

capacity = 0;
if numel(lines) >= 4
    capLine = lines{end-3};
    if strlength(string(capLine)) >= 7
        capacity = str2double(strtrim(extractBetween(string(capLine), strlength(string(capLine))-6, strlength(string(capLine))-3)));
    end
end

problem = pdptw(fileName, requests, depot, capacity);
end
