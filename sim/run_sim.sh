#!/bin/bash
# PAT: imgs_lime1 -> 1;  imgs_lime1 -> 2
# PATCH_I, PATCH_J: patch_PATCH_I_PATCH_J_over/under.bmp
# INIT_EN: Initialize mode -> 1; hardware mode -> 0
# ITER: iteration number for ALM layers (3-14)
#       ITER=0 -> iter_000, ITER=1 -> iter_001, ITER=2 -> iter_002
#       ITER=3 -> iter003, ITER=4 -> 004, ITER=10 -> iter010, ITER=20 -> iter20, ITER=29 -> iter29
# TOLERANCE: Floating point comparison tolerance for layer 3-14 (default: 4e-3)
#            Example: +define+TOLERANCE=1e-6 for stricter comparison


# Layer1: input_image #
#  vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer1.log \
#      +define+INPUT \
#      +define+PAT=1 \
#      +define+PATCH_I=20 \
#      +define+PATCH_J=20 \
#      +define+FLAG_VERBOSE=1 \
#      +define+FLAG_DUMPWV=1 \
#      +define+END_CYCLES=5000

# # # Layer2: initial_illum_map #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer2.log \
#     +define+INIT \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=30000

# # # Layer3: ALM_U #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer3.log \
#     +define+ALM_U \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=1 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=50000

# Layer4: W_DENOM #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer4.log \
#     +define+W_DENOM \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=1 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=100000

# # # # Layer5: ALM_delG #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer5.log \
#     +define+ALM_delG \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=20 \
#     +define+PATCH_J=20 \
#     +define+ITER=1 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=100000

# # Layer6: ALM_Tnum # check SRAME_1.dat
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer6.log \
#     +define+ALM_Tnum \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=1 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=70000

# # # Layer7: ALM_Tn # check SRAMT_1.dat
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer7.log \
#     +define+ALM_Tn \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=50000 \
#     +define+TOLERANCE=10

# # # Layer8: ALM_Td #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer8.log \
#     +define+ALM_Td \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=50000 \
#     +define+TOLERANCE=10

# # # Layer9: ALM_Tnd #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer9.log \
#     +define+ALM_Tnd \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=50000 \
#     +define+TOLERANCE=10

# # # Layer10: ALM_Tout # check SRAMT_2.dat
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer10.log \
#     +define+ALM_Tout \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=3 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+FSDB
#     +define+END_CYCLES=200000 \
#     +define+TOLERANCE=10 \

# # # Layer10: ALM_Tout # check SRAMT_2.dat Fast Simulation
    vcs -R +v2k -full64 -f sim.f -l vcs_layer10.log \
    +define+ALM_Tout \
    +define+INIT_EN=0 \
    +define+PAT=1 \
    +define+ITER=20 \
    +define+FLAG_VERBOSE=1 \
    +define+FLAG_DUMPWV=1 \
    +define+END_CYCLES=2000000000000 \
    +define+TOLERANCE=10 \
    +define+ALL_PATCH=1 \
    # +define+PATCH_I=0 \
    # +define+PATCH_J=2 \

# # # # Layer11: ALM_delT #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer11.log \
#     +define+ALM_delT \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=50000 \
#     +define+TOLERANCE=10

# # # Layer12: ALM_G # SRAMG_1.dat
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer12.log \
#     +define+ALM_G \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=1 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=100000

# # Layer13: ALM_Q # 
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer13.log \
#     +define+ALM_Q \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=50000 \
#     +define+TOLERANCE=10

# # Layer14: ALM_Z #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer14.log \
#     +define+ALM_Z \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+ITER=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+TOLERANCE=10 \
#     +define+END_CYCLES=50000
    