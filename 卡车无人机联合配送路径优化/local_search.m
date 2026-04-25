classdef local_search
    properties
        solution
    end

    methods
        function obj = local_search(solution)
            obj.solution = solution;
        end

        function obj = two_opt(obj)
            improved = true;
            while improved
                improved = false;
                route = obj.solution.truckRoute.locations;
                best_distance = obj.solution.truckRoute.distance;
                for i = 2:(numel(route)-2)
                    for j = (i+1):(numel(route)-1)
                        if j - i == 1
                            continue;
                        end
                        new_route = [route(1:i-1), fliplr(route(i:j-1)), route(j:end)];
                        temp_route = obj.solution.makeRoute(new_route, obj.solution.servedByTruck);
                        if temp_route.distance < best_distance && temp_route.feasible
                            obj.solution.truckRoute = temp_route;
                            obj.solution.distance = temp_route.distance;
                            obj.solution.totalCost = obj.solution.computeTotalCost();
                            improved = true;
                            best_distance = temp_route.distance;
                        end
                    end
                end
            end
        end

        function obj = three_opt(obj)
            improved = true;
            while improved
                improved = false;
                route = obj.solution.truckRoute.locations;
                best_distance = obj.solution.truckRoute.distance;
                n = numel(route);
                for i = 2:(n-2)
                    for j = (i+1):(n-1)
                        for k = (j+1):n
                            new_route = obj.three_opt_swap(route, i, j, k);
                            temp_route = obj.solution.makeRoute(new_route, obj.solution.servedByTruck);
                            if temp_route.distance < best_distance && temp_route.feasible
                                obj.solution.truckRoute = temp_route;
                                obj.solution.distance = temp_route.distance;
                                obj.solution.totalCost = obj.solution.computeTotalCost();
                                improved = true;
                                best_distance = temp_route.distance;
                            end
                        end
                    end
                end
            end
        end

        function new_route = three_opt_swap(~, route, i, j, k)
            new_route = [route(1:i-1), route(j:k-1), route(i:j-1), route(k:end)];
        end
    end
end
