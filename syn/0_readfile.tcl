set TOP_DIR $TOPLEVEL
set RPT_DIR report
set NET_DIR netlist

sh rm -rf ./$TOP_DIR
sh rm -rf ./$RPT_DIR
sh rm -rf ./$NET_DIR
sh mkdir ./$TOP_DIR
sh mkdir ./$RPT_DIR
sh mkdir ./$NET_DIR

# Define a lib path
define_design_lib $TOPLEVEL -path ./$TOPLEVEL

# Add your hdl files here
set HDL_DIR_top "../hdl"
set HDL_DIR_delT "../sub_module/delT/hdl"
set HDL_DIR_fft "../sub_module/fft/hdl"
set HDL_DIR_fp2int "../sub_module/fp2int/hdl"
set HDL_DIR_fp64_recip  "../sub_module/fp64_recip/hdl"
set HDL_DIR_int2fp "../sub_module/int2fp/hdl"
set HDL_DIR_mul "../sub_module/mul/hdl"


analyze -library $TOPLEVEL -format verilog [list \
    $HDL_DIR_top/IEC_top.v \
    $HDL_DIR_mul/mul.v \
    $HDL_DIR_mul/mul16_array_ntt.v \
    $HDL_DIR_mul/mul16_array.v \
    $HDL_DIR_mul/mul_64.v \
    $HDL_DIR_mul/mul_53.v \
    $HDL_DIR_mul/mul_16.v \
    $HDL_DIR_mul/butterfly.v \
    $HDL_DIR_mul/fp_add.v \
    $HDL_DIR_mul/fmul_exp.v \
    $HDL_DIR_mul/fmul_rounder.v \
    $HDL_DIR_mul/wallace_131.v \
    $HDL_DIR_mul/LOD_128.v \
    $HDL_DIR_mul/LOD_64.v \
    $HDL_DIR_mul/CLA33.v \
    $HDL_DIR_mul/CLA17.v \
    $HDL_DIR_mul/CLA_8.v \
    $HDL_DIR_mul/add_107.v \
    $HDL_DIR_mul/add_58.v \
    $HDL_DIR_mul/add_54.v \
    $HDL_DIR_mul/add_53_overflow.v \
    $HDL_DIR_mul/add_53.v \
    $HDL_DIR_mul/add_13_overflow.v \
    $HDL_DIR_mul/add_13.v \
    $HDL_DIR_mul/add_12_overflow.v \
    $HDL_DIR_mul/add_11_overflow.v \
    $HDL_DIR_mul/sub_107.v \
    $HDL_DIR_mul/sub_58.v \
    $HDL_DIR_mul/sub_13.v \
    $HDL_DIR_mul/sub_12.v \
    $HDL_DIR_mul/mont_add.v \
    $HDL_DIR_mul/mont_sub.v \
    $HDL_DIR_mul/FA.v \
    $HDL_DIR_mul/HA.v \
    $HDL_DIR_delT/delT.v \
    $HDL_DIR_fft/fft.v \
    $HDL_DIR_fft/bpe.v \
    $HDL_DIR_fp2int/fp2int.v \
    $HDL_DIR_fp64_recip/fp64_recip.v \
    $HDL_DIR_fp64_recip/LUT7.v \
    $HDL_DIR_int2fp/int2fp.v \
]

# Elaborate your design
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

# Solve multiple instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

# Link the design
current_design $TOPLEVEL
link
