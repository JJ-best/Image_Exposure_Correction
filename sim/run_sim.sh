#!/bin/bash
# PAT: imgs_lime1 -> 1;  imgs_lime1 -> 2
# PATCH_I, PATCH_J: patch_PATCH_I_PATCH_J_over/under.bmp
# INIT_EN: Initialize mode -> 1; hardware mode -> 0


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
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=10000

# # # # Layer4: ALM_A #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer4.log \
#     +define+ALM_A \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=10000

# # # # Layer5: ALM_delG #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer5.log \
#     +define+ALM_delG \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=20 \
#     +define+PATCH_J=20 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=10000

# # Layer6: ALM_Tnum #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer6.log \
#     +define+ALM_Tnum \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=10000

# # # Layer7: ALM_Tn #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer7.log \
#     +define+ALM_Tn \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=30000

# # # Layer8: ALM_Td #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer8.log \
#     +define+ALM_Td \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=35000

# # # Layer9: ALM_Tnd #
vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer9.log \
    +define+ALM_Tnd \
    +define+INIT_EN=0 \
    +define+PAT=1 \
    +define+PATCH_I=0 \
    +define+PATCH_J=0 \
    +define+FLAG_VERBOSE=1 \
    +define+FLAG_DUMPWV=1 \
    +define+END_CYCLES=30000

# # # Layer10: ALM_Tout #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer10.log \
#     +define+ALM_Tout \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=5000

# # # Layer11: ALM_delT #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer11.log \
#     +define+ALM_delT \
#     +define+INIT_EN=0 \
#     +define+PAT=1 \
#     +define+PATCH_I=0 \
#     +define+PATCH_J=0 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=5000

# # # Layer12: ALM_G #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer12.log \
#     +define+ALM_G \
#     +define+INIT_EN=1 \
#     +define+PAT=1 \
#     +define+PATCH_I=20 \
#     +define+PATCH_J=20 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=5000

# # Layer13: ALM_Q #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer13.log \
#     +define+ALM_Q \
#     +define+INIT_EN=1 \
#     +define+PAT=1 \
#     +define+PATCH_I=20 \
#     +define+PATCH_J=20 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=5000


# # Layer14: ALM_Z #
# vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer14.log \
#     +define+ALM_Z \
#     +define+INIT_EN=1 \
#     +define+PAT=1 \
#     +define+PATCH_I=20 \
#     +define+PATCH_J=20 \
#     +define+FLAG_VERBOSE=1 \
#     +define+FLAG_DUMPWV=1 \
#     +define+END_CYCLES=5000