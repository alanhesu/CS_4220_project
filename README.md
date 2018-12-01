# CS_4220_project
Elba standard project

# Usage
testplot.m is the script that generates the relevant graphs.
Set the parameters in the top section:
- wl (workload)
- topology (####, where each number represents the number of Apache, Tomcat, CJDBC, and MySQL nodes)
- numNodes (this should equal the sum of each digit in the topology)
- isRW (set to 1 to use RW or 0 to use RO data)
- impath (filepath to save images to. This will automatically get overwritten, so make sure it is changed if you want to generate a new set of graphs)

Make sure the main directory structure for the experiment is labeled 'output-{topology}', which should contain folders for each workload titled '{topology}-RW' or '{topology}-RO'. For example, Pointintime.csv for a 1000 RW workload experiment at 1-1-1-1 topology should be in 'output-1111/1000-RW/Pointintime.csv'.

After running, select a point in the point-in-time response time graph. This marks the start of the 10-second window that will be captured in all subsequent plots:
- Response time
- Queue lengths at each tier
- Average CPU utilization for each node and tier
- Average disk utilization for each node and tier