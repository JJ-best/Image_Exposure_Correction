// testbench
test_delT.v

// sram behavior model
../../../sim/sram_model/sram_512x8b.v
../../../sim/sram_model/sram_256x16b.v
../../../sim/sram_model/sram_64x16b_16bank.v

// module 
../hdl/delT.v
// mul and fp_add modules (used by adder)
../../mul/hdl/add_107.v
../../mul/hdl/add_11_overflow.v
../../mul/hdl/add_12_overflow.v
../../mul/hdl/add_13_overflow.v
../../mul/hdl/add_13.v
../../mul/hdl/add_53_overflow.v
../../mul/hdl/add_53.v
../../mul/hdl/add_54.v
../../mul/hdl/add_58.v
../../mul/hdl/butterfly.v
../../mul/hdl/CLA17.v
../../mul/hdl/CLA33.v
../../mul/hdl/CLA_8.v
../../mul/hdl/FA.v
../../mul/hdl/fmul_exp.v
../../mul/hdl/fmul_rounder.v
../../mul/hdl/fp_add.v
../../mul/hdl/HA.v
../../mul/hdl/LOD_128.v
../../mul/hdl/LOD_64.v
../../mul/hdl/mont_add.v
../../mul/hdl/mont_sub.v
../../mul/hdl/mul16_array_ntt.v
../../mul/hdl/mul16_array.v
../../mul/hdl/mul_16.v
../../mul/hdl/mul_53.v
../../mul/hdl/mul_64.v
../../mul/hdl/mul.v
../../mul/hdl/sub_107.v
../../mul/hdl/sub_12.v
../../mul/hdl/sub_13.v
../../mul/hdl/sub_58.v
../../mul/hdl/wallace_131.v
