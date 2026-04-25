classdef ALNS
    properties
    end

    methods
        function obj = ALNS(problem, nDestroyOps, nRepairOps, nIterations, minSizeNBH, maxPercentageNHB, tau, coolingRate, decayParameter, noise)
            % Auto-converted constructor skeleton
        end

        function obj = printWeight(obj)
            % Auto-converted method skeleton from alns.py:67
        end

        function obj = constructInitialSolution(obj)
            % Auto-converted method skeleton from alns.py:77
        end

        function res = findStartingTemperature(obj, startTempControlParam, starting_solution)
            % Auto-converted method skeleton from alns.py:100
            res = [];
        end

        function obj = execute(obj)
            % Auto-converted method skeleton from alns.py:106
        end

        function obj = checkIfAcceptNewSol(obj)
            % Auto-converted method skeleton from alns.py:210
        end

        function obj = updateWeights(obj, destroyOpNr, repairOpNr)
            % Auto-converted method skeleton from alns.py:269
        end

        function res = determineDestroyOpNr(obj)
            % Auto-converted method skeleton from alns.py:286
            res = [];
        end

        function res = determineRepairOpNr(obj)
            % Auto-converted method skeleton from alns.py:301
            res = [];
        end

        function obj = destroyAndRepair(obj, destroyHeuristicNr, repairHeuristicNr, sizeNBH)
            % Auto-converted method skeleton from alns.py:316
        end

    end
end
