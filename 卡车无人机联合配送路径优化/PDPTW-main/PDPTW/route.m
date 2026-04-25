classdef Route
    properties
    end

    methods
        function obj = Route(locations, requests, problem)
            % Auto-converted constructor skeleton
        end

        function obj = calculateServiceStartTime(obj)
            % Auto-converted method skeleton from route.py:32
        end

        function res = computeDistance(obj)
            % Auto-converted method skeleton from route.py:41
            res = [];
        end

        function res = computeDiff(obj, preNode, afterNode, insertNode)
            % Auto-converted method skeleton from route.py:55
            res = [];
        end

        function res = compute_cost_add_one_request(obj, preNode_index, afterNode_index, request)
            % Auto-converted method skeleton from route.py:69
            res = [];
        end

        function obj = print(obj)
            % Auto-converted method skeleton from route.py:82
        end

        function res = isFeasible(obj)
            % Auto-converted method skeleton from route.py:91
            res = [];
        end

        function obj = removeRequest(obj, request)
            % Auto-converted method skeleton from route.py:135
        end

        function obj = addRequest(obj, request, preNode_index, afterNode_index)
            % Auto-converted method skeleton from route.py:149
        end

        function copyObj = copy(obj)
            % Auto-converted method skeleton from route.py:171
            copyObj = [];
        end

        function obj = greedyInsert(obj, request)
            % Auto-converted method skeleton from route.py:179
        end

    end
end
