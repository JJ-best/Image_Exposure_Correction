module IEC_top #(
    parameter BW_PER_ADDR_A = 24,
    parameter BW_PER_ADDR_B = 64,
    parameter ADDR_WIDTH_A = 8,
    parameter ADDR_WIDTH_B = 8
)(
    input clk,
    input rst_n,
    input enable, // sram initialization done, you can start from sramA fetch data
    output done,  // you are done, tb will start checking when receiving done

    // sram A     
    output sram_wen_a0, // low enable
    output sram_wen_a1,
    output sram_wen_a2,
    output sram_wen_a3,
    input [BW_PER_ADDR_A-1:0] sram_rdata_a0,
    input [BW_PER_ADDR_A-1:0] sram_rdata_a1,
    input [BW_PER_ADDR_A-1:0] sram_rdata_a2,
    input [BW_PER_ADDR_A-1:0] sram_rdata_a3,
    output [ADDR_WIDTH_A-1:0] sram_addr_a0,
    output [ADDR_WIDTH_A-1:0] sram_addr_a1,
    output [ADDR_WIDTH_A-1:0] sram_addr_a2,
    output [ADDR_WIDTH_A-1:0] sram_addr_a3,
    output [BW_PER_ADDR_A-1:0] sram_wdata_a0,
    output [BW_PER_ADDR_A-1:0] sram_wdata_a1,
    output [BW_PER_ADDR_A-1:0] sram_wdata_a2,
    output [BW_PER_ADDR_A-1:0] sram_wdata_a3,

    // sram B
    output sram_wen_b0, // low enable
    output sram_wen_b1,
    output sram_wen_b2,
    output sram_wen_b3,
    input [BW_PER_ADDR_B-1:0] sram_rdata_b0,
    input [BW_PER_ADDR_B-1:0] sram_rdata_b1,
    input [BW_PER_ADDR_B-1:0] sram_rdata_b2,
    input [BW_PER_ADDR_B-1:0] sram_rdata_b3,
    output [ADDR_WIDTH_B-1:0] sram_addr_b0,
    output [ADDR_WIDTH_B-1:0] sram_addr_b1,
    output [ADDR_WIDTH_B-1:0] sram_addr_b2,
    output [ADDR_WIDTH_B-1:0] sram_addr_b3,
    output [BW_PER_ADDR_B-1:0] sram_wdata_b0,
    output [BW_PER_ADDR_B-1:0] sram_wdata_b1,
    output [BW_PER_ADDR_B-1:0] sram_wdata_b2,
    output [BW_PER_ADDR_B-1:0] sram_wdata_b3

);

endmodule