classdef Solution
    properties
    end

    methods
        function obj = Solution(problem, truck_route, served_by_truck, served_by_drone, notServed)
            % Auto-converted constructor skeleton
        end

        function res = computeDistanceAndTime(obj)
            % Auto-converted method skeleton from solution.py:32
            res = [];
        end

        function res = computeTotalCost(obj)
            % Auto-converted method skeleton from solution.py:54
            res = [];
        end

        function obj = removeRequest(obj, request)
            % Auto-converted method skeleton from solution.py:103
        end

        function obj = optimize_truck_route(obj)
            % Auto-converted method skeleton from solution.py:135
        end

        function obj = insert_into_truck(obj, request)
            % Auto-converted method skeleton from solution.py:142
        end

        function obj = assign_to_drone(obj, request)
            % Auto-converted method skeleton from solution.py:165
        end

        function copyObj = copy(obj)
            % Auto-converted method skeleton from solution.py:250
            copyObj = [];
        end

    end
end
