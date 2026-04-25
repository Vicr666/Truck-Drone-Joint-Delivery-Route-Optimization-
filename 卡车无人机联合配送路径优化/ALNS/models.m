function model = models()
% MATLAB conversion helper for ALNS/models.py
model.Location = @(nodeID,typeLoc,x,y,demand,requestID,service_time) struct('nodeID',nodeID,'typeLoc',typeLoc,'x',x,'y',y,'demand',demand,'requestID',requestID,'service_time',service_time);
model.Request = @(ID,pickUpLoc,deliveryLoc,demand) struct('ID',ID,'pickUpLoc',pickUpLoc,'deliveryLoc',deliveryLoc,'demand',demand);
model.Drone = @(drone_id,max_range,speed,capacity) struct('drone_id',drone_id,'max_range',max_range,'speed',speed,'capacity',capacity,'current_range',max_range,'available_time',0.0);
model.DroneTask = @(launch_node,pickup_node,recovery_node,drone_id,launch_time,recovery_time) struct('launch_node',launch_node,'pickup_node',pickup_node,'recovery_node',recovery_node,'drone_id',drone_id,'launch_time',launch_time,'recovery_time',recovery_time,'waiting_time',0.0);
end
