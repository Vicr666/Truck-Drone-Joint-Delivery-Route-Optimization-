function generate_data()
% MATLAB conversion of generate_data.py
rng('shuffle');
generate_loop_instance(50, 'c50.csv');
generate_loop_instance(100, 'c100.csv');
end

function generate_loop_instance(num_customers, filename)
data = struct('CUST_NO', {}, 'XCOORD', {}, 'YCOORD', {}, 'READY_TIME', {}, 'DUE_DATE', {}, 'DEMAND', {}, 'SERVICE_TIME', {});

data(1).CUST_NO = 0;
data(1).XCOORD = 100.0;
data(1).YCOORD = 0.0;
data(1).READY_TIME = 0.0;
data(1).DUE_DATE = 24.0;
data(1).DEMAND = 0;
data(1).SERVICE_TIME = 0.0;

angle_increment = 360 / num_customers;
for i = 1:num_customers
    angle_deg = 20 + angle_increment * (i - 1);
    angle_rad = deg2rad(angle_deg);
    x = 50 + 50 * cos(angle_rad);
    y = 0 + 50 * sin(angle_rad);
    ready_time = round((8.0 + (16.0-8.0)*rand()) * 10) / 10;
    due_date = round((ready_time + 1.0 + (24.0-ready_time-1.0)*rand()) * 10) / 10;
    demand = randi([2,7]);
    service_time = 0.5;

    k = i + 1;
    data(k).CUST_NO = i;
    data(k).XCOORD = round(x,2);
    data(k).YCOORD = round(y,2);
    data(k).READY_TIME = ready_time;
    data(k).DUE_DATE = due_date;
    data(k).DEMAND = demand;
    data(k).SERVICE_TIME = service_time;
end

T = struct2table(data);
T.Properties.VariableNames = {'CUST NO.','XCOORD.','YCOORD.','READY TIME','DUE DATE','DEMAND','SERVICE TIME'};
writetable(T, filename);
fprintf('算例已生成并保存为 %s
', filename);
end
