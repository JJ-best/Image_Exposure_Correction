module IEC_top #(
    parameter BW_PER_ADDR_A = 24,
    parameter BW_PER_ADDR_B = 64,
    parameter ADDR_WIDTH_A = 8,
    parameter ADDR_WIDTH_B = 8,
    parameter alpha = 64'h3fb47ae147ae147b, // alpha = 0.08
    parameter mu0 = 64'h3f847ae147ae147b,   // mu0 = 0.01
    parameter rho = 64'h3ff3333333333333,   // rho = 1.2
    parameter gamma = 64'h3fe999999999999a, // gamma = 0.8
    parameter k0 = 8'd50                    // iteration time
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

// ===== top state ===== //
localparam IDLE = 7'd0;
localparam R_SRAMA = 7'd1;


reg [6:0] top_state;
reg [6:0] top_state_n;

// ===== init illumination map ===== //
// read original RGB data(3-byte) from SRAM-A

// find max{R,G,B} * 255^-1 and store into SRAM-B
// find (1-min{R,G,B}) * 255^-1 and store into SRAM-C

// read SRAM-A --> find max and min --> write into SRAM-B and SRAM-C 
// --> read SRAM-C --> 1-min --> write SRAM-C

// Memory Size
// SRAM-A: 32x32x3x1-byte
// SRAM-B: 32x32x1x8-byte
// SRAM-C: 32x32x1x8-byte
// Each SRAM has 4-bank, please refer to readme file


endmodule