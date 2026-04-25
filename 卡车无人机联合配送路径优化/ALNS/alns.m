classdef ALNS
    properties
        problem
        nDestroyOps
        nRepairOps
        nIterations
        minSizeNBH
        maxPercentageNHB
        tau
        coolingRate
        decayParameter
        noise
    end

    methods
        function obj = ALNS(problem, nDestroyOps, nRepairOps, nIterations, minSizeNBH, maxPercentageNHB, tau, coolingRate, decayParameter, noise)
            obj.problem = problem;
            obj.nDestroyOps = nDestroyOps;
            obj.nRepairOps = nRepairOps;
            obj.nIterations = nIterations;
            obj.minSizeNBH = minSizeNBH;
            obj.maxPercentageNHB = maxPercentageNHB;
            obj.tau = tau;
            obj.coolingRate = coolingRate;
            obj.decayParameter = decayParameter;
            obj.noise = noise;
        end

        function result = execute(~, dataFile)
            if nargin < 2
                result = truck_uav_alns_main();
            else
                result = truck_uav_alns_main(dataFile);
            end
        end
    end
end
