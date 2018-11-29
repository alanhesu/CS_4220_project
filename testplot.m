close all;
clear;

% file names
%%%%%%%%%%%%
% Parameters to set
wl = 5000; % Workload
topology = '3311'; 
numNodes = 8; % Total number of nodes = #Apache + #Tomcat + #CJDBC + #MySQL
isRW = 1; % Use RW or RO results
impath = 'Figures/5000wl-6/'; % MAKE SURE YOU CHANGE THIS!!! Filepath to save images to
%%%%%%%%%%%%

if isRW
	pname = sprintf('output-%s/%d-RW/', topology, wl);
else
	pname = sprintf('output-%s/%d-RO/', topology, wl);
end
mkdir(impath);
fnames = dir(pname);
for i = 1:length(fnames)
	if ~isempty(strfind(fnames(i).name, 'Apache_multiplicity'))
		apachename = fnames(i).name;
	end
	if ~isempty(strfind(fnames(i).name, 'Tomcat_multiplicity'))
		tomcatname = fnames(i).name;
	end
	if ~isempty(strfind(fnames(i).name, 'CJDBC_multiplicity'))
		cjdbcname = fnames(i).name;
	end
	if ~isempty(strfind(fnames(i).name, 'Mysql_multiplicity'))
		mysqlname = fnames(i).name;
	end
end

% response time
bounds = dlmread([pname, 'exp_time.csv'], ' ');
num = csvread([pname, 'Pointintime.csv'], 1, 0);
x = num(:,1)/1000;
t = x(x >= bounds(1) & x <= bounds(2));
y = num(:,2);
pit = y(x >= bounds(1) & x <= bounds(2));

figs(1) = figure;
plot(t,pit);
xlabel('Time (s)');
ylabel('Response time (ms)');
title('Point in time response time');
set(gca, 'FontSize', 18);

[ux, uy] = ginput(1);
ux = [ux, ux + 10];
figs(2) = figure;
plot(t(t >= ux(1) & t <= ux(2)),pit(t >= ux(1) & t <= ux(2)));
xlabel('Time (s)');
ylabel('Response time (ms)');
title('Point in time response time');
set(gca, 'FontSize', 18);
saveas(figs(2), [impath, 'Responsetime.png']);

peakstarts = [];

% queue lengths
% Apache
num = readtable([pname, apachename]);
x = num.date_time;
t_apache = x(x >= bounds(1) & x <= bounds(2));
y = num.http_adjustLoad;
ql_apache = y(x >= bounds(1) & x <= bounds(2));

figs(3) = figure;
subplot(4,1,1);
plot(x(x >= ux(1) & x <= ux(2)),y(x >= ux(1) & x <= ux(2)));
ppoints = findPeak(t_apache(t_apache >= ux(1) & t_apache <= ux(2)), ql_apache(t_apache >= ux(1) & t_apache <= ux(2)));
peakstart(1) = ppoints(1);


% Tomcat
num = readtable([pname, tomcatname]);
x = num.date_time;
t_tomcat = x(x >= bounds(1) & x <= bounds(2));
y = num.http_adjustLoad;
ql_tomcat = y(x >= bounds(1) & x <= bounds(2));

subplot(4,1,2);
plot(x(x >= ux(1) & x <= ux(2)),y(x >= ux(1) & x <= ux(2)));
ppoints = findPeak(t_tomcat(t_tomcat >= ux(1) & t_tomcat <= ux(2)), ql_tomcat(t_tomcat >= ux(1) & t_tomcat <= ux(2)));
peakstart(2) = ppoints(1);

% CJDBC
num = readtable([pname, cjdbcname]);
x = num.date_time;
t_cjdbc = x(x >= bounds(1) & x <= bounds(2));
y = num.http_adjustLoad;
ql_cjdbc = y(x >= bounds(1) & x <= bounds(2));

subplot(4,1,3);
plot(x(x >= ux(1) & x <= ux(2)),y(x >= ux(1) & x <= ux(2)));
ppoints = findPeak(t_cjdbc(t_cjdbc >= ux(1) & t_cjdbc <= ux(2)), ql_cjdbc(t_cjdbc >= ux(1) & t_cjdbc <= ux(2)));
peakstart(3) = ppoints(1);

% dxt = gradient(y(x >= ux(1) & x <= ux(2)), x(2) - x(1));
% subplot(4,1,4);
% plot(x(x >= ux(1) & x <= ux(2)), dxt);

% hold on;
% points = findPeak(x(x >= ux(1) & x <= ux(2)),y(x >= ux(1) & x <= ux(2)));
% plot(points,zeros(1,length(points)));

% Mysql
num = readtable([pname, mysqlname]);
x = num.date_time;
t_mysql = x(x >= bounds(1) & x <= bounds(2));
y = num.http_adjustLoad;
ql_mysql = y(x >= bounds(1) & x <= bounds(2));

subplot(4,1,4);
plot(x(x >= ux(1) & x <= ux(2)),y(x >= ux(1) & x <= ux(2)));
suplabel(sprintf('Queue lengths for Apache, Tomcat, CJDBC, and MySQL from %0.3f to %0.3f', ux(1), ux(2)), 't');
suplabel('Time (s)', 'x');
suplabel('Queue length (#)', 'y');

ppoints = findPeak(t_mysql(t_mysql >= ux(1) & t_mysql <= ux(2)), ql_mysql(t_mysql >= ux(1) & t_mysql <= ux(2)));
peakstart(4) = ppoints(1);
saveas(figs(3), [impath, 'QLseparate.png']);

% Compare queue lengths
figs(4) = figure;
plot(t_apache(t_apache >= ux(1) & t_apache <= ux(2)), ql_apache(t_apache >= ux(1) & t_apache <= ux(2)));
hold on;
plot(t_tomcat(t_tomcat >= ux(1) & t_tomcat <= ux(2)), ql_tomcat(t_tomcat >= ux(1) & t_tomcat <= ux(2)));
plot(t_cjdbc(t_cjdbc >= ux(1) & t_cjdbc <= ux(2)), ql_cjdbc(t_cjdbc >= ux(1) & t_cjdbc <= ux(2)));
plot(t_mysql(t_mysql >= ux(1) & t_mysql <= ux(2)), ql_mysql(t_mysql >= ux(1) & t_mysql <= ux(2)));
xlabel('Time (s)');
ylabel('Queue length (#)');
title('Queue lengths at each tier');
legend('Apache', 'Tomcat', 'CJDBC', 'MySQL');
set(gca, 'FontSize', 18);
saveas(figs(4), [impath, 'QLoverlay.png']);

% Average CPU utilization
% For 4-4-1-2, Apache = node7-10, Tomcat = node11-14, CJDBC = node15, Mysql
% = node16-17
num = readtable([pname, 'by_node_rsrc_util.csv'], 'Delimiter', '|');
num = num(num.transform_timestamp >= ux(1) & num.transform_timestamp <= ux(2),:);
t = num.transform_timestamp;

utils = [];
avgutils = [];
figs(5) = figure;
for i = 1:numNodes
	colName1 = sprintf('node%d_CPU_0_Idle_PCT', i+6);
	colName2 = sprintf('node%d_CPU_1_Idle_PCT', i+6);
	utils = [utils, table2array(num(:,strcmp(num.Properties.VariableNames, colName1)))];
	utils = [utils, table2array(num(:,strcmp(num.Properties.VariableNames, colName2)))];
	
	subplot(6,2,i);
	avg = mean(utils(:,i*2-1:i*2), 2);
	tMod = t(~isnan(avg));
	avgMod = avg(~isnan(avg));
	avgutils(:,i*2-1) = tMod;
	avgutils(:,i*2) = 100-avgMod;
	plot(tMod, 100-avgMod);
	title(sprintf('Node %d', i+6));
	ylim([0,100]);
end
suplabel('Average CPU utilization', 't');
suplabel('Time (s)', 'x');
suplabel('%', 'y');
saveas(figs(5), [impath, 'CPUseparate.png']);

% Average disk utilization
disk = [];
avgdisk = [];
figs(6) = figure;
for i = 1:numNodes
	colName1 = sprintf('node%d_DSK_sda_Util', i+6);
	colName2 = sprintf('node%d_DSK_sdb_Util', i+6);
	disk = [disk, table2array(num(:,strcmp(num.Properties.VariableNames, colName1)))];
	disk = [disk, table2array(num(:,strcmp(num.Properties.VariableNames, colName2)))];
	
	subplot(6,2,i);	
	if i < numNodes
		avg = mean(disk(:,i*2-1:i*2), 2);	
	else
		avg = mean(disk(:,i*2-1), 2);
	end
	tMod = t(~isnan(avg));
	avgMod = avg(~isnan(avg));
	avgdisk(:,i*2-1) = tMod;
	avgdisk(:,i*2) = avgMod;
	plot(tMod, avgMod);
	title(sprintf('Node %d', i+6));
	ylim([0,100]);
end
suplabel('Average Disk utilization', 't');
suplabel('Time (s)', 'x');
suplabel('%', 'y');
saveas(figs(6), [impath, 'Diskseparate.png']);

% Overlay plots

% Compare CPU utilization
numapache = str2num(topology(1));
numtomcat = str2num(topology(2));
numcjdbc = str2num(topology(3));
nummysql = str2num(topology(4)); %'NUMMY'

figs(7) = figure;
overlayAvgUtil(numapache, avgutils(:,1:numapache*2), 'Apache CPU');
saveas(figs(7), [impath, 'CPUApache.png']);
figs(8) = figure;
overlayAvgUtil(numtomcat, avgutils(:,numapache*2+1:(numapache+numtomcat)*2), 'Tomcat CPU');
saveas(figs(8), [impath, 'CPUTomcat.png']);
figs(9) = figure;
overlayAvgUtil(numcjdbc, avgutils(:,(numapache+numtomcat)*2+1:(numapache+numtomcat+numcjdbc)*2), 'CJDBC CPU');
saveas(figs(9), [impath, 'CPUCJDBC.png']);
figs(10) = figure;
overlayAvgUtil(nummysql, avgutils(:,(numapache+numtomcat+numcjdbc)*2+1:end), 'MySQL CPU');
saveas(figs(10), [impath, 'CPUMySQL.png']);

% Compare Disk utilization
figs(11) = figure;
overlayAvgUtil(numapache, avgdisk(:,1:numapache*2), 'Apache disk');
saveas(figs(11), [impath, 'DiskApache.png']);
figs(12) = figure;
overlayAvgUtil(numtomcat, avgdisk(:,numapache*2+1:(numapache+numtomcat)*2), 'Tomcat disk');
saveas(figs(12), [impath, 'DiskTomcat.png']);
figs(13) = figure;
overlayAvgUtil(numcjdbc, avgdisk(:,(numapache+numtomcat)*2+1:(numapache+numtomcat+numcjdbc)*2), 'CJDBC disk');
saveas(figs(13), [impath, 'DiskCJDBC.png']);
figs(14) = figure;
overlayAvgUtil(nummysql, avgdisk(:,(numapache+numtomcat+numcjdbc)*2+1:end), 'MySQL disk');
saveas(figs(14), [impath, 'DiskMySQL.png']);