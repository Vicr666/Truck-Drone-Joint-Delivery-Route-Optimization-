function loc = location(requestID, xLoc, yLoc, demand, startTW, endTW, servTime, servStartTime, typeLoc, nodeID)
% MATLAB conversion of Location class
loc.requestID = requestID;
loc.xLoc = xLoc;
loc.yLoc = yLoc;
loc.demand = demand;
loc.startTW = startTW;
loc.endTW = endTW;
loc.servTime = servTime;
loc.servStartTime = servStartTime;
loc.typeLoc = typeLoc;
loc.nodeID = nodeID;
end

function d = getDistance(l1, l2)
dx = l1.xLoc - l2.xLoc;
dy = l1.yLoc - l2.yLoc;
d = round(sqrt(dx^2 + dy^2));
end
