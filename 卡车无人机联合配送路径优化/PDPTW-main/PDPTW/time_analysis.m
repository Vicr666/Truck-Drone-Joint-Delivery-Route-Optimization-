function time_analysis(csvFile)
% MATLAB conversion of time_analysis.py
if nargin < 1
    csvFile = 'time_output.csv';
end
T = readtable(csvFile);
method = strings(height(T),1);
for i = 1:height(T)
    fn = string(T.func_name(i));
    if contains(fn, 'Insertion')
        method(i) = "Insertion";
    elseif contains(fn, 'Removal')
        method(i) = "Removal";
    else
        method(i) = fn;
    end
end
T.method = method;
repair = T(T.method == "Insertion", :);
destroy = T(T.method == "Removal", :);
disp('repair');
disp(sum(repair{:,2}));
disp('destroy');
disp(sum(destroy{:,2}));
end
