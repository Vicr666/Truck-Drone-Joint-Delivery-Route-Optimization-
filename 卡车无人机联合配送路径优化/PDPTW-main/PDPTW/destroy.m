classdef Destroy
    properties
    end

    methods
        function obj = Destroy(problem, solution)
            % Auto-converted constructor skeleton
        end

        function res = findWorstCostRequest(obj)
            % Auto-converted method skeleton from destroy.py:24
            res = [];
        end

        function res = findWorstTimeRequest(obj)
            % Auto-converted method skeleton from destroy.py:47
            res = [];
        end

        function res = findRandomRoute(obj, randomGen)
            % Auto-converted method skeleton from destroy.py:68
            res = [];
        end

        function res = findWorstCostRequestRandomRoute(obj, randomGen)
            % Auto-converted method skeleton from destroy.py:82
            res = [];
        end

        function res = findStartingLocationShaw(obj, randomGen)
            % Auto-converted method skeleton from destroy.py:105
            res = [];
        end

        function res = findNextShawRequest(obj)
            % Auto-converted method skeleton from destroy.py:122
            res = [];
        end

        function res = findNextProximityBasedRequest(obj)
            % Auto-converted method skeleton from destroy.py:179
            res = [];
        end

        function res = findNextTimeBasedRequest(obj)
            % Auto-converted method skeleton from destroy.py:204
            res = [];
        end

        function res = findNextDemandBasedRequest(obj)
            % Auto-converted method skeleton from destroy.py:228
            res = [];
        end

        function res = findWorstNeighborhoodRequest(obj)
            % Auto-converted method skeleton from destroy.py:252
            res = [];
        end

        function obj = executeRandomRemoval(obj, nRemove, randomGen)
            % Auto-converted method skeleton from destroy.py:285
        end

        function obj = executeWorstCostRemoval(obj, nRemove)
            % Auto-converted method skeleton from destroy.py:300
        end

        function obj = executeWorstTimeRemoval(obj, nRemove)
            % Auto-converted method skeleton from destroy.py:314
        end

        function obj = executeRandomRouteRemoval(obj, nRemove, randomGen)
            % Auto-converted method skeleton from destroy.py:329
        end

        function obj = executeShawRequestRemoval(obj, nRemove, randomGen)
            % Auto-converted method skeleton from destroy.py:343
        end

        function obj = executeProximityBasedRemoval(obj, nRemove, randomGen)
            % Auto-converted method skeleton from destroy.py:371
        end

        function obj = executeTimeBasedRemoval(obj, nRemove, randomGen)
            % Auto-converted method skeleton from destroy.py:399
        end

        function obj = executeDemandBasedRemoval(obj, nRemove, randomGen)
            % Auto-converted method skeleton from destroy.py:427
        end

        function obj = executeWorstNeighborhoodRemoval(obj, nRemove)
            % Auto-converted method skeleton from destroy.py:455
        end

    end
end
