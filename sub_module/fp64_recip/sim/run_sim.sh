vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_recip.log \
+memcbk \
+define+PAT_L=0+define+PAT_U=2999 \
+define+FLAG_VERBOSE=1 \
+define+FLAG_DUMPWV=1 \
+define+END_CYCLES=100000 

### Notice1: set FLAG_VERBOSE to 1 for detailed simulation reports
### Notice2: set FLAG_DUMPWV to 1 for dumping the fsdb waveform
