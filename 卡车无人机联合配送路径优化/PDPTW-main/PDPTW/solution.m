classdef Solution
    properties
    end

    methods
        function obj = Solution(problem, routes, served, notServed)
            % Auto-converted constructor skeleton
        end

        function res = computeDistance(obj)
            % Auto-converted method skeleton from solution.py:28
            res = [];
        end

        function res = computeDistanceWithNoise(obj, max_arc_dist, noise, randomGen)
            % Auto-converted method skeleton from solution.py:37
            res = [];
        end

        function obj = calculateMaxArc(obj)
            % Auto-converted method skeleton from solution.py:59
        end

        function obj = print(obj)
            % Auto-converted method skeleton from solution.py:70
        end

        function obj = executeRandomRemoval(obj, nRemove, randomGen)
            % Auto-converted method skeleton from solution.py:83
        end

        function obj = removeRequest(obj, request)
            % Auto-converted method skeleton from solution.py:111
        end

        function obj = addRequest(obj, request, insertRoute, prevNode_index, afterNode_index)
            % Auto-converted method skeleton from solution.py:127
        end

        function copyObj = copy(obj)
            % Auto-converted method skeleton from solution.py:153
            copyObj = [];
        end

        function obj = executeRandomInsertion(obj, randomGen)
            % Auto-converted method skeleton from solution.py:165
        end

    end
end
