function result = truck_uav_alns_main(dataFile)
cfg = default_config();
if nargin < 1
    dataFile = fullfile(fileparts(mfilename('fullpath')), '..', 'ALNS', 'data.csv');
end

rng(cfg.randomSeed);
problem = load_problem(dataFile, cfg);
solution = init_solution(problem);

while ~isempty(solution.notServed)
    reqID = solution.notServed(randi(numel(solution.notServed)));
    if rand < 0.5
        [solution, assigned] = assign_to_drone(solution, problem, reqID);
        if assigned
            continue;
        end
    end
    [solution, inserted] = insert_into_truck(solution, problem, reqID);
    if inserted
        continue;
    end
    [solution, assigned] = assign_to_drone(solution, problem, reqID);
    if ~assigned
        solution.notServed(solution.notServed == reqID) = [];
    end
end

params.nIterations = cfg.alns.nIterations;
params.minSizeNBH = cfg.alns.minSizeNBH;
params.maxPercentageNBH = cfg.alns.maxPercentageNBH;
params.tau = cfg.alns.tau;
params.coolingRate = cfg.alns.coolingRate;
params.decayParameter = cfg.alns.decayParameter;
params.improvementWeightFactor = cfg.alns.improvementWeightFactor;
params.nonImprovementWeightFactor = cfg.alns.nonImprovementWeightFactor;
params.wDestroy = ones(1, 3);
params.wRepair = ones(1, 3);
params.destroyUseTimes = zeros(1, 3);
params.repairUseTimes = zeros(1, 3);
params.destroyScore = ones(1, 3);
params.repairScore = ones(1, 3);
params.w1 = 1.5;
params.w3 = 0.8;
params.w4 = 0.6;

result = alns_optimize(solution, problem, params);
print_result(result.bestSolution, problem);
end

function cfg = default_config()
cfg.randomSeed = 42;
cfg.alns.nIterations = 500;
cfg.alns.minSizeNBH = 1;
cfg.alns.maxPercentageNBH = 5;
cfg.alns.tau = 0.03;
cfg.alns.coolingRate = 0.999;
cfg.alns.decayParameter = 0.15;
cfg.alns.improvementWeightFactor = 1.0;
cfg.alns.nonImprovementWeightFactor = 0.5;
cfg.drone.drone_id = 1;
cfg.drone.max_range = 10000;
cfg.drone.speed = 80;
cfg.drone.capacity = 1;
cfg.cost.drone_launch_recovery_time = 0.5;
cfg.cost.truck_transport_cost = 5;
cfg.cost.drone_transport_cost = 1;
cfg.cost.truck_waiting_cost = 1;
cfg.cost.drone_waiting_cost = 1;
cfg.cost.drone_reward_per_task = 30;
cfg.constraint.max_drone_launch_pickup_distance = 15;
cfg.destroy.random_removal_fraction = 0.8;
cfg.truck_speed = 60;
end

function problem = load_problem(dataFile, cfg)
t = readtable(dataFile);

depot = make_location(t(1, :), 0);
locations = depot;
requests = struct('ID', {}, 'pickupID', {}, 'deliveryID', {}, 'demand', {});

for i = 2:height(t)
    nodeID = t{i, 'CUST NO.'};
    demand = t{i, 'DEMAND'};
    delivery = make_location(t(i, :), 2);
    delivery.requestID = nodeID;
    delivery.demand = demand;
    locations(end + 1) = delivery; %#ok<AGROW>

    requests(end + 1).ID = nodeID; %#ok<AGROW>
    requests(end).pickupID = depot.nodeID;
    requests(end).deliveryID = nodeID;
    requests(end).demand = demand;
end

nodeIDs = [locations.nodeID];
N = numel(nodeIDs);
distMatrix = zeros(N, N);
for i = 1:N
    for j = 1:N
        dx = locations(i).x - locations(j).x;
        dy = locations(i).y - locations(j).y;
        distMatrix(i, j) = hypot(dx, dy);
    end
end

problem.locations = locations;
problem.requests = requests;
problem.nodeIDs = nodeIDs;
problem.distMatrix = distMatrix;
problem.depotID = depot.nodeID;
problem.drone_launch_recovery_time = cfg.cost.drone_launch_recovery_time;
problem.truck_transport_cost = cfg.cost.truck_transport_cost;
problem.drone_transport_cost = cfg.cost.drone_transport_cost;
problem.truck_waiting_cost = cfg.cost.truck_waiting_cost;
problem.drone_waiting_cost = cfg.cost.drone_waiting_cost;
problem.drone_reward_per_task = cfg.cost.drone_reward_per_task;
problem.max_drone_launch_pickup_distance = cfg.constraint.max_drone_launch_pickup_distance;
problem.random_removal_fraction = cfg.destroy.random_removal_fraction;
problem.truck_speed = cfg.truck_speed;
problem.drones = cfg.drone;
end

function loc = make_location(row, typeLoc)
loc.nodeID = row{1, 'CUST NO.'};
loc.typeLoc = typeLoc;
loc.x = row{1, 'XCOORD.'};
loc.y = row{1, 'YCOORD.'};
loc.demand = row{1, 'DEMAND'};
loc.requestID = [];
loc.service_time = 0.5;
end

function solution = init_solution(problem)
solution.truckRoute.locations = [problem.depotID, problem.depotID];
solution.truckRoute.requestIDs = [];
solution.servedByTruck = [];
solution.servedByDrone = [];
solution.notServed = [problem.requests.ID];
solution.droneTasks = struct('launch_node', {}, 'pickup_node', {}, 'recovery_node', {}, 'drone_id', {}, 'launch_time', {}, 'recovery_time', {});

for i = 1:numel(problem.drones)
    solution.droneStates(i).drone = problem.drones(i); %#ok<AGROW>
    solution.droneStates(i).current_range = problem.drones(i).max_range;
    solution.droneStates(i).available_time = 0;
end

solution = recompute_solution(solution, problem);
end

function result = alns_optimize(initialSolution, problem, params)
current = initialSolution;
best = initialSolution;

number_of_request = numel(problem.requests);
maxSizeNBH = max(1, floor(params.maxPercentageNBH / 100 * number_of_request));
T = find_starting_temperature(params.tau, best.distance);

for i = 1:params.nIterations
    destroyOpNr = roulette_select(params.wDestroy);
    repairOpNr = roulette_select(params.wRepair);
    params.destroyUseTimes(destroyOpNr) = params.destroyUseTimes(destroyOpNr) + 1;
    params.repairUseTimes(repairOpNr) = params.repairUseTimes(repairOpNr) + 1;
    sizeNBH = randi([params.minSizeNBH, maxSizeNBH]);

    candidate = current;
    candidate = destroy_step(candidate, problem, destroyOpNr, sizeNBH);
    candidate = repair_step(candidate, problem, repairOpNr);

    repaired_cost = candidate.total_cost;
    improvement = false;

    if repaired_cost < best.total_cost
        improvement = true;
        best = candidate;
        current = candidate;
        params.destroyScore(destroyOpNr) = params.destroyScore(destroyOpNr) + params.w1;
        params.repairScore(repairOpNr) = params.repairScore(repairOpNr) + params.w1;
    else
        if T > 0
            acceptance_prob = exp(-(repaired_cost - current.total_cost) / T);
        else
            acceptance_prob = 0;
        end

        if rand < acceptance_prob
            current = candidate;
            params.destroyScore(destroyOpNr) = params.destroyScore(destroyOpNr) + params.w3;
            params.repairScore(repairOpNr) = params.repairScore(repairOpNr) + params.w3;
        else
            params.destroyScore(destroyOpNr) = params.destroyScore(destroyOpNr) + params.w4;
            params.repairScore(repairOpNr) = params.repairScore(repairOpNr) + params.w4;
        end
    end

    if improvement
        weightFactor = params.improvementWeightFactor;
    else
        weightFactor = params.nonImprovementWeightFactor;
    end
    destroyPerformance = params.destroyScore(destroyOpNr) / max(1, params.destroyUseTimes(destroyOpNr));
    repairPerformance = params.repairScore(repairOpNr) / max(1, params.repairUseTimes(repairOpNr));
    params.wDestroy(destroyOpNr) = (1 - params.decayParameter) * params.wDestroy(destroyOpNr) + params.decayParameter * destroyPerformance * weightFactor;
    params.wRepair(repairOpNr) = (1 - params.decayParameter) * params.wRepair(repairOpNr) + params.decayParameter * repairPerformance * weightFactor;
    T = T * params.coolingRate;
end

result.bestSolution = best;
result.currentSolution = current;
end

function T = find_starting_temperature(startTempControlParam, starting_distance)
delta = startTempControlParam * max(starting_distance, 1e-6);
T = -delta / log(0.5);
end

function op = roulette_select(weights)
cumw = cumsum(weights);
r = rand * cumw(end);
op = find(r <= cumw, 1, 'first');
end

function solution = destroy_step(solution, problem, destroyOpNr, sizeNBH)
served = unique([solution.servedByTruck, solution.servedByDrone]);
if isempty(served)
    return;
end

switch destroyOpNr
    case 1
        remove_size = min(sizeNBH, max(1, floor(problem.random_removal_fraction * numel(served))));
        removed = served(randperm(numel(served), remove_size));
    case 2
        [~, idx] = sort(arrayfun(@(id) depot_distance(problem, id), served), 'descend');
        removed = served(idx(1:min(sizeNBH, numel(served))));
    otherwise
        focal = served(randi(numel(served)));
        d = arrayfun(@(id) node_distance(problem, focal, id), served);
        [~, idx] = sort(d, 'ascend');
        removed = served(idx(1:min(sizeNBH, numel(served))));
end

for k = 1:numel(removed)
    solution = remove_request(solution, problem, removed(k));
end
solution = recompute_solution(solution, problem);
end

function solution = repair_step(solution, problem, repairOpNr)
if isempty(solution.notServed)
    return;
end

pending = solution.notServed;
switch repairOpNr
    case 1
        pending = pending(randperm(numel(pending)));
    case 2
        [~, idx] = sort(arrayfun(@(id) request_demand(problem, id), pending), 'descend');
        pending = pending(idx);
    otherwise
        truckNodes = solution.truckRoute.locations;
        nearest = zeros(size(pending));
        for i = 1:numel(pending)
            nearest(i) = min(arrayfun(@(n) node_distance(problem, n, pending(i)), truckNodes));
        end
        [~, idx] = sort(nearest, 'ascend');
        pending = pending(idx);
end

for i = 1:numel(pending)
    reqID = pending(i);
    if ismember(reqID, solution.servedByTruck) || ismember(reqID, solution.servedByDrone)
        continue;
    end
    [solution, assigned] = assign_to_drone(solution, problem, reqID);
    if assigned
        continue;
    end
    [solution, inserted] = insert_into_truck(solution, problem, reqID);
    if ~inserted
        [solution, assigned] = assign_to_drone(solution, problem, reqID);
        if ~assigned
            solution.notServed(solution.notServed == reqID) = [];
        end
    end
end
solution = recompute_solution(solution, problem);
end

function [solution, inserted] = insert_into_truck(solution, problem, reqID)
inserted = false;
if ismember(reqID, solution.servedByDrone)
    return;
end

bestCost = inf;
bestRoute = [];
route = solution.truckRoute.locations;
for i = 2:numel(route)
    candidate = [route(1:i-1), reqID, route(i:end)];
    addCost = route_distance(problem, candidate) - route_distance(problem, route);
    if addCost < bestCost
        bestCost = addCost;
        bestRoute = candidate;
    end
end

if ~isempty(bestRoute)
    solution.truckRoute.locations = bestRoute;
    solution.truckRoute.requestIDs = unique([solution.truckRoute.requestIDs, reqID]);
    solution.servedByTruck = unique([solution.servedByTruck, reqID]);
    solution.notServed(solution.notServed == reqID) = [];
    inserted = true;
    solution = recompute_solution(solution, problem);
end
end

function [solution, assigned] = assign_to_drone(solution, problem, reqID)
assigned = false;
if ismember(reqID, solution.servedByTruck)
    return;
end

route = solution.truckRoute.locations;
for i = 1:(numel(route) - 1)
    launch_node = route(i);
    recovery_node = route(i + 1);
    if launch_node == recovery_node
        continue;
    end

    distance_launch_to_pickup = node_distance(problem, launch_node, reqID);
    if distance_launch_to_pickup > problem.max_drone_launch_pickup_distance
        continue;
    end

    for d = 1:numel(solution.droneStates)
        drone = solution.droneStates(d).drone;
        if request_demand(problem, reqID) > drone.capacity
            continue;
        end

        distance_pickup_to_recovery = node_distance(problem, reqID, recovery_node);
        total_distance = distance_launch_to_pickup + distance_pickup_to_recovery;
        if total_distance > solution.droneStates(d).current_range
            continue;
        end

        truckTimes = route_start_service_times(problem, route);
        launch_time = truckTimes(i);
        flight_time = total_distance / drone.speed;
        recovery_time = launch_time + flight_time + problem.drone_launch_recovery_time;

        if launch_time < solution.droneStates(d).available_time
            continue;
        end
        if any(arrayfun(@(task) task.pickup_node == reqID, solution.droneTasks))
            continue;
        end

        t.launch_node = launch_node;
        t.pickup_node = reqID;
        t.recovery_node = recovery_node;
        t.drone_id = drone.drone_id;
        t.launch_time = launch_time;
        t.recovery_time = recovery_time;

        solution.droneTasks(end + 1) = t; %#ok<AGROW>
        solution.servedByDrone = unique([solution.servedByDrone, reqID]);
        solution.notServed(solution.notServed == reqID) = [];
        solution.droneStates(d).current_range = solution.droneStates(d).current_range - total_distance;
        solution.droneStates(d).available_time = recovery_time;
        assigned = true;
        solution = recompute_solution(solution, problem);
        return;
    end
end
end

function solution = remove_request(solution, problem, reqID)
removed_from_truck = ismember(reqID, solution.servedByTruck);
if removed_from_truck
    solution.servedByTruck(solution.servedByTruck == reqID) = [];
    solution.truckRoute.requestIDs(solution.truckRoute.requestIDs == reqID) = [];
    locs = solution.truckRoute.locations;
    locs(locs == reqID) = [];
    if locs(end) ~= problem.depotID
        locs(end + 1) = problem.depotID;
    end
    if isempty(locs)
        locs = [problem.depotID, problem.depotID];
    end
    solution.truckRoute.locations = locs;
end

if ismember(reqID, solution.servedByDrone)
    solution.servedByDrone(solution.servedByDrone == reqID) = [];
    keep = true(1, numel(solution.droneTasks));
    current_truck_nodes = solution.truckRoute.locations;
    for i = 1:numel(solution.droneTasks)
        pickup_match = solution.droneTasks(i).pickup_node == reqID;
        launch_invalid = removed_from_truck && ~ismember(solution.droneTasks(i).launch_node, current_truck_nodes);
        recovery_invalid = removed_from_truck && ~ismember(solution.droneTasks(i).recovery_node, current_truck_nodes);
        if pickup_match || launch_invalid || recovery_invalid
            keep(i) = false;
        end
    end
    solution.droneTasks = solution.droneTasks(keep);
end

if ~ismember(reqID, solution.notServed)
    solution.notServed(end + 1) = reqID;
end
solution = recompute_solution(solution, problem);
end

function solution = recompute_solution(solution, problem)
route = solution.truckRoute.locations;
solution.truckRoute.distance = route_distance(problem, route);
solution.truckRoute.start_service_times = route_start_service_times(problem, route);
solution.truckRoute.arrival_times = route_arrival_times(problem, route);
solution.truckRoute.service_time = route_service_time(problem, route);

truck_distance = solution.truckRoute.distance;
total_distance = truck_distance;
truck_time = solution.truckRoute.start_service_times(end) + solution.truckRoute.service_time;
for i = 1:numel(solution.droneTasks)
    task = solution.droneTasks(i);
    d = node_distance(problem, task.launch_node, task.pickup_node) + node_distance(problem, task.pickup_node, task.recovery_node);
    total_distance = total_distance + d;
    task_drone = get_drone(problem, task.drone_id);
    total_time = task.launch_time + d / task_drone.speed + problem.drone_launch_recovery_time;
    truck_time = max(truck_time, total_time);
end

solution.distance = total_distance;
solution.time = truck_time;
solution.total_cost = compute_total_cost(solution, problem);
end

function total_cost = compute_total_cost(solution, problem)
truck_transport_cost = solution.truckRoute.distance * problem.truck_transport_cost;
drone_transport_cost = 0;
for i = 1:numel(solution.droneTasks)
    task = solution.droneTasks(i);
    d = node_distance(problem, task.launch_node, task.pickup_node) + node_distance(problem, task.pickup_node, task.recovery_node);
    drone_transport_cost = drone_transport_cost + d * problem.drone_transport_cost;
end

drone_reward = problem.drone_reward_per_task * numel(solution.droneTasks);

truck_waiting_cost = 0;
drone_waiting_cost = 0;
truckNodes = solution.truckRoute.locations;
arrivals = solution.truckRoute.arrival_times;
for i = 1:numel(solution.droneTasks)
    task = solution.droneTasks(i);
    idx = find(truckNodes == task.recovery_node, 1, 'first');
    if isempty(idx)
        continue;
    end
    waiting_time = arrivals(idx) - task.recovery_time;
    if waiting_time > 0
        drone_waiting_cost = drone_waiting_cost + abs(waiting_time) * problem.drone_waiting_cost;
    else
        truck_waiting_cost = truck_waiting_cost + abs(waiting_time) * problem.truck_waiting_cost;
    end
end

total_cost = truck_transport_cost + drone_transport_cost + truck_waiting_cost + drone_waiting_cost - drone_reward;
end

function d = route_distance(problem, route)
d = 0;
for i = 2:numel(route)
    d = d + node_distance(problem, route(i - 1), route(i));
end
end

function t = route_service_time(problem, route)
t = 0;
for i = 1:numel(route)
    loc = get_location(problem, route(i));
    if loc.typeLoc == 2
        t = t + loc.service_time;
    end
end
end

function arr = route_arrival_times(problem, route)
arr = zeros(1, numel(route));
current_time = 0;
for i = 2:numel(route)
    travel_time = node_distance(problem, route(i - 1), route(i)) / problem.truck_speed;
    arrival_time = current_time + travel_time;
    arr(i) = arrival_time;
    loc = get_location(problem, route(i));
    if loc.typeLoc == 2
        current_time = arrival_time + loc.service_time;
    else
        current_time = arrival_time;
    end
end
end

function st = route_start_service_times(problem, route)
st = route_arrival_times(problem, route);
end

function d = node_distance(problem, fromID, toID)
i = find(problem.nodeIDs == fromID, 1, 'first');
j = find(problem.nodeIDs == toID, 1, 'first');
d = problem.distMatrix(i, j);
end

function d = depot_distance(problem, reqID)
d = node_distance(problem, problem.depotID, reqID);
end

function q = request_demand(problem, reqID)
idx = find([problem.requests.ID] == reqID, 1, 'first');
q = problem.requests(idx).demand;
end

function loc = get_location(problem, nodeID)
idx = find(problem.nodeIDs == nodeID, 1, 'first');
loc = problem.locations(idx);
end

function drone = get_drone(problem, drone_id)
idx = find([problem.drones.drone_id] == drone_id, 1, 'first');
if isempty(idx)
    idx = 1;
end
drone = problem.drones(idx);
end

function print_result(solution, problem)
fprintf('\n===== MATLAB ALNS 结果 =====\n');
fprintf('最佳总成本: %.2f\n', solution.total_cost);
fprintf('总距离: %.2f\n', solution.distance);
fprintf('总时间: %.2f\n', solution.time);
fprintf('卡车服务节点数: %d\n', numel(solution.servedByTruck));
fprintf('无人机服务节点数: %d\n', numel(solution.droneTasks));
fprintf('卡车路线: %s\n', mat2str(solution.truckRoute.locations));

figure('Name', 'Truck-UAV Route');
hold on; grid on;
route = solution.truckRoute.locations;
truckXY = arrayfun(@(id) [get_location(problem, id).x, get_location(problem, id).y], route, 'UniformOutput', false);
truckXY = vertcat(truckXY{:});
plot(truckXY(:, 1), truckXY(:, 2), 'b-o', 'DisplayName', '卡车路线');

for i = 1:numel(solution.droneTasks)
    task = solution.droneTasks(i);
    a = get_location(problem, task.launch_node);
    b = get_location(problem, task.pickup_node);
    c = get_location(problem, task.recovery_node);
    plot([a.x b.x c.x], [a.y b.y c.y], 'r--o', 'HandleVisibility', 'off');
end
legend('show');
title('配送路线图 (MATLAB)');
xlabel('X 坐标'); ylabel('Y 坐标');
hold off;
end
