function result = main(instanceFile)
% MATLAB conversion entry for PDPTW/main.py
if nargin < 1
    instanceFile = 'Instances/lrc104.txt';
end
problem = pdptw_readInstance(instanceFile);
solver = ALNS(problem, 3, 3, 2800, 1, 5, 0.03, 0.9990, 0.15, 0.015);
result = solver.execute();
end
