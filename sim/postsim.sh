# # Layer10: POSTSIM
    vcs -R +v2k -full64 -f postsim.f -debug_access+all -l postsim.log \
    +define+ALM_Tout \
    +define+INIT_EN=0 \
    +define+PAT=1 \
    +define+ITER=0 \
    +define+POSTSIM \
    +define+FLAG_VERBOSE=1 \
    +define+FLAG_DUMPWV=1 \
    +define+END_CYCLES=2000000000 \
    +define+TOLERANCE=10 \
    +define+PATCH_I=0 \
    +define+PATCH_J=0 \
     # +define+ALL_PATCH=1 \