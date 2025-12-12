#!/bin/bash
# PAT: imgs_lime1 -> 1;  imgs_lime1 -> 2
# PATCH_I, PATCH_J: patch_PATCH_I_PATCH_J_over/under.bmp
# INIT_EN: Initialize mode -> 1; hardware mode -> 0
# Layer0: input_image #
#  vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer0.log \
#      +define+INPUT \
#      +define+PAT=1 \
#      +define+PATCH_I=20 \
#      +define+PATCH_J=20 \
#      +define+FLAG_VERBOSE=1 \
#      +define+FLAG_DUMPWV=1 \
#      +define+END_CYCLES=5000

# # Layer1: initial_illum_map #
vcs -R +v2k -full64 -f sim.f -debug_acc+all -l vcs_layer1.log \
    +define+INIT \
    +define+INIT_EN=0 \
    +define+PAT=1 \
    +define+PATCH_I=20 \
    +define+PATCH_J=20 \
    +define+FLAG_VERBOSE=1 \
    +define+FLAG_DUMPWV=1 \
    +define+END_CYCLES=5000
