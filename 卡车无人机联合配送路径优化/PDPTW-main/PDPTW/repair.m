classdef Repair
    properties
    end

    methods
        function obj = Repair(problem, solution)
            % Auto-converted constructor skeleton
        end

        function res = computeDiff(obj, preNode, afterNode, insertNode)
            % Auto-converted method skeleton from repair.py:25
            res = [];
        end

        function res = findRegretInsertion(obj)
            % Auto-converted method skeleton from repair.py:38
            res = [];
        end

        function obj = executeRegretInsertion(obj)
            % Auto-converted method skeleton from repair.py:112
        end

        function obj = executeGreedyInsertion(obj)
            % Auto-converted method skeleton from repair.py:128
        end

        function obj = executeRandomInsertion(obj, randomGen)
            % Auto-converted method skeleton from repair.py:168
        end

    end
end
