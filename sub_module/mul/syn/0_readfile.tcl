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
set HDL_DIR "../hdl"
analyze -library $TOPLEVEL -format verilog [list \
    $HDL_DIR/mul.v \
    $HDL_DIR/mul16_array_ntt.v \
    $HDL_DIR/mul16_array.v \
    $HDL_DIR/mul_64.v \
    $HDL_DIR/mul_53.v \
    $HDL_DIR/mul_16.v \
    $HDL_DIR/butterfly.v \
    $HDL_DIR/fp_add.v \
    $HDL_DIR/fmul_exp.v \
    $HDL_DIR/fmul_rounder.v \
    $HDL_DIR/wallace_131.v \
    $HDL_DIR/LOD_128.v \
    $HDL_DIR/LOD_64.v \
    $HDL_DIR/CLA33.v \
    $HDL_DIR/CLA17.v \
    $HDL_DIR/CLA_8.v \
    $HDL_DIR/add_107.v \
    $HDL_DIR/add_58.v \
    $HDL_DIR/add_54.v \
    $HDL_DIR/add_53_overflow.v \
    $HDL_DIR/add_53.v \
    $HDL_DIR/add_13_overflow.v \
    $HDL_DIR/add_13.v \
    $HDL_DIR/add_12_overflow.v \
    $HDL_DIR/add_11_overflow.v \
    $HDL_DIR/sub_107.v \
    $HDL_DIR/sub_58.v \
    $HDL_DIR/sub_13.v \
    $HDL_DIR/sub_12.v \
    $HDL_DIR/mont_add.v \
    $HDL_DIR/mont_sub.v \
    $HDL_DIR/FA.v \
    $HDL_DIR/HA.v \
]

# Elaborate your design
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

# Solve multiple instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

# Link the design
current_design $TOPLEVEL
link
