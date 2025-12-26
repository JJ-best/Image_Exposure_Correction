# # Layer10: GATESIM
    vcs -R +v2k -full64 -f gatesim.f -debug_access+all -l vcs_layer10.log \
    +define+ALM_Tout \
    +define+INIT_EN=0 \
    +define+PAT=1 \
    +define+ITER=20 \
    +define+GATESIM \
    +define+FLAG_VERBOSE=1 \
    +define+FLAG_DUMPWV=1 \
    +define+END_CYCLES=2000000000000 \
    +define+TOLERANCE=10 \
    +define+PATCH_I=0 \
    +define+PATCH_J=2 \
     # +define+ALL_PATCH=1 \