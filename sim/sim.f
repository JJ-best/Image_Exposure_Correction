// testbench
test_IEC_top.v

// sram behavior model
sram_model/sram_256x3b.v
sram_model/sram_256x8b.v
sram_model/sram_512x8b.v
sram_model/sram_256x16b.v
sram_model/sram_64x16b_16bank.v

// module 
../hdl/IEC_top.v

// sub modules
../sub_module/int2fp/hdl/int2fp.v
../sub_module/mul/hdl/mul.v
../sub_module/mul/hdl/mul16_array.v
../sub_module/mul/hdl/mul16_array_ntt.v
../sub_module/mul/hdl/wallace_131.v
../sub_module/mul/hdl/fmul_exp.v
../sub_module/mul/hdl/fmul_rounder.v
../sub_module/mul/hdl/fp_add.v
../sub_module/mul/hdl/add_107.v
../sub_module/mul/hdl/add_11_overflow.v
../sub_module/mul/hdl/add_12_overflow.v
../sub_module/mul/hdl/add_13_overflow.v
../sub_module/mul/hdl/add_13.v
../sub_module/mul/hdl/add_53_overflow.v
../sub_module/mul/hdl/add_53.v
../sub_module/mul/hdl/add_54.v
../sub_module/mul/hdl/add_58.v
../sub_module/mul/hdl/butterfly.v
../sub_module/mul/hdl/CLA17.v
../sub_module/mul/hdl/CLA33.v
../sub_module/mul/hdl/CLA_8.v
../sub_module/mul/hdl/FA.v
../sub_module/mul/hdl/HA.v
../sub_module/mul/hdl/LOD_128.v
../sub_module/mul/hdl/LOD_64.v
../sub_module/mul/hdl/mont_add.v
../sub_module/mul/hdl/mont_sub.v
../sub_module/mul/hdl/mul_16.v
../sub_module/mul/hdl/mul_53.v
../sub_module/mul/hdl/mul_64.v
../sub_module/mul/hdl/sub_107.v
../sub_module/mul/hdl/sub_12.v
../sub_module/mul/hdl/sub_13.v
../sub_module/mul/hdl/sub_58.v

