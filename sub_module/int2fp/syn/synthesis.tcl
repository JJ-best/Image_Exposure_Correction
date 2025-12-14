# Multi-core for fast synthesis
set CORES 16
set_host_options -max_cores $CORES
report_host_options

# set your TOPLEVEL here
set TOPLEVEL "int2fp"

# change your timing constraint here
set TEST_CYCLE 3
source -echo -verbose 0_readfile.tcl 
source -echo -verbose 1_setting.tcl 
source -echo -verbose 2_compile.tcl 
source -echo -verbose 3_report.tcl 

exit
