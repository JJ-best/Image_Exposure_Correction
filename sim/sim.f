// testbench
test_IEC_top.v

// sram behavior model
sram_model/sram_256x3b.v
sram_model/sram_256x8b.v
sram_model/sram_512x8b.v
sram_model/sram_256x16b.v
sram_model/sram_64x16b_16bank.v
sram_model/twiddle_rom.v
// top module 
../hdl/IEC_top.v
// fft
../submodule/fft/hdl/fft.v
../submodule/fft/hdl/bpe.v
// int2fp
../submodule/int2fp/hdl/int2fp.v
// fp64_recip
../submodule/fp64_recip/hdl/fp64_recip.v
../submodule/fp64_recip/hdl/LUT7.v
// mul
../submodule/mul/hdl/mul.v
../submodule/mul/hdl/mul16_array_ntt.v
../submodule/mul/hdl/mul16_array.v
../submodule/mul/hdl/mul_64.v
../submodule/mul/hdl/mul_53.v
../submodule/mul/hdl/mul_16.v
../submodule/mul/hdl/butterfly.v
../submodule/mul/hdl/fp_add.v
../submodule/mul/hdl/fmul_exp.v
../submodule/mul/hdl/fmul_rounder.v
../submodule/mul/hdl/wallace_131.v
../submodule/mul/hdl/LOD_128.v
../submodule/mul/hdl/LOD_64.v
../submodule/mul/hdl/CLA33.v
../submodule/mul/hdl/CLA17.v
../submodule/mul/hdl/CLA_8.v
../submodule/mul/hdl/add_107.v
../submodule/mul/hdl/add_58.v
../submodule/mul/hdl/add_54.v
../submodule/mul/hdl/add_53_overflow.v
../submodule/mul/hdl/add_53.v
../submodule/mul/hdl/add_13_overflow.v
../submodule/mul/hdl/add_13.v
../submodule/mul/hdl/add_12_overflow.v
../submodule/mul/hdl/add_11_overflow.v
../submodule/mul/hdl/sub_107.v
../submodule/mul/hdl/sub_58.v
../submodule/mul/hdl/sub_13.v
../submodule/mul/hdl/sub_12.v
../submodule/mul/hdl/mont_add.v
../submodule/mul/hdl/mont_sub.v
../submodule/mul/hdl/FA.v
../submodule/mul/hdl/HA.v



