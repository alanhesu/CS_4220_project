close all;
clear;

% response time
wl = 1000;
path = sprintf('output-4412-%dwl/%d-RW/', wl, wl);
bounds = dlmread([path, 'exp_time.csv'], ' ');
num = csvread([path, 'Pointintime.csv'], 1, 0);
x = num(:,1)/1000;
t = x(x >= bounds(1) & x <= bounds(2));
y = num(:,2);
pit = y(x >= bounds(1) & x <= bounds(2));

figure;
scatter(t,pit,'.');
xlabel('Time (s)');
ylabel('Response time (s)');
title('Point in time response time');
set(gca, 'FontSize', 18);

[ux, uy] = ginput(2);
figure;
scatter(t(t >= ux(1) & t <= ux(2)),pit(t >= ux(1) & t <= ux(2)),'.');
xlabel('Time (s)');
ylabel('Response time (s)');
title(sprintf('Point in time response time from %0.3f to %0.3f', ux(1), ux(2)));
set(gca, 'FontSize', 18);

% queue lengths
% Apache
num = readtable([path, '20181031172415-173051_Apache_multiplicity_wl1000RW-50ms.csv']);
x = num.date_time;
t_apache = x(x >= bounds(1) & x <= bounds(2));
y = num.http_adjustLoad;
ql_apache = y(x >= bounds(1) & x <= bounds(2));

figure;
subplot(4,1,1);
scatter(x(x >= ux(1) & x <= ux(2)),y(x >= ux(1) & x <= ux(2)),'.');

% Tomcat
num = readtable([path, '20181031172415-173051_Tomcat_multiplicity_wl1000RW-50ms.csv']);
x = num.date_time;
t_tomcat = x(x >= bounds(1) & x <= bounds(2));
y = num.http_adjustLoad;
ql_tomcat = y(x >= bounds(1) & x <= bounds(2));

subplot(4,1,2);
scatter(x(x >= ux(1) & x <= ux(2)),y(x >= ux(1) & x <= ux(2)),'.');

% CJDBC
num = readtable([path, '20181031172415-173051_CJDBC_multiplicity_wl1000RW-50ms.csv']);
x = num.date_time;
t_cjdbc = x(x >= bounds(1) & x <= bounds(2));
y = num.http_adjustLoad;
ql_cjdbc = y(x >= bounds(1) & x <= bounds(2));

subplot(4,1,3);
scatter(x(x >= ux(1) & x <= ux(2)),y(x >= ux(1) & x <= ux(2)),'.');

% Mysql
num = readtable([path, '20181031172415-173051_Mysql_multiplicity_wl1000RW-50ms.csv']);
x = num.date_time;
t_mysql = x(x >= bounds(1) & x <= bounds(2));
y = num.http_adjustLoad;
ql_mysql = y(x >= bounds(1) & x <= bounds(2));

subplot(4,1,4);
scatter(x(x >= ux(1) & x <= ux(2)),y(x >= ux(1) & x <= ux(2)),'.');
suplabel(sprintf('Queue lengths for Apache, Tomcat, CJDBC, and MySQL from %0.3f to %0.3f', ux(1), ux(2)), 't');
suplabel('Time (s)', 'x');
suplabel('Queue time (s)', 'y');

% Average CPU utilization
% For 4-4-1-2, Apache = node7-10, Tomcat = node11-14, CJDBC = node15, Mysql
% = node16-17
num = readtable([path, 'by_node_rsrc_util.csv'], 'Delimiter', '|');
num = num(num.transform_timestamp >= ux(1) & num.transform_timestamp <= ux(2),:);
t = num.transform_timestamp;
utils = [];

figure;
for i = 1:10
	colName1 = sprintf('node%d_CPU_0_Idle_PCT', i+7);
	colName2 = sprintf('node%d_CPU_1_Idle_PCT', i+7);
	utils = [utils, table2array(num(:,strcmp(num.Properties.VariableNames, colName1)))];
	utils = [utils, table2array(num(:,strcmp(num.Properties.VariableNames, colName2)))];
	
	subplot(5,2,i);
	avg = mean(utils(:,i*2-1:i*2), 2);
	tMod = t(~isnan(avg));
	avgMod = avg(~isnan(avg));
	scatter(tMod, avgMod, '.');
	title(sprintf('Node %d', i+7));
end
suplabel('Average CPU utilization', 't');
suplabel('Time (s)', 'x');
suplabel('%', 'y');

% Average disk utilization
utils = [];
figure;
for i = 1:10
	colName1 = sprintf('node%d_DSK_sda_Util', i+7);
	colName2 = sprintf('node%d_DSK_sdb_Util', i+7);
	utils = [utils, table2array(num(:,strcmp(num.Properties.VariableNames, colName1)))];
	utils = [utils, table2array(num(:,strcmp(num.Properties.VariableNames, colName2)))];
	
	subplot(5,2,i);
	avg = mean(utils(:,i*2-1:i*2), 2);
	tMod = t(~isnan(avg));
	avgMod = avg(~isnan(avg));
	scatter(tMod, avgMod, '.');
	title(sprintf('Node %d', i+7));
end
suplabel('Average Disk utilization', 't');
suplabel('Time (s)', 'x');
suplabel('%', 'y');