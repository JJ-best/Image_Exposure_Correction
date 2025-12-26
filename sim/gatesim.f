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
../syn/netlist/IEC_top_syn.v

-v /usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/verilog/slow_vdd1v2_basicCells.v

+define+GATESIM
+maxdelays
+neg_tchk
