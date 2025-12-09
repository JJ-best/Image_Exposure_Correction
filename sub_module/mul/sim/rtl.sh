#vcs tb.v accumulator.v -full64 -R -debug_access+all +v2k +neg_tchk

vcs \
    ./mul_tb.v \
    -y ../hdl +libext+.v \
    -full64 -R -debug_access+all +v2k +neg_tchk
