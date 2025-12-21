`timescale 1ns/100ps
`define PAT_L 0
`define PAT_U 1
`define NUM_PAT (`PAT_U-`PAT_L+1)

`define CYCLE 10
`define END_CYCLES 20
`define FLAG_DUMPWV 1
`define FLAG_VERBOSE 1

module test_IEC_top;

// ===== Parameters ===== //
localparam pFP_WIDTH = 64;

localparam INPUT = 5'd0;
localparam INIT = 5'd1;
localparam BW_PER_ADDR_A = 24;    // SRAM A: 24-bit per address 
localparam BW_PER_ADDR_B = 64;    // SRAM B: 64-bit per address 
localparam BW_PER_ADDR_I = 64;    // SRAM I: 64-bit per address
localparam BW_PER_ADDR_U = 64;    // SRAM U: 64-bit per address
localparam BW_PER_ADDR_W = 64;    // SRAM W: 64-bit per address
localparam BW_PER_ADDR_X = 64;    // SRAM X: 64-bit per address
localparam BW_PER_ADDR_E = 128;   // SRAM E: 128-bit per address
localparam BW_PER_ADDR_T = 128;   // SRAM T: 128-bit per address
localparam BW_PER_ADDR_C = 128;   // SRAM C: 128-bit per address
localparam BW_PER_ADDR_G = 64;    // SRAM G: 64-bit per address
localparam BW_PER_ADDR_Z = 64;    // SRAM Z: 64-bit per address


localparam SRAM_ADDR_WIDTH_A = 8;  // SRAM A: 8-bit address (256 addresses)
localparam SRAM_ADDR_WIDTH_B = 8;  // SRAM B: 8-bit address (256 addresses)
localparam SRAM_ADDR_WIDTH_I = 8;  // SRAM I: 9-bit address (512 addresses)
localparam SRAM_ADDR_WIDTH_U = 9;  // SRAM U: 9-bit address (512 addresses)
localparam SRAM_ADDR_WIDTH_W = 9;  // SRAM W: 9-bit address (512 addresses)
localparam SRAM_ADDR_WIDTH_X = 9;  // SRAM X: 9-bit address (512 addresses)
localparam SRAM_ADDR_WIDTH_E = 6;  // SRAM E: 6-bit address (64 addresses)
localparam SRAM_ADDR_WIDTH_T = 6;  // SRAM T: 6-bit address (64 addresses)
localparam SRAM_ADDR_WIDTH_C = 6;  // SRAM C: 6-bit address (64 addresses)
localparam SRAM_ADDR_WIDTH_G = 9;  // SRAM G: 9-bit address (512 addresses)
localparam SRAM_ADDR_WIDTH_Z = 9;  // SRAM Z: 9-bit address (512 addresses)

// ===== Layer selection ===== //
// +define+LAYER=1 or +define+LAYER=2 in run_sim.sh
// LAYER=1 (input_image)
// LAYER=2 (init)
integer layer_value;

// ===== Pattern selection ===== //
// +define+PAT=1 or +define+PAT=2 in run_sim.sh
// PATCH_I, PATCH_J can be set via +define+PATCH_I=0 and +define+PATCH_J=0
// Example : patch_00_00_under/over.bmp -> patch_i_value = 00, patch_j_value = 00
reg [7:0] pat_value;
integer patch_i_value;
integer patch_j_value;

// ===== Initialization selection ===== //
// Control whether to initialize the current layer's SRAM
// INIT_EN applies to the layer being tested (layer_value)
// Validation for testbench
integer init_enable;  


// ===== Settings  ===== //
initial begin
    // LAYER 
    // INPUT: input_image -> 1
    // INIT : initial_illum_map -> 2
    `ifdef INPUT
        layer_value = 1;  
    `elsif INIT
        layer_value = 2;
    `elsif ALM_U
        layer_value = 3;
    `elsif ALM_A
        layer_value = 4;
    `elsif ALM_delG
        layer_value = 5;
    `elsif ALM_Tnum
        layer_value = 6;
    `elsif ALM_Tn
        layer_value = 7;
    `elsif ALM_Td
        layer_value = 8;
    `elsif ALM_Tnd
        layer_value = 9;
    `elsif ALM_Tout
        layer_value = 10;
    `elsif ALM_delT
        layer_value = 11;
    `elsif ALM_G
        layer_value = 12;
    `elsif ALM_Q
        layer_value = 13;
    `elsif ALM_Z
        layer_value = 14;
    `endif
    
    // PAT 
    // 1 : imgs_lime1
    // 2 : imgs_lime2
    if(`PAT == 1)
        pat_value = "1";
    else if(`PAT == 2)
        pat_value = "2";
    else
        pat_value = "1";  
    
    // PATCH_I 
    `ifdef PATCH_I
        patch_i_value = `PATCH_I;
    `else
        patch_i_value = 0; 
    `endif
    
    // PATCH_J 
    `ifdef PATCH_J
        patch_j_value = `PATCH_J;
    `else
        patch_j_value = 0;  
    `endif
    
    // INIT_EN: Control whether to initialize the current layer's SRAM
    // When INIT_EN=1: Initialize mode (load data and compare)
    // When INIT_EN=0: Hardware mode (run hardware and compare)
    `ifdef INIT_EN
        init_enable = `INIT_EN;
    `else
        init_enable = 0; 
    `endif
    
    // Print setting info
    $display("Using PAT = %c (lime%c), PATCH_I = %0d, PATCH_J = %0d, INIT_EN = %0d", 
             pat_value, pat_value, patch_i_value, patch_j_value, init_enable);
end


// ===== golden data for patch verification ===== //
// For SRAM A (24-bit RGB)
reg [BW_PER_ADDR_A-1:0] golden_bank_a0 [0:255];
reg [BW_PER_ADDR_A-1:0] golden_bank_a1 [0:255];
reg [BW_PER_ADDR_A-1:0] golden_bank_a2 [0:255];
reg [BW_PER_ADDR_A-1:0] golden_bank_a3 [0:255];
// For SRAM B (fp64 single channel) 
reg [BW_PER_ADDR_B-1:0] golden_bank_b0 [0:255];
reg [BW_PER_ADDR_B-1:0] golden_bank_b1 [0:255];
reg [BW_PER_ADDR_B-1:0] golden_bank_b2 [0:255];
reg [BW_PER_ADDR_B-1:0] golden_bank_b3 [0:255];
// For SRAM U, W, X, G, Z (64-bit fp64, 512 addresses)
reg [BW_PER_ADDR_U-1:0] golden_bank_u0 [0:511];
reg [BW_PER_ADDR_U-1:0] golden_bank_u1 [0:511];
reg [BW_PER_ADDR_U-1:0] golden_bank_u2 [0:511];
reg [BW_PER_ADDR_U-1:0] golden_bank_u3 [0:511];
// For SRAM E, T, C (128-bit fp64, 64 addresses, 16 banks)
reg [BW_PER_ADDR_E-1:0] golden_bank_e0 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e1 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e2 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e3 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e4 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e5 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e6 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e7 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e8 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e9 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e10 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e11 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e12 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e13 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e14 [0:63];
reg [BW_PER_ADDR_E-1:0] golden_bank_e15 [0:63];


// ===== module I/O ===== //
reg clk;
reg rst_n;
reg enable;
wire done;

// SRAM A signals
wire sram_wen_a0;
wire sram_wen_a1;
wire sram_wen_a2;
wire sram_wen_a3;
wire [BW_PER_ADDR_A-1:0] sram_rdata_a0;
wire [BW_PER_ADDR_A-1:0] sram_rdata_a1;
wire [BW_PER_ADDR_A-1:0] sram_rdata_a2;
wire [BW_PER_ADDR_A-1:0] sram_rdata_a3;
wire [SRAM_ADDR_WIDTH_A-1:0] sram_addr_a0;
wire [SRAM_ADDR_WIDTH_A-1:0] sram_addr_a1;
wire [SRAM_ADDR_WIDTH_A-1:0] sram_addr_a2;
wire [SRAM_ADDR_WIDTH_A-1:0] sram_addr_a3;
wire [BW_PER_ADDR_A-1:0] sram_wdata_a0;
wire [BW_PER_ADDR_A-1:0] sram_wdata_a1;
wire [BW_PER_ADDR_A-1:0] sram_wdata_a2;
wire [BW_PER_ADDR_A-1:0] sram_wdata_a3;

// SRAM B signals
wire sram_wen_b0;
wire sram_wen_b1;
wire sram_wen_b2;
wire sram_wen_b3;
wire [BW_PER_ADDR_B-1:0] sram_rdata_b0;
wire [BW_PER_ADDR_B-1:0] sram_rdata_b1;
wire [BW_PER_ADDR_B-1:0] sram_rdata_b2;
wire [BW_PER_ADDR_B-1:0] sram_rdata_b3;
wire [SRAM_ADDR_WIDTH_B-1:0] sram_addr_b0;
wire [SRAM_ADDR_WIDTH_B-1:0] sram_addr_b1;
wire [SRAM_ADDR_WIDTH_B-1:0] sram_addr_b2;
wire [SRAM_ADDR_WIDTH_B-1:0] sram_addr_b3;
wire [BW_PER_ADDR_B-1:0] sram_wdata_b0;
wire [BW_PER_ADDR_B-1:0] sram_wdata_b1;
wire [BW_PER_ADDR_B-1:0] sram_wdata_b2;
wire [BW_PER_ADDR_B-1:0] sram_wdata_b3;

// SRAM I signals
wire sram_wen_i0;
wire sram_wen_i1;
wire sram_wen_i2;
wire sram_wen_i3;
wire [BW_PER_ADDR_I-1:0] sram_rdata_i0;
wire [BW_PER_ADDR_I-1:0] sram_rdata_i1;
wire [BW_PER_ADDR_I-1:0] sram_rdata_i2;
wire [BW_PER_ADDR_I-1:0] sram_rdata_i3;
wire [SRAM_ADDR_WIDTH_I-1:0] sram_addr_i0;
wire [SRAM_ADDR_WIDTH_I-1:0] sram_addr_i1;
wire [SRAM_ADDR_WIDTH_I-1:0] sram_addr_i2;
wire [SRAM_ADDR_WIDTH_I-1:0] sram_addr_i3;
wire [BW_PER_ADDR_I-1:0] sram_wdata_i0;
wire [BW_PER_ADDR_I-1:0] sram_wdata_i1;
wire [BW_PER_ADDR_I-1:0] sram_wdata_i2;
wire [BW_PER_ADDR_I-1:0] sram_wdata_i3;

// SRAM U signals
wire sram_wen_u0;
wire sram_wen_u1;
wire sram_wen_u2;
wire sram_wen_u3;
wire [BW_PER_ADDR_U-1:0] sram_rdata_u0;
wire [BW_PER_ADDR_U-1:0] sram_rdata_u1;
wire [BW_PER_ADDR_U-1:0] sram_rdata_u2;
wire [BW_PER_ADDR_U-1:0] sram_rdata_u3;
wire [SRAM_ADDR_WIDTH_U-1:0] sram_addr_u0;
wire [SRAM_ADDR_WIDTH_U-1:0] sram_addr_u1;
wire [SRAM_ADDR_WIDTH_U-1:0] sram_addr_u2;
wire [SRAM_ADDR_WIDTH_U-1:0] sram_addr_u3;
wire [BW_PER_ADDR_U-1:0] sram_wdata_u0;
wire [BW_PER_ADDR_U-1:0] sram_wdata_u1;
wire [BW_PER_ADDR_U-1:0] sram_wdata_u2;
wire [BW_PER_ADDR_U-1:0] sram_wdata_u3;

// SRAM W signals
wire sram_wen_w0;
wire sram_wen_w1;
wire sram_wen_w2;
wire sram_wen_w3;
wire [BW_PER_ADDR_W-1:0] sram_rdata_w0;
wire [BW_PER_ADDR_W-1:0] sram_rdata_w1;
wire [BW_PER_ADDR_W-1:0] sram_rdata_w2;
wire [BW_PER_ADDR_W-1:0] sram_rdata_w3;
wire [SRAM_ADDR_WIDTH_W-1:0] sram_addr_w0;
wire [SRAM_ADDR_WIDTH_W-1:0] sram_addr_w1;
wire [SRAM_ADDR_WIDTH_W-1:0] sram_addr_w2;
wire [SRAM_ADDR_WIDTH_W-1:0] sram_addr_w3;
wire [BW_PER_ADDR_W-1:0] sram_wdata_w0;
wire [BW_PER_ADDR_W-1:0] sram_wdata_w1;
wire [BW_PER_ADDR_W-1:0] sram_wdata_w2;
wire [BW_PER_ADDR_W-1:0] sram_wdata_w3;

// SRAM X signals
wire sram_wen_x0;
wire sram_wen_x1;
wire sram_wen_x2;
wire sram_wen_x3;
wire [BW_PER_ADDR_X-1:0] sram_rdata_x0;
wire [BW_PER_ADDR_X-1:0] sram_rdata_x1;
wire [BW_PER_ADDR_X-1:0] sram_rdata_x2;
wire [BW_PER_ADDR_X-1:0] sram_rdata_x3;
wire [SRAM_ADDR_WIDTH_X-1:0] sram_addr_x0;
wire [SRAM_ADDR_WIDTH_X-1:0] sram_addr_x1;
wire [SRAM_ADDR_WIDTH_X-1:0] sram_addr_x2;
wire [SRAM_ADDR_WIDTH_X-1:0] sram_addr_x3;
wire [BW_PER_ADDR_X-1:0] sram_wdata_x0;
wire [BW_PER_ADDR_X-1:0] sram_wdata_x1;
wire [BW_PER_ADDR_X-1:0] sram_wdata_x2;
wire [BW_PER_ADDR_X-1:0] sram_wdata_x3;

// SRAM E signals (16 banks)
wire sram_wen_e0, sram_wen_e1, sram_wen_e2, sram_wen_e3;
wire sram_wen_e4, sram_wen_e5, sram_wen_e6, sram_wen_e7;
wire sram_wen_e8, sram_wen_e9, sram_wen_e10, sram_wen_e11;
wire sram_wen_e12, sram_wen_e13, sram_wen_e14, sram_wen_e15;
wire [BW_PER_ADDR_E-1:0] sram_rdata_e0, sram_rdata_e1, sram_rdata_e2, sram_rdata_e3;
wire [BW_PER_ADDR_E-1:0] sram_rdata_e4, sram_rdata_e5, sram_rdata_e6, sram_rdata_e7;
wire [BW_PER_ADDR_E-1:0] sram_rdata_e8, sram_rdata_e9, sram_rdata_e10, sram_rdata_e11;
wire [BW_PER_ADDR_E-1:0] sram_rdata_e12, sram_rdata_e13, sram_rdata_e14, sram_rdata_e15;
wire [SRAM_ADDR_WIDTH_E-1:0] sram_addr_e0, sram_addr_e1, sram_addr_e2, sram_addr_e3;
wire [SRAM_ADDR_WIDTH_E-1:0] sram_addr_e4, sram_addr_e5, sram_addr_e6, sram_addr_e7;
wire [SRAM_ADDR_WIDTH_E-1:0] sram_addr_e8, sram_addr_e9, sram_addr_e10, sram_addr_e11;
wire [SRAM_ADDR_WIDTH_E-1:0] sram_addr_e12, sram_addr_e13, sram_addr_e14, sram_addr_e15;
wire [BW_PER_ADDR_E-1:0] sram_wdata_e0, sram_wdata_e1, sram_wdata_e2, sram_wdata_e3;
wire [BW_PER_ADDR_E-1:0] sram_wdata_e4, sram_wdata_e5, sram_wdata_e6, sram_wdata_e7;
wire [BW_PER_ADDR_E-1:0] sram_wdata_e8, sram_wdata_e9, sram_wdata_e10, sram_wdata_e11;
wire [BW_PER_ADDR_E-1:0] sram_wdata_e12, sram_wdata_e13, sram_wdata_e14, sram_wdata_e15;

// SRAM T signals (16 banks)
wire sram_wen_t0, sram_wen_t1, sram_wen_t2, sram_wen_t3;
wire sram_wen_t4, sram_wen_t5, sram_wen_t6, sram_wen_t7;
wire sram_wen_t8, sram_wen_t9, sram_wen_t10, sram_wen_t11;
wire sram_wen_t12, sram_wen_t13, sram_wen_t14, sram_wen_t15;
wire [BW_PER_ADDR_T-1:0] sram_rdata_t0, sram_rdata_t1, sram_rdata_t2, sram_rdata_t3;
wire [BW_PER_ADDR_T-1:0] sram_rdata_t4, sram_rdata_t5, sram_rdata_t6, sram_rdata_t7;
wire [BW_PER_ADDR_T-1:0] sram_rdata_t8, sram_rdata_t9, sram_rdata_t10, sram_rdata_t11;
wire [BW_PER_ADDR_T-1:0] sram_rdata_t12, sram_rdata_t13, sram_rdata_t14, sram_rdata_t15;
wire [SRAM_ADDR_WIDTH_T-1:0] sram_addr_t0, sram_addr_t1, sram_addr_t2, sram_addr_t3;
wire [SRAM_ADDR_WIDTH_T-1:0] sram_addr_t4, sram_addr_t5, sram_addr_t6, sram_addr_t7;
wire [SRAM_ADDR_WIDTH_T-1:0] sram_addr_t8, sram_addr_t9, sram_addr_t10, sram_addr_t11;
wire [SRAM_ADDR_WIDTH_T-1:0] sram_addr_t12, sram_addr_t13, sram_addr_t14, sram_addr_t15;
wire [BW_PER_ADDR_T-1:0] sram_wdata_t0, sram_wdata_t1, sram_wdata_t2, sram_wdata_t3;
wire [BW_PER_ADDR_T-1:0] sram_wdata_t4, sram_wdata_t5, sram_wdata_t6, sram_wdata_t7;
wire [BW_PER_ADDR_T-1:0] sram_wdata_t8, sram_wdata_t9, sram_wdata_t10, sram_wdata_t11;
wire [BW_PER_ADDR_T-1:0] sram_wdata_t12, sram_wdata_t13, sram_wdata_t14, sram_wdata_t15;

// SRAM C signals (16 banks)
wire sram_wen_c0, sram_wen_c1, sram_wen_c2, sram_wen_c3;
wire sram_wen_c4, sram_wen_c5, sram_wen_c6, sram_wen_c7;
wire sram_wen_c8, sram_wen_c9, sram_wen_c10, sram_wen_c11;
wire sram_wen_c12, sram_wen_c13, sram_wen_c14, sram_wen_c15;
wire [BW_PER_ADDR_C-1:0] sram_rdata_c0, sram_rdata_c1, sram_rdata_c2, sram_rdata_c3;
wire [BW_PER_ADDR_C-1:0] sram_rdata_c4, sram_rdata_c5, sram_rdata_c6, sram_rdata_c7;
wire [BW_PER_ADDR_C-1:0] sram_rdata_c8, sram_rdata_c9, sram_rdata_c10, sram_rdata_c11;
wire [BW_PER_ADDR_C-1:0] sram_rdata_c12, sram_rdata_c13, sram_rdata_c14, sram_rdata_c15;
wire [SRAM_ADDR_WIDTH_C-1:0] sram_addr_c0, sram_addr_c1, sram_addr_c2, sram_addr_c3;
wire [SRAM_ADDR_WIDTH_C-1:0] sram_addr_c4, sram_addr_c5, sram_addr_c6, sram_addr_c7;
wire [SRAM_ADDR_WIDTH_C-1:0] sram_addr_c8, sram_addr_c9, sram_addr_c10, sram_addr_c11;
wire [SRAM_ADDR_WIDTH_C-1:0] sram_addr_c12, sram_addr_c13, sram_addr_c14, sram_addr_c15;
wire [BW_PER_ADDR_C-1:0] sram_wdata_c0, sram_wdata_c1, sram_wdata_c2, sram_wdata_c3;
wire [BW_PER_ADDR_C-1:0] sram_wdata_c4, sram_wdata_c5, sram_wdata_c6, sram_wdata_c7;
wire [BW_PER_ADDR_C-1:0] sram_wdata_c8, sram_wdata_c9, sram_wdata_c10, sram_wdata_c11;
wire [BW_PER_ADDR_C-1:0] sram_wdata_c12, sram_wdata_c13, sram_wdata_c14, sram_wdata_c15;

// SRAM G signals
wire sram_wen_g0;
wire sram_wen_g1;
wire sram_wen_g2;
wire sram_wen_g3;
wire [BW_PER_ADDR_G-1:0] sram_rdata_g0;
wire [BW_PER_ADDR_G-1:0] sram_rdata_g1;
wire [BW_PER_ADDR_G-1:0] sram_rdata_g2;
wire [BW_PER_ADDR_G-1:0] sram_rdata_g3;
wire [SRAM_ADDR_WIDTH_G-1:0] sram_addr_g0;
wire [SRAM_ADDR_WIDTH_G-1:0] sram_addr_g1;
wire [SRAM_ADDR_WIDTH_G-1:0] sram_addr_g2;
wire [SRAM_ADDR_WIDTH_G-1:0] sram_addr_g3;
wire [BW_PER_ADDR_G-1:0] sram_wdata_g0;
wire [BW_PER_ADDR_G-1:0] sram_wdata_g1;
wire [BW_PER_ADDR_G-1:0] sram_wdata_g2;
wire [BW_PER_ADDR_G-1:0] sram_wdata_g3;

// SRAM Z signals
wire sram_wen_z0;
wire sram_wen_z1;
wire sram_wen_z2;
wire sram_wen_z3;
wire [BW_PER_ADDR_Z-1:0] sram_rdata_z0;
wire [BW_PER_ADDR_Z-1:0] sram_rdata_z1;
wire [BW_PER_ADDR_Z-1:0] sram_rdata_z2;
wire [BW_PER_ADDR_Z-1:0] sram_rdata_z3;
wire [SRAM_ADDR_WIDTH_Z-1:0] sram_addr_z0;
wire [SRAM_ADDR_WIDTH_Z-1:0] sram_addr_z1;
wire [SRAM_ADDR_WIDTH_Z-1:0] sram_addr_z2;
wire [SRAM_ADDR_WIDTH_Z-1:0] sram_addr_z3;
wire [BW_PER_ADDR_Z-1:0] sram_wdata_z0;
wire [BW_PER_ADDR_Z-1:0] sram_wdata_z1;
wire [BW_PER_ADDR_Z-1:0] sram_wdata_z2;
wire [BW_PER_ADDR_Z-1:0] sram_wdata_z3;

// Twiddle ROM signals (16 banks)
wire [0:0] twiddle_addr_0, twiddle_addr_1, twiddle_addr_2, twiddle_addr_3,
            twiddle_addr_4, twiddle_addr_5, twiddle_addr_6, twiddle_addr_7,
            twiddle_addr_8, twiddle_addr_9, twiddle_addr_10, twiddle_addr_11,
            twiddle_addr_12, twiddle_addr_13, twiddle_addr_14, twiddle_addr_15;
wire [(2*pFP_WIDTH-1):0] twiddle_data_0, twiddle_data_1, twiddle_data_2, twiddle_data_3,
                        twiddle_data_4, twiddle_data_5, twiddle_data_6, twiddle_data_7,
                        twiddle_data_8, twiddle_data_9, twiddle_data_10, twiddle_data_11,
                        twiddle_data_12, twiddle_data_13, twiddle_data_14, twiddle_data_15;

// Instantiate IEC RTL module
IEC_top #(
    .BW_PER_ADDR_A(BW_PER_ADDR_A),
    .BW_PER_ADDR_B(BW_PER_ADDR_B),
    .BW_PER_ADDR_I(BW_PER_ADDR_I),
    .BW_PER_ADDR_U(BW_PER_ADDR_U),
    .BW_PER_ADDR_W(BW_PER_ADDR_W),
    .BW_PER_ADDR_X(BW_PER_ADDR_X),
    .BW_PER_ADDR_E(BW_PER_ADDR_E),
    .BW_PER_ADDR_T(BW_PER_ADDR_T),
    .BW_PER_ADDR_C(BW_PER_ADDR_C),
    .BW_PER_ADDR_G(BW_PER_ADDR_G),
    .BW_PER_ADDR_Z(BW_PER_ADDR_Z),
    .ADDR_WIDTH_A(SRAM_ADDR_WIDTH_A),
    .ADDR_WIDTH_B(SRAM_ADDR_WIDTH_B),
    .ADDR_WIDTH_I(SRAM_ADDR_WIDTH_I),
    .ADDR_WIDTH_U(SRAM_ADDR_WIDTH_U),
    .ADDR_WIDTH_W(SRAM_ADDR_WIDTH_W),
    .ADDR_WIDTH_X(SRAM_ADDR_WIDTH_X),
    .ADDR_WIDTH_E(SRAM_ADDR_WIDTH_E),
    .ADDR_WIDTH_T(SRAM_ADDR_WIDTH_T),
    .ADDR_WIDTH_C(SRAM_ADDR_WIDTH_C),
    .ADDR_WIDTH_G(SRAM_ADDR_WIDTH_G),
    .ADDR_WIDTH_Z(SRAM_ADDR_WIDTH_Z)
)U_IEC(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable), 
    .done(done),
    
    .sram_wen_a0(sram_wen_a0),
    .sram_wen_a1(sram_wen_a1),
    .sram_wen_a2(sram_wen_a2),
    .sram_wen_a3(sram_wen_a3),

    .sram_addr_a0(sram_addr_a0),
    .sram_addr_a1(sram_addr_a1),
    .sram_addr_a2(sram_addr_a2),
    .sram_addr_a3(sram_addr_a3),
    
    .sram_wdata_a0(sram_wdata_a0),
    .sram_wdata_a1(sram_wdata_a1),
    .sram_wdata_a2(sram_wdata_a2),
    .sram_wdata_a3(sram_wdata_a3),

    .sram_rdata_a0(sram_rdata_a0),
    .sram_rdata_a1(sram_rdata_a1),
    .sram_rdata_a2(sram_rdata_a2),
    .sram_rdata_a3(sram_rdata_a3),
    
    // SRAM B
    .sram_wen_b0(sram_wen_b0),
    .sram_wen_b1(sram_wen_b1),
    .sram_wen_b2(sram_wen_b2),
    .sram_wen_b3(sram_wen_b3),

    .sram_addr_b0(sram_addr_b0),
    .sram_addr_b1(sram_addr_b1),
    .sram_addr_b2(sram_addr_b2),
    .sram_addr_b3(sram_addr_b3),
    
    .sram_wdata_b0(sram_wdata_b0),
    .sram_wdata_b1(sram_wdata_b1),
    .sram_wdata_b2(sram_wdata_b2),
    .sram_wdata_b3(sram_wdata_b3),

    .sram_rdata_b0(sram_rdata_b0),
    .sram_rdata_b1(sram_rdata_b1),
    .sram_rdata_b2(sram_rdata_b2),
    .sram_rdata_b3(sram_rdata_b3),

    // SRAM I
    .sram_wen_i0(sram_wen_i0),
    .sram_wen_i1(sram_wen_i1),
    .sram_wen_i2(sram_wen_i2),
    .sram_wen_i3(sram_wen_i3),

    .sram_addr_i0(sram_addr_i0),
    .sram_addr_i1(sram_addr_i1),
    .sram_addr_i2(sram_addr_i2),
    .sram_addr_i3(sram_addr_i3),
    
    .sram_wdata_i0(sram_wdata_i0),
    .sram_wdata_i1(sram_wdata_i1),
    .sram_wdata_i2(sram_wdata_i2),
    .sram_wdata_i3(sram_wdata_i3),

    .sram_rdata_i0(sram_rdata_i0),
    .sram_rdata_i1(sram_rdata_i1),
    .sram_rdata_i2(sram_rdata_i2),
    .sram_rdata_i3(sram_rdata_i3),

    // SRAM U
    .sram_wen_u0(sram_wen_u0),
    .sram_wen_u1(sram_wen_u1),
    .sram_wen_u2(sram_wen_u2),
    .sram_wen_u3(sram_wen_u3),

    .sram_addr_u0(sram_addr_u0),
    .sram_addr_u1(sram_addr_u1),
    .sram_addr_u2(sram_addr_u2),
    .sram_addr_u3(sram_addr_u3),
    
    .sram_wdata_u0(sram_wdata_u0),
    .sram_wdata_u1(sram_wdata_u1),
    .sram_wdata_u2(sram_wdata_u2),
    .sram_wdata_u3(sram_wdata_u3),

    .sram_rdata_u0(sram_rdata_u0),
    .sram_rdata_u1(sram_rdata_u1),
    .sram_rdata_u2(sram_rdata_u2),
    .sram_rdata_u3(sram_rdata_u3),

    // SRAM W
    .sram_wen_w0(sram_wen_w0),
    .sram_wen_w1(sram_wen_w1),
    .sram_wen_w2(sram_wen_w2),
    .sram_wen_w3(sram_wen_w3),
    .sram_addr_w0(sram_addr_w0),
    .sram_addr_w1(sram_addr_w1),
    .sram_addr_w2(sram_addr_w2),
    .sram_addr_w3(sram_addr_w3),
    .sram_wdata_w0(sram_wdata_w0),
    .sram_wdata_w1(sram_wdata_w1),
    .sram_wdata_w2(sram_wdata_w2),
    .sram_wdata_w3(sram_wdata_w3),
    .sram_rdata_w0(sram_rdata_w0),
    .sram_rdata_w1(sram_rdata_w1),
    .sram_rdata_w2(sram_rdata_w2),
    .sram_rdata_w3(sram_rdata_w3),

    // SRAM X
    .sram_wen_x0(sram_wen_x0),
    .sram_wen_x1(sram_wen_x1),
    .sram_wen_x2(sram_wen_x2),
    .sram_wen_x3(sram_wen_x3),
    .sram_addr_x0(sram_addr_x0),
    .sram_addr_x1(sram_addr_x1),
    .sram_addr_x2(sram_addr_x2),
    .sram_addr_x3(sram_addr_x3),
    .sram_wdata_x0(sram_wdata_x0),
    .sram_wdata_x1(sram_wdata_x1),
    .sram_wdata_x2(sram_wdata_x2),
    .sram_wdata_x3(sram_wdata_x3),
    .sram_rdata_x0(sram_rdata_x0),
    .sram_rdata_x1(sram_rdata_x1),
    .sram_rdata_x2(sram_rdata_x2),
    .sram_rdata_x3(sram_rdata_x3),

    // SRAM E (16 banks)
    .sram_wen_e0(sram_wen_e0), .sram_wen_e1(sram_wen_e1), .sram_wen_e2(sram_wen_e2), .sram_wen_e3(sram_wen_e3),
    .sram_wen_e4(sram_wen_e4), .sram_wen_e5(sram_wen_e5), .sram_wen_e6(sram_wen_e6), .sram_wen_e7(sram_wen_e7),
    .sram_wen_e8(sram_wen_e8), .sram_wen_e9(sram_wen_e9), .sram_wen_e10(sram_wen_e10), .sram_wen_e11(sram_wen_e11),
    .sram_wen_e12(sram_wen_e12), .sram_wen_e13(sram_wen_e13), .sram_wen_e14(sram_wen_e14), .sram_wen_e15(sram_wen_e15),
    .sram_addr_e0(sram_addr_e0), .sram_addr_e1(sram_addr_e1), .sram_addr_e2(sram_addr_e2), .sram_addr_e3(sram_addr_e3),
    .sram_addr_e4(sram_addr_e4), .sram_addr_e5(sram_addr_e5), .sram_addr_e6(sram_addr_e6), .sram_addr_e7(sram_addr_e7),
    .sram_addr_e8(sram_addr_e8), .sram_addr_e9(sram_addr_e9), .sram_addr_e10(sram_addr_e10), .sram_addr_e11(sram_addr_e11),
    .sram_addr_e12(sram_addr_e12), .sram_addr_e13(sram_addr_e13), .sram_addr_e14(sram_addr_e14), .sram_addr_e15(sram_addr_e15),
    .sram_wdata_e0(sram_wdata_e0), .sram_wdata_e1(sram_wdata_e1), .sram_wdata_e2(sram_wdata_e2), .sram_wdata_e3(sram_wdata_e3),
    .sram_wdata_e4(sram_wdata_e4), .sram_wdata_e5(sram_wdata_e5), .sram_wdata_e6(sram_wdata_e6), .sram_wdata_e7(sram_wdata_e7),
    .sram_wdata_e8(sram_wdata_e8), .sram_wdata_e9(sram_wdata_e9), .sram_wdata_e10(sram_wdata_e10), .sram_wdata_e11(sram_wdata_e11),
    .sram_wdata_e12(sram_wdata_e12), .sram_wdata_e13(sram_wdata_e13), .sram_wdata_e14(sram_wdata_e14), .sram_wdata_e15(sram_wdata_e15),
    .sram_rdata_e0(sram_rdata_e0), .sram_rdata_e1(sram_rdata_e1), .sram_rdata_e2(sram_rdata_e2), .sram_rdata_e3(sram_rdata_e3),
    .sram_rdata_e4(sram_rdata_e4), .sram_rdata_e5(sram_rdata_e5), .sram_rdata_e6(sram_rdata_e6), .sram_rdata_e7(sram_rdata_e7),
    .sram_rdata_e8(sram_rdata_e8), .sram_rdata_e9(sram_rdata_e9), .sram_rdata_e10(sram_rdata_e10), .sram_rdata_e11(sram_rdata_e11),
    .sram_rdata_e12(sram_rdata_e12), .sram_rdata_e13(sram_rdata_e13), .sram_rdata_e14(sram_rdata_e14), .sram_rdata_e15(sram_rdata_e15),

    // SRAM T (16 banks)
    .sram_wen_t0(sram_wen_t0), .sram_wen_t1(sram_wen_t1), .sram_wen_t2(sram_wen_t2), .sram_wen_t3(sram_wen_t3),
    .sram_wen_t4(sram_wen_t4), .sram_wen_t5(sram_wen_t5), .sram_wen_t6(sram_wen_t6), .sram_wen_t7(sram_wen_t7),
    .sram_wen_t8(sram_wen_t8), .sram_wen_t9(sram_wen_t9), .sram_wen_t10(sram_wen_t10), .sram_wen_t11(sram_wen_t11),
    .sram_wen_t12(sram_wen_t12), .sram_wen_t13(sram_wen_t13), .sram_wen_t14(sram_wen_t14), .sram_wen_t15(sram_wen_t15),
    .sram_addr_t0(sram_addr_t0), .sram_addr_t1(sram_addr_t1), .sram_addr_t2(sram_addr_t2), .sram_addr_t3(sram_addr_t3),
    .sram_addr_t4(sram_addr_t4), .sram_addr_t5(sram_addr_t5), .sram_addr_t6(sram_addr_t6), .sram_addr_t7(sram_addr_t7),
    .sram_addr_t8(sram_addr_t8), .sram_addr_t9(sram_addr_t9), .sram_addr_t10(sram_addr_t10), .sram_addr_t11(sram_addr_t11),
    .sram_addr_t12(sram_addr_t12), .sram_addr_t13(sram_addr_t13), .sram_addr_t14(sram_addr_t14), .sram_addr_t15(sram_addr_t15),
    .sram_wdata_t0(sram_wdata_t0), .sram_wdata_t1(sram_wdata_t1), .sram_wdata_t2(sram_wdata_t2), .sram_wdata_t3(sram_wdata_t3),
    .sram_wdata_t4(sram_wdata_t4), .sram_wdata_t5(sram_wdata_t5), .sram_wdata_t6(sram_wdata_t6), .sram_wdata_t7(sram_wdata_t7),
    .sram_wdata_t8(sram_wdata_t8), .sram_wdata_t9(sram_wdata_t9), .sram_wdata_t10(sram_wdata_t10), .sram_wdata_t11(sram_wdata_t11),
    .sram_wdata_t12(sram_wdata_t12), .sram_wdata_t13(sram_wdata_t13), .sram_wdata_t14(sram_wdata_t14), .sram_wdata_t15(sram_wdata_t15),
    .sram_rdata_t0(sram_rdata_t0), .sram_rdata_t1(sram_rdata_t1), .sram_rdata_t2(sram_rdata_t2), .sram_rdata_t3(sram_rdata_t3),
    .sram_rdata_t4(sram_rdata_t4), .sram_rdata_t5(sram_rdata_t5), .sram_rdata_t6(sram_rdata_t6), .sram_rdata_t7(sram_rdata_t7),
    .sram_rdata_t8(sram_rdata_t8), .sram_rdata_t9(sram_rdata_t9), .sram_rdata_t10(sram_rdata_t10), .sram_rdata_t11(sram_rdata_t11),
    .sram_rdata_t12(sram_rdata_t12), .sram_rdata_t13(sram_rdata_t13), .sram_rdata_t14(sram_rdata_t14), .sram_rdata_t15(sram_rdata_t15),

    // SRAM C (16 banks)
    .sram_wen_c0(sram_wen_c0), .sram_wen_c1(sram_wen_c1), .sram_wen_c2(sram_wen_c2), .sram_wen_c3(sram_wen_c3),
    .sram_wen_c4(sram_wen_c4), .sram_wen_c5(sram_wen_c5), .sram_wen_c6(sram_wen_c6), .sram_wen_c7(sram_wen_c7),
    .sram_wen_c8(sram_wen_c8), .sram_wen_c9(sram_wen_c9), .sram_wen_c10(sram_wen_c10), .sram_wen_c11(sram_wen_c11),
    .sram_wen_c12(sram_wen_c12), .sram_wen_c13(sram_wen_c13), .sram_wen_c14(sram_wen_c14), .sram_wen_c15(sram_wen_c15),
    .sram_addr_c0(sram_addr_c0), .sram_addr_c1(sram_addr_c1), .sram_addr_c2(sram_addr_c2), .sram_addr_c3(sram_addr_c3),
    .sram_addr_c4(sram_addr_c4), .sram_addr_c5(sram_addr_c5), .sram_addr_c6(sram_addr_c6), .sram_addr_c7(sram_addr_c7),
    .sram_addr_c8(sram_addr_c8), .sram_addr_c9(sram_addr_c9), .sram_addr_c10(sram_addr_c10), .sram_addr_c11(sram_addr_c11),
    .sram_addr_c12(sram_addr_c12), .sram_addr_c13(sram_addr_c13), .sram_addr_c14(sram_addr_c14), .sram_addr_c15(sram_addr_c15),
    .sram_wdata_c0(sram_wdata_c0), .sram_wdata_c1(sram_wdata_c1), .sram_wdata_c2(sram_wdata_c2), .sram_wdata_c3(sram_wdata_c3),
    .sram_wdata_c4(sram_wdata_c4), .sram_wdata_c5(sram_wdata_c5), .sram_wdata_c6(sram_wdata_c6), .sram_wdata_c7(sram_wdata_c7),
    .sram_wdata_c8(sram_wdata_c8), .sram_wdata_c9(sram_wdata_c9), .sram_wdata_c10(sram_wdata_c10), .sram_wdata_c11(sram_wdata_c11),
    .sram_wdata_c12(sram_wdata_c12), .sram_wdata_c13(sram_wdata_c13), .sram_wdata_c14(sram_wdata_c14), .sram_wdata_c15(sram_wdata_c15),
    .sram_rdata_c0(sram_rdata_c0), .sram_rdata_c1(sram_rdata_c1), .sram_rdata_c2(sram_rdata_c2), .sram_rdata_c3(sram_rdata_c3),
    .sram_rdata_c4(sram_rdata_c4), .sram_rdata_c5(sram_rdata_c5), .sram_rdata_c6(sram_rdata_c6), .sram_rdata_c7(sram_rdata_c7),
    .sram_rdata_c8(sram_rdata_c8), .sram_rdata_c9(sram_rdata_c9), .sram_rdata_c10(sram_rdata_c10), .sram_rdata_c11(sram_rdata_c11),
    .sram_rdata_c12(sram_rdata_c12), .sram_rdata_c13(sram_rdata_c13), .sram_rdata_c14(sram_rdata_c14), .sram_rdata_c15(sram_rdata_c15),

    // SRAM G
    .sram_wen_g0(sram_wen_g0),
    .sram_wen_g1(sram_wen_g1),
    .sram_wen_g2(sram_wen_g2),
    .sram_wen_g3(sram_wen_g3),
    .sram_addr_g0(sram_addr_g0),
    .sram_addr_g1(sram_addr_g1),
    .sram_addr_g2(sram_addr_g2),
    .sram_addr_g3(sram_addr_g3),
    .sram_wdata_g0(sram_wdata_g0),
    .sram_wdata_g1(sram_wdata_g1),
    .sram_wdata_g2(sram_wdata_g2),
    .sram_wdata_g3(sram_wdata_g3),
    .sram_rdata_g0(sram_rdata_g0),
    .sram_rdata_g1(sram_rdata_g1),
    .sram_rdata_g2(sram_rdata_g2),
    .sram_rdata_g3(sram_rdata_g3),

    // SRAM Z
    .sram_wen_z0(sram_wen_z0),
    .sram_wen_z1(sram_wen_z1),
    .sram_wen_z2(sram_wen_z2),
    .sram_wen_z3(sram_wen_z3),
    .sram_addr_z0(sram_addr_z0),
    .sram_addr_z1(sram_addr_z1),
    .sram_addr_z2(sram_addr_z2),
    .sram_addr_z3(sram_addr_z3),
    .sram_wdata_z0(sram_wdata_z0),
    .sram_wdata_z1(sram_wdata_z1),
    .sram_wdata_z2(sram_wdata_z2),
    .sram_wdata_z3(sram_wdata_z3),
    .sram_rdata_z0(sram_rdata_z0),
    .sram_rdata_z1(sram_rdata_z1),
    .sram_rdata_z2(sram_rdata_z2),
    .sram_rdata_z3(sram_rdata_z3),

    .twiddle_addr_0(twiddle_addr_0), .twiddle_addr_1(twiddle_addr_1), .twiddle_addr_2(twiddle_addr_2), .twiddle_addr_3(twiddle_addr_3),
    .twiddle_addr_4(twiddle_addr_4), .twiddle_addr_5(twiddle_addr_5), .twiddle_addr_6(twiddle_addr_6), .twiddle_addr_7(twiddle_addr_7),
    .twiddle_addr_8(twiddle_addr_8), .twiddle_addr_9(twiddle_addr_9), .twiddle_addr_10(twiddle_addr_10), .twiddle_addr_11(twiddle_addr_11),
    .twiddle_addr_12(twiddle_addr_12), .twiddle_addr_13(twiddle_addr_13), .twiddle_addr_14(twiddle_addr_14), .twiddle_addr_15(twiddle_addr_15),
    .twiddle_data_0(twiddle_data_0), .twiddle_data_1(twiddle_data_1), .twiddle_data_2(twiddle_data_2), .twiddle_data_3(twiddle_data_3),
    .twiddle_data_4(twiddle_data_4), .twiddle_data_5(twiddle_data_5), .twiddle_data_6(twiddle_data_6), .twiddle_data_7(twiddle_data_7),
    .twiddle_data_8(twiddle_data_8), .twiddle_data_9(twiddle_data_9), .twiddle_data_10(twiddle_data_10), .twiddle_data_11(twiddle_data_11),
    .twiddle_data_12(twiddle_data_12), .twiddle_data_13(twiddle_data_13), .twiddle_data_14(twiddle_data_14), .twiddle_data_15(twiddle_data_15)
);


// ===== sram connection ===== //
// SRAM for LAYER1: input_image (sram_a)
sram_256x3b #(
    .BW_PER_ADDR(BW_PER_ADDR_A),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_A)
) sram_a(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_a0), 
    .wsb_1(sram_wen_a1), 
    .wsb_2(sram_wen_a2), 
    .wsb_3(sram_wen_a3), 

    .wdata_0(sram_wdata_a0), 
    .wdata_1(sram_wdata_a1), 
    .wdata_2(sram_wdata_a2), 
    .wdata_3(sram_wdata_a3), 

    .waddr_0(sram_addr_a0),  
    .waddr_1(sram_addr_a1), 
    .waddr_2(sram_addr_a2), 
    .waddr_3(sram_addr_a3), 
    
    .raddr_0(sram_addr_a0),  
    .raddr_1(sram_addr_a1), 
    .raddr_2(sram_addr_a2), 
    .raddr_3(sram_addr_a3), 

    .rdata_0(sram_rdata_a0),
    .rdata_1(sram_rdata_a1),
    .rdata_2(sram_rdata_a2),
    .rdata_3(sram_rdata_a3)
);

// SRAM I(32x32x8b)

// SRAM for LAYER2: initial_illum_map (sram_b)
sram_256x8b #(
    .BW_PER_ADDR(BW_PER_ADDR_B),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_B)
) sram_b(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_b0), 
    .wsb_1(sram_wen_b1), 
    .wsb_2(sram_wen_b2), 
    .wsb_3(sram_wen_b3), 

    .wdata_0(sram_wdata_b0), 
    .wdata_1(sram_wdata_b1), 
    .wdata_2(sram_wdata_b2), 
    .wdata_3(sram_wdata_b3), 

    .waddr_0(sram_addr_b0),  
    .waddr_1(sram_addr_b1), 
    .waddr_2(sram_addr_b2), 
    .waddr_3(sram_addr_b3), 
    
    .raddr_0(sram_addr_b0),  
    .raddr_1(sram_addr_b1), 
    .raddr_2(sram_addr_b2), 
    .raddr_3(sram_addr_b3), 

    .rdata_0(sram_rdata_b0),
    .rdata_1(sram_rdata_b1),
    .rdata_2(sram_rdata_b2),
    .rdata_3(sram_rdata_b3)
);

// SRAM for LAYER2: initial_illum_map (sram_i)
sram_256x8b #(
    .BW_PER_ADDR(BW_PER_ADDR_I),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_I)
) sram_i(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_i0), 
    .wsb_1(sram_wen_i1), 
    .wsb_2(sram_wen_i2), 
    .wsb_3(sram_wen_i3), 

    .wdata_0(sram_wdata_i0), 
    .wdata_1(sram_wdata_i1), 
    .wdata_2(sram_wdata_i2), 
    .wdata_3(sram_wdata_i3), 

    .waddr_0(sram_addr_i0),  
    .waddr_1(sram_addr_i1), 
    .waddr_2(sram_addr_i2), 
    .waddr_3(sram_addr_i3), 
    
    .raddr_0(sram_addr_i0),  
    .raddr_1(sram_addr_i1), 
    .raddr_2(sram_addr_i2), 
    .raddr_3(sram_addr_i3), 

    .rdata_0(sram_rdata_i0),
    .rdata_1(sram_rdata_i1),
    .rdata_2(sram_rdata_i2),
    .rdata_3(sram_rdata_i3)
);

// SRAM for LAYER3-0: U (sram_U1)
// SRAM for LAYER3-10: Q (sram_U2)
sram_512x8b #(
    .BW_PER_ADDR(BW_PER_ADDR_U),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_U)
) sram_u(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_u0), 
    .wsb_1(sram_wen_u1), 
    .wsb_2(sram_wen_u2), 
    .wsb_3(sram_wen_u3), 

    .wdata_0(sram_wdata_u0), 
    .wdata_1(sram_wdata_u1), 
    .wdata_2(sram_wdata_u2), 
    .wdata_3(sram_wdata_u3), 

    .waddr_0(sram_addr_u0),  
    .waddr_1(sram_addr_u1), 
    .waddr_2(sram_addr_u2), 
    .waddr_3(sram_addr_u3), 
    
    .raddr_0(sram_addr_u0),  
    .raddr_1(sram_addr_u1), 
    .raddr_2(sram_addr_u2), 
    .raddr_3(sram_addr_u3), 

    .rdata_0(sram_rdata_u0),
    .rdata_1(sram_rdata_u1),
    .rdata_2(sram_rdata_u2),
    .rdata_3(sram_rdata_u3)
);

// SRAM for LAYER3-1: A (sram_W)
sram_512x8b #(
    .BW_PER_ADDR(BW_PER_ADDR_W),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_W)
) sram_w(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_w0), 
    .wsb_1(sram_wen_w1), 
    .wsb_2(sram_wen_w2), 
    .wsb_3(sram_wen_w3), 

    .wdata_0(sram_wdata_w0), 
    .wdata_1(sram_wdata_w1), 
    .wdata_2(sram_wdata_w2), 
    .wdata_3(sram_wdata_w3), 

    .waddr_0(sram_addr_w0),  
    .waddr_1(sram_addr_w1), 
    .waddr_2(sram_addr_w2), 
    .waddr_3(sram_addr_w3), 
    
    .raddr_0(sram_addr_w0),  
    .raddr_1(sram_addr_w1), 
    .raddr_2(sram_addr_w2), 
    .raddr_3(sram_addr_w3), 

    .rdata_0(sram_rdata_w0),
    .rdata_1(sram_rdata_w1),
    .rdata_2(sram_rdata_w2),
    .rdata_3(sram_rdata_w3)
);

// SRAM for LAYER3-2: delG (sram_X1)
// SRAM for LAYER3-8: delT (sram_X2)
sram_512x8b #(
    .BW_PER_ADDR(BW_PER_ADDR_X),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_X)
) sram_x(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_x0), 
    .wsb_1(sram_wen_x1), 
    .wsb_2(sram_wen_x2), 
    .wsb_3(sram_wen_x3), 

    .wdata_0(sram_wdata_x0), 
    .wdata_1(sram_wdata_x1), 
    .wdata_2(sram_wdata_x2), 
    .wdata_3(sram_wdata_x3), 

    .waddr_0(sram_addr_x0),  
    .waddr_1(sram_addr_x1), 
    .waddr_2(sram_addr_x2), 
    .waddr_3(sram_addr_x3), 
    
    .raddr_0(sram_addr_x0),  
    .raddr_1(sram_addr_x1), 
    .raddr_2(sram_addr_x2), 
    .raddr_3(sram_addr_x3), 

    .rdata_0(sram_rdata_x0),
    .rdata_1(sram_rdata_x1),
    .rdata_2(sram_rdata_x2),
    .rdata_3(sram_rdata_x3)
);

// SRAM for LAYER3-3: Tnum (sram_E1)
// SRAM for LAYER3-5: Td (sram_E2)
sram_64x16b_16bank #(
    .BW_PER_ADDR(BW_PER_ADDR_E),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_E)
) sram_e(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_e0), .wsb_1(sram_wen_e1), .wsb_2(sram_wen_e2), .wsb_3(sram_wen_e3),
    .wsb_4(sram_wen_e4), .wsb_5(sram_wen_e5), .wsb_6(sram_wen_e6), .wsb_7(sram_wen_e7),
    .wsb_8(sram_wen_e8), .wsb_9(sram_wen_e9), .wsb_10(sram_wen_e10), .wsb_11(sram_wen_e11),
    .wsb_12(sram_wen_e12), .wsb_13(sram_wen_e13), .wsb_14(sram_wen_e14), .wsb_15(sram_wen_e15),

    .wdata_0(sram_wdata_e0), .wdata_1(sram_wdata_e1), .wdata_2(sram_wdata_e2), .wdata_3(sram_wdata_e3),
    .wdata_4(sram_wdata_e4), .wdata_5(sram_wdata_e5), .wdata_6(sram_wdata_e6), .wdata_7(sram_wdata_e7),
    .wdata_8(sram_wdata_e8), .wdata_9(sram_wdata_e9), .wdata_10(sram_wdata_e10), .wdata_11(sram_wdata_e11),
    .wdata_12(sram_wdata_e12), .wdata_13(sram_wdata_e13), .wdata_14(sram_wdata_e14), .wdata_15(sram_wdata_e15),

    .waddr_0(sram_addr_e0), .waddr_1(sram_addr_e1), .waddr_2(sram_addr_e2), .waddr_3(sram_addr_e3),
    .waddr_4(sram_addr_e4), .waddr_5(sram_addr_e5), .waddr_6(sram_addr_e6), .waddr_7(sram_addr_e7),
    .waddr_8(sram_addr_e8), .waddr_9(sram_addr_e9), .waddr_10(sram_addr_e10), .waddr_11(sram_addr_e11),
    .waddr_12(sram_addr_e12), .waddr_13(sram_addr_e13), .waddr_14(sram_addr_e14), .waddr_15(sram_addr_e15),
    
    .raddr_0(sram_addr_e0), .raddr_1(sram_addr_e1), .raddr_2(sram_addr_e2), .raddr_3(sram_addr_e3),
    .raddr_4(sram_addr_e4), .raddr_5(sram_addr_e5), .raddr_6(sram_addr_e6), .raddr_7(sram_addr_e7),
    .raddr_8(sram_addr_e8), .raddr_9(sram_addr_e9), .raddr_10(sram_addr_e10), .raddr_11(sram_addr_e11),
    .raddr_12(sram_addr_e12), .raddr_13(sram_addr_e13), .raddr_14(sram_addr_e14), .raddr_15(sram_addr_e15),

    .rdata_0(sram_rdata_e0), .rdata_1(sram_rdata_e1), .rdata_2(sram_rdata_e2), .rdata_3(sram_rdata_e3),
    .rdata_4(sram_rdata_e4), .rdata_5(sram_rdata_e5), .rdata_6(sram_rdata_e6), .rdata_7(sram_rdata_e7),
    .rdata_8(sram_rdata_e8), .rdata_9(sram_rdata_e9), .rdata_10(sram_rdata_e10), .rdata_11(sram_rdata_e11),
    .rdata_12(sram_rdata_e12), .rdata_13(sram_rdata_e13), .rdata_14(sram_rdata_e14), .rdata_15(sram_rdata_e15)
);

// SRAM for LAYER3-4: Tn   (sram_T1)
// SRAM for LAYER3-7: Tout (sram_T2)
sram_64x16b_16bank #(
    .BW_PER_ADDR(BW_PER_ADDR_T),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_T)
) sram_t(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_t0), .wsb_1(sram_wen_t1), .wsb_2(sram_wen_t2), .wsb_3(sram_wen_t3),
    .wsb_4(sram_wen_t4), .wsb_5(sram_wen_t5), .wsb_6(sram_wen_t6), .wsb_7(sram_wen_t7),
    .wsb_8(sram_wen_t8), .wsb_9(sram_wen_t9), .wsb_10(sram_wen_t10), .wsb_11(sram_wen_t11),
    .wsb_12(sram_wen_t12), .wsb_13(sram_wen_t13), .wsb_14(sram_wen_t14), .wsb_15(sram_wen_t15),

    .wdata_0(sram_wdata_t0), .wdata_1(sram_wdata_t1), .wdata_2(sram_wdata_t2), .wdata_3(sram_wdata_t3),
    .wdata_4(sram_wdata_t4), .wdata_5(sram_wdata_t5), .wdata_6(sram_wdata_t6), .wdata_7(sram_wdata_t7),
    .wdata_8(sram_wdata_t8), .wdata_9(sram_wdata_t9), .wdata_10(sram_wdata_t10), .wdata_11(sram_wdata_t11),
    .wdata_12(sram_wdata_t12), .wdata_13(sram_wdata_t13), .wdata_14(sram_wdata_t14), .wdata_15(sram_wdata_t15),

    .waddr_0(sram_addr_t0), .waddr_1(sram_addr_t1), .waddr_2(sram_addr_t2), .waddr_3(sram_addr_t3),
    .waddr_4(sram_addr_t4), .waddr_5(sram_addr_t5), .waddr_6(sram_addr_t6), .waddr_7(sram_addr_t7),
    .waddr_8(sram_addr_t8), .waddr_9(sram_addr_t9), .waddr_10(sram_addr_t10), .waddr_11(sram_addr_t11),
    .waddr_12(sram_addr_t12), .waddr_13(sram_addr_t13), .waddr_14(sram_addr_t14), .waddr_15(sram_addr_t15),
    
    .raddr_0(sram_addr_t0), .raddr_1(sram_addr_t1), .raddr_2(sram_addr_t2), .raddr_3(sram_addr_t3),
    .raddr_4(sram_addr_t4), .raddr_5(sram_addr_t5), .raddr_6(sram_addr_t6), .raddr_7(sram_addr_t7),
    .raddr_8(sram_addr_t8), .raddr_9(sram_addr_t9), .raddr_10(sram_addr_t10), .raddr_11(sram_addr_t11),
    .raddr_12(sram_addr_t12), .raddr_13(sram_addr_t13), .raddr_14(sram_addr_t14), .raddr_15(sram_addr_t15),

    .rdata_0(sram_rdata_t0), .rdata_1(sram_rdata_t1), .rdata_2(sram_rdata_t2), .rdata_3(sram_rdata_t3),
    .rdata_4(sram_rdata_t4), .rdata_5(sram_rdata_t5), .rdata_6(sram_rdata_t6), .rdata_7(sram_rdata_t7),
    .rdata_8(sram_rdata_t8), .rdata_9(sram_rdata_t9), .rdata_10(sram_rdata_t10), .rdata_11(sram_rdata_t11),
    .rdata_12(sram_rdata_t12), .rdata_13(sram_rdata_t13), .rdata_14(sram_rdata_t14), .rdata_15(sram_rdata_t15)
);


// SRAM for LAYER3-6: Tnd (sram_C1)
sram_64x16b_16bank #(
    .BW_PER_ADDR(BW_PER_ADDR_C),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_C)
) sram_c(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_c0), .wsb_1(sram_wen_c1), .wsb_2(sram_wen_c2), .wsb_3(sram_wen_c3),
    .wsb_4(sram_wen_c4), .wsb_5(sram_wen_c5), .wsb_6(sram_wen_c6), .wsb_7(sram_wen_c7),
    .wsb_8(sram_wen_c8), .wsb_9(sram_wen_c9), .wsb_10(sram_wen_c10), .wsb_11(sram_wen_c11),
    .wsb_12(sram_wen_c12), .wsb_13(sram_wen_c13), .wsb_14(sram_wen_c14), .wsb_15(sram_wen_c15),

    .wdata_0(sram_wdata_c0), .wdata_1(sram_wdata_c1), .wdata_2(sram_wdata_c2), .wdata_3(sram_wdata_c3),
    .wdata_4(sram_wdata_c4), .wdata_5(sram_wdata_c5), .wdata_6(sram_wdata_c6), .wdata_7(sram_wdata_c7),
    .wdata_8(sram_wdata_c8), .wdata_9(sram_wdata_c9), .wdata_10(sram_wdata_c10), .wdata_11(sram_wdata_c11),
    .wdata_12(sram_wdata_c12), .wdata_13(sram_wdata_c13), .wdata_14(sram_wdata_c14), .wdata_15(sram_wdata_c15),

    .waddr_0(sram_addr_c0), .waddr_1(sram_addr_c1), .waddr_2(sram_addr_c2), .waddr_3(sram_addr_c3),
    .waddr_4(sram_addr_c4), .waddr_5(sram_addr_c5), .waddr_6(sram_addr_c6), .waddr_7(sram_addr_c7),
    .waddr_8(sram_addr_c8), .waddr_9(sram_addr_c9), .waddr_10(sram_addr_c10), .waddr_11(sram_addr_c11),
    .waddr_12(sram_addr_c12), .waddr_13(sram_addr_c13), .waddr_14(sram_addr_c14), .waddr_15(sram_addr_c15),
    
    .raddr_0(sram_addr_c0), .raddr_1(sram_addr_c1), .raddr_2(sram_addr_c2), .raddr_3(sram_addr_c3),
    .raddr_4(sram_addr_c4), .raddr_5(sram_addr_c5), .raddr_6(sram_addr_c6), .raddr_7(sram_addr_c7),
    .raddr_8(sram_addr_c8), .raddr_9(sram_addr_c9), .raddr_10(sram_addr_c10), .raddr_11(sram_addr_c11),
    .raddr_12(sram_addr_c12), .raddr_13(sram_addr_c13), .raddr_14(sram_addr_c14), .raddr_15(sram_addr_c15),

    .rdata_0(sram_rdata_c0), .rdata_1(sram_rdata_c1), .rdata_2(sram_rdata_c2), .rdata_3(sram_rdata_c3),
    .rdata_4(sram_rdata_c4), .rdata_5(sram_rdata_c5), .rdata_6(sram_rdata_c6), .rdata_7(sram_rdata_c7),
    .rdata_8(sram_rdata_c8), .rdata_9(sram_rdata_c9), .rdata_10(sram_rdata_c10), .rdata_11(sram_rdata_c11),
    .rdata_12(sram_rdata_c12), .rdata_13(sram_rdata_c13), .rdata_14(sram_rdata_c14), .rdata_15(sram_rdata_c15)
);

// SRAM for LAYER3-9: G (sram_G1)
sram_512x8b #(
    .BW_PER_ADDR(BW_PER_ADDR_G),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_G)
) sram_g(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_g0), 
    .wsb_1(sram_wen_g1), 
    .wsb_2(sram_wen_g2), 
    .wsb_3(sram_wen_g3), 

    .wdata_0(sram_wdata_g0), 
    .wdata_1(sram_wdata_g1), 
    .wdata_2(sram_wdata_g2), 
    .wdata_3(sram_wdata_g3), 

    .waddr_0(sram_addr_g0),  
    .waddr_1(sram_addr_g1), 
    .waddr_2(sram_addr_g2), 
    .waddr_3(sram_addr_g3), 
    
    .raddr_0(sram_addr_g0),  
    .raddr_1(sram_addr_g1), 
    .raddr_2(sram_addr_g2), 
    .raddr_3(sram_addr_g3), 

    .rdata_0(sram_rdata_g0),
    .rdata_1(sram_rdata_g1),
    .rdata_2(sram_rdata_g2),
    .rdata_3(sram_rdata_g3)
);

// SRAM for LAYER3-11: Z (sram_Z1)
sram_512x8b #(
    .BW_PER_ADDR(BW_PER_ADDR_Z),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_Z)
) sram_z(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_z0), 
    .wsb_1(sram_wen_z1), 
    .wsb_2(sram_wen_z2), 
    .wsb_3(sram_wen_z3), 

    .wdata_0(sram_wdata_z0), 
    .wdata_1(sram_wdata_z1), 
    .wdata_2(sram_wdata_z2), 
    .wdata_3(sram_wdata_z3), 

    .waddr_0(sram_addr_z0),  
    .waddr_1(sram_addr_z1), 
    .waddr_2(sram_addr_z2), 
    .waddr_3(sram_addr_z3), 
    
    .raddr_0(sram_addr_z0),  
    .raddr_1(sram_addr_z1), 
    .raddr_2(sram_addr_z2), 
    .raddr_3(sram_addr_z3), 

    .rdata_0(sram_rdata_z0),
    .rdata_1(sram_rdata_z1),
    .rdata_2(sram_rdata_z2),
    .rdata_3(sram_rdata_z3)
);

// Instantiate Twiddle ROM (16 banks)
twiddle_rom #(
    .DATA_WIDTH(2*pFP_WIDTH),
    .BANK_ADDR_WIDTH(1)
) u_twiddle_rom (
    .addr_0(twiddle_addr_0), .addr_1(twiddle_addr_1), .addr_2(twiddle_addr_2), .addr_3(twiddle_addr_3),
    .addr_4(twiddle_addr_4), .addr_5(twiddle_addr_5), .addr_6(twiddle_addr_6), .addr_7(twiddle_addr_7),
    .addr_8(twiddle_addr_8), .addr_9(twiddle_addr_9), .addr_10(twiddle_addr_10), .addr_11(twiddle_addr_11),
    .addr_12(twiddle_addr_12), .addr_13(twiddle_addr_13), .addr_14(twiddle_addr_14), .addr_15(twiddle_addr_15),
    .twiddle_out_0(twiddle_data_0), .twiddle_out_1(twiddle_data_1), .twiddle_out_2(twiddle_data_2), .twiddle_out_3(twiddle_data_3),
    .twiddle_out_4(twiddle_data_4), .twiddle_out_5(twiddle_data_5), .twiddle_out_6(twiddle_data_6), .twiddle_out_7(twiddle_data_7),
    .twiddle_out_8(twiddle_data_8), .twiddle_out_9(twiddle_data_9), .twiddle_out_10(twiddle_data_10), .twiddle_out_11(twiddle_data_11),
    .twiddle_out_12(twiddle_data_12), .twiddle_out_13(twiddle_data_13), .twiddle_out_14(twiddle_data_14), .twiddle_out_15(twiddle_data_15)
);

// ===== waveform dumpping ===== //
initial begin
    if(`FLAG_DUMPWV)begin
        $fsdbDumpfile("IMC.fsdb");
        $fsdbDumpvars("+mda");
    end
end

// ===== system reset ===== //
initial begin
    clk = 0;
    rst_n = 0;
    enable = 0;
    
    sram_a.clear_sram(0);
    sram_b.clear_sram(0);
    sram_i.clear_sram(0);
    sram_u.clear_sram(0);
    sram_w.clear_sram(0);
    sram_x.clear_sram(0);
    sram_e.clear_sram(0);
    sram_t.clear_sram(0);
    sram_c.clear_sram(0);
    sram_g.clear_sram(0);
    sram_z.clear_sram(0);
    
    #(`CYCLE * 5);
    
    // Initialize SRAM 
    if(layer_value == 1) begin // Layer 1: input_image
        // Initialize sramA
        $display("Initializing SRAM A (input_image)");
        sram_a.load_dat(pat_value, 1, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
        #(`CYCLE * 5);
        
        // Load golden data for comparison
        load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
        
        #(`CYCLE * 5);
        
        // Compare 
        compare_load();
        
        // Finish simulation after comparison
        $display("\nSimulation completed successfully!");
        $finish;
        
    end else if(layer_value == 2) begin // Layer 2: initial_illum_map 
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM B (initial_illum_map)");
            sram_b.load_dat(pat_value, 2, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 3)begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM U (sramU_1.dat)");
            sram_u.load_dat(pat_value, 3, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 4)begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM W (sramW_1.dat)");
            sram_w.load_dat(pat_value, 4, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 5) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM X (sramX_1.dat)");
            sram_x.load_dat(pat_value, 5, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 6) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM E (sramE_1.dat)");
            sram_e.load_dat(pat_value, 6, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 7) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM T (sramT_1.dat)");
            sram_t.load_dat(pat_value, 7, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 8) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM E (sramE_2.dat)");
            sram_e.load_dat(pat_value, 8, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 9) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM C (sramC_1.dat)");
            sram_c.load_dat(pat_value, 9, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 10) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM T (sramT_2.dat)");
            sram_t.load_dat(pat_value, 10, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 11) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM X (sramX_2.dat)");
            sram_x.load_dat(pat_value, 11, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 12) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM G (sramG_1.dat)");
            sram_g.load_dat(pat_value, 12, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 13) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM U (sramU_2.dat)");
            sram_u.load_dat(pat_value, 13, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end else if(layer_value == 14) begin
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM Z (sramZ_1.dat)");
            sram_z.load_dat(pat_value, 14, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end
    end
    
    // ===== Hardware mode (INIT_EN = 0) ===== //
    // Common hardware mode for all layers (layer_value >= 2)
    // This block handles hardware execution and comparison for all layers
    if(layer_value >= 2 && init_enable == 0) begin
        // Initialize sramA 
        sram_a.load_dat(pat_value, 1, patch_i_value, patch_j_value);
        
        @(posedge clk); rst_n = 1;
        @(posedge clk); enable = 1;
        $display("Starting IEC processing");
        
        // Wait for done 
        wait(done);
        #(`CYCLE * 5);
        
        // Load golden data for comparison
        load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
        #(`CYCLE * 5);
        
        // Compare 
        compare_load();
        
        // INIT_EN=0: Finish simulation after comparison
        $display("\nSimulation completed successfully!");
        $finish;
    end
end

// ===== Clock generation ===== //
initial begin
    while(1) #(`CYCLE/2) clk = ~clk;
end

initial begin
  #(`CYCLE * `END_CYCLES);
    $display("\n========================================================");
    $display("   Error!!! Simulation time is too long...            ");
    $display("   There might be something wrong in your code.       ");
    $display("   If your design really needs such a long time,      ");
    $display("   increase the END_CYCLES setting in the testbench.  ");
    $display("========================================================");
    $finish;
end


// ===== Load golden data from BMP file ===== //
task load_golden;
    input [7:0] PAT;        // "1" for lime1, "2" for lime2
    input [31:0] LAYER;     // 1~5
    input [31:0] PATCH_I;   // patch row index (0-27)
    input [31:0] PATCH_J;   // patch column index (0-27)

    integer row, col, addr, file_in;
    integer i, j;
    integer byte_idx;
    reg [196*8-1:0] bmp_filepath;
    reg [7:0] r, g, b;  // RGB components
    reg [23:0] pixel_data;
    reg [7:0] patch_i_str [0:1];
    reg [7:0] patch_j_str [0:1];
    reg [7:0] byte_data [0:7];  // For 64-bit
    reg [7:0] byte_data_128 [0:15];  // For 128-bit
    real pixel_val_fp64;  // For fp64 conversion
    integer hex_char;
    reg [7:0] hex_line [0:15];  // 16 characters for hex string
    reg [63:0] hex_value;
    reg [63:0] hex_value_low, hex_value_high;
    integer char_idx;
    integer nibble_val;

begin
    patch_i_str[0] = ((PATCH_I / 10) % 10) + "0";
    patch_i_str[1] = (PATCH_I % 10) + "0";
    patch_j_str[0] = ((PATCH_J / 10) % 10) + "0";
    patch_j_str[1] = (PATCH_J % 10) + "0";

   // filepath
    if(PAT == "1") begin // PAT == "1" (imgs_lime1)
        case(LAYER)
            1 : $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/input_image/patch_%c%c_%c%c_under.bmp",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            2 : $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/initial_illum_map/patch_%c%c_%c%c_under.bmp",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);

            3 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramU_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            4 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramW_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            5 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramX_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            6 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramE_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            7 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramT_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            8 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramE_2.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            9 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramC_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            10: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramT_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            11: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramX_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            12: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramG_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            13: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramU_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            14: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramZ_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            
            15: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/refined_illum_map/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            16: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/gamma_illum_map/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            17: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/enhanced_image/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            default: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/unknown_layer/patch_%c%c_%c%c_under.bmp",
                              patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
        endcase
    end else begin  // PAT == "2" (imgs_lime2)
        case(LAYER)
            1 : $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/input_image/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            2 : $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/initial_illum_map/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            
            3 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramU_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            4 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramW_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            5 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramX_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            6 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramE_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            7 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramT_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            8 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramE_2.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            9 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramC_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            10: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramT_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            11: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramX_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            12: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramG_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            13: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramU_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            14: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramZ_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);


            15: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/refined_illum_map/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            16: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/gamma_illum_map/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            17: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/enhanced_image/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            default: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/unknown_layer/patch_%c%c_%c%c_over.bmp",
                              patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
        endcase
    end

    file_in = $fopen(bmp_filepath, "rb");
    if(file_in == 0) begin
        $display("Error: Cannot open %s", bmp_filepath);
        disable load_golden;
    end

    if(LAYER == 1) begin
        // Layer 1: BMP file (24-bit RGB)
        // Skip 54-byte header 
        for(i = 0; i < 54; i = i + 1)
            r = $fgetc(file_in);
        
        // addr : 0~255
        addr = 0;
        for(row = 31; row >= 0; row = row - 1) begin  // BMP bottom-up
            for(col = 0; col < 32; col = col + 4) begin  // 4 pixel -> 4 bank
                // bmp order: B-> G -> R
                // pixel0 -> golden_bank_a0
                b = $fgetc(file_in);
                g = $fgetc(file_in);
                r = $fgetc(file_in);
                pixel_data = {r, g, b};
                golden_bank_a0[addr] = pixel_data;

                // pixel1 -> golden_bank_a1
                b = $fgetc(file_in);
                g = $fgetc(file_in);
                r = $fgetc(file_in);
                pixel_data = {r, g, b};
                golden_bank_a1[addr] = pixel_data;

                // pixel2 -> golden_bank_a2
                b = $fgetc(file_in);
                g = $fgetc(file_in);
                r = $fgetc(file_in);
                pixel_data = {r, g, b};
                golden_bank_a2[addr] = pixel_data;

                // pixel3 -> golden_bank_a3
                b = $fgetc(file_in);
                g = $fgetc(file_in);
                r = $fgetc(file_in);
                pixel_data = {r, g, b};
                golden_bank_a3[addr] = pixel_data;

                addr = addr + 1;
            end
        end
    end else if(LAYER == 2) begin
        // Layer 2: BMP file (8-bit grayscale)
        // Skip header (54 bytes + 256*4 palette = 1078 bytes)
        for(i = 0; i < 1078; i = i + 1)
            r = $fgetc(file_in);
        
        // addr : 0~255
        addr = 0;
        for(row = 31; row >= 0; row = row - 1) begin  // BMP bottom-up
            for(col = 0; col < 32; col = col + 4) begin  // 4 pixel -> 4 bank
                // pixel0 -> golden_bank_b0 
                r = $fgetc(file_in);
                golden_bank_b0[addr] = r;  

                // pixel1 -> golden_bank_b1 
                r = $fgetc(file_in);
                golden_bank_b1[addr] = r;  

                // pixel2 -> golden_bank_b2 
                r = $fgetc(file_in);
                golden_bank_b2[addr] = r;  

                // pixel3 -> golden_bank_b3 
                r = $fgetc(file_in);
                golden_bank_b3[addr] = r; 

                addr = addr + 1;
            end
        end
    end else if(LAYER >= 3 && LAYER <= 14) begin
        // Layer 3-14: .dat file (ASCII text, each line is a 16-character hex string)
        // Layer 3,4,5,7,11,12,13,14: 64-bit fp64, 512 addresses (U, W, X, T, X, G, U, Z)
        // Layer 6,8,9,10: 128-bit fp64, 256 addresses (E, E, C, T)
        
        if(LAYER == 3 || LAYER == 4 || LAYER == 5 || LAYER == 11 || LAYER == 12 || LAYER == 13 || LAYER == 14) begin
            // 64-bit fp64, 512 addresses
            addr = 0;
            while(addr < 512 && !$feof(file_in)) begin
                // Read 16 hex characters for bank0
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;  // Exit loop
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                if(hex_char != 10 && hex_char != 13 && hex_char != -1) begin
                    // Not a newline, unget the character by reading it again later
                    // We'll handle this by checking if we read 16 chars already
                end
                // Convert hex string to 64-bit value
                hex_value = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value = (hex_value << 4) | nibble_val;
                end
                golden_bank_u0[addr] = hex_value;
                
                // Read 16 hex characters for bank1
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;  // Exit loop
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                if(hex_char != 10 && hex_char != 13 && hex_char != -1) begin
                    // Not a newline, unget the character by reading it again later
                    // We'll handle this by checking if we read 16 chars already
                end
                hex_value = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value = (hex_value << 4) | nibble_val;
                end
                golden_bank_u1[addr] = hex_value;
                
                // Read 16 hex characters for bank2
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;  // Exit loop
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                if(hex_char != 10 && hex_char != 13 && hex_char != -1) begin
                    // Not a newline, unget the character by reading it again later
                    // We'll handle this by checking if we read 16 chars already
                end
                hex_value = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value = (hex_value << 4) | nibble_val;
                end
                golden_bank_u2[addr] = hex_value;
                
                // Read 16 hex characters for bank3
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;  // Exit loop
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                if(hex_char != 10 && hex_char != 13 && hex_char != -1) begin
                    // Not a newline, unget the character by reading it again later
                    // We'll handle this by checking if we read 16 chars already
                end
                hex_value = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value = (hex_value << 4) | nibble_val;
                end
                golden_bank_u3[addr] = hex_value;
                
                addr = addr + 1;
            end
        end else if(LAYER == 7 || LAYER == 9 || LAYER == 10) begin
            // Layer 7,9,10: 128-bit fp64, 64 addresses, 16 banks (SRAM T, C, T)
            // File format: 32 hex characters with underscore separator (e.g., "408b37e7e7e7e7e8_0000000000000000")
            // Format: high_low, where high is [127:64] (real part), low is [63:0] (imaginary part)
            addr = 0;
            while(addr < 64 && !$feof(file_in)) begin
                // Read 16 hex characters for high 64-bit (before underscore)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                // Skip underscore
                hex_char = $fgetc(file_in);
                // Convert hex string to 64-bit value (high)
                hex_value_high = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value_high = (hex_value_high << 4) | nibble_val;
                end
                // Read 16 hex characters for low 64-bit (after underscore)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                // Convert hex string to 64-bit value (low)
                hex_value_low = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value_low = (hex_value_low << 4) | nibble_val;
                end
                golden_bank_e0[addr] = {hex_value_high, hex_value_low};
                
                // Read for bank1 (high_low format)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_high = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value_high = (hex_value_high << 4) | nibble_val;
                end
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_low = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value_low = (hex_value_low << 4) | nibble_val;
                end
                golden_bank_e1[addr] = {hex_value_high, hex_value_low};
                
                // Read for bank2 (high_low format)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_high = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value_high = (hex_value_high << 4) | nibble_val;
                end
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_low = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value_low = (hex_value_low << 4) | nibble_val;
                end
                golden_bank_e2[addr] = {hex_value_high, hex_value_low};
                
                // Read for bank3 (high_low format)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_high = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value_high = (hex_value_high << 4) | nibble_val;
                end
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_low = 64'h0;
                for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                    if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                        nibble_val = hex_line[char_idx] - "0";
                    end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                        nibble_val = hex_line[char_idx] - "a" + 10;
                    end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                        nibble_val = hex_line[char_idx] - "A" + 10;
                    end else begin
                        nibble_val = 0;
                    end
                    hex_value_low = (hex_value_low << 4) | nibble_val;
                end
                golden_bank_e3[addr] = {hex_value_high, hex_value_low};
                
                // Read for bank4-15 (high_low format)
                for(i = 4; i < 16; i = i + 1) begin
                    char_idx = 0;
                    while(char_idx < 16) begin
                        hex_char = $fgetc(file_in);
                        if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                            for(j = char_idx; j < 16; j = j + 1) begin
                                hex_line[j] = "0";
                            end
                            char_idx = 16;
                        end else begin
                            hex_line[char_idx] = hex_char;
                            char_idx = char_idx + 1;
                        end
                    end
                    hex_char = $fgetc(file_in);
                    hex_value_high = 64'h0;
                    for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                        if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                            nibble_val = hex_line[char_idx] - "0";
                        end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                            nibble_val = hex_line[char_idx] - "a" + 10;
                        end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                            nibble_val = hex_line[char_idx] - "A" + 10;
                        end else begin
                            nibble_val = 0;
                        end
                        hex_value_high = (hex_value_high << 4) | nibble_val;
                    end
                    char_idx = 0;
                    while(char_idx < 16) begin
                        hex_char = $fgetc(file_in);
                        if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                            for(j = char_idx; j < 16; j = j + 1) begin
                                hex_line[j] = "0";
                            end
                            char_idx = 16;
                        end else begin
                            hex_line[char_idx] = hex_char;
                            char_idx = char_idx + 1;
                        end
                    end
                    hex_char = $fgetc(file_in);
                    hex_value_low = 64'h0;
                    for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                        if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                            nibble_val = hex_line[char_idx] - "0";
                        end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                            nibble_val = hex_line[char_idx] - "a" + 10;
                        end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                            nibble_val = hex_line[char_idx] - "A" + 10;
                        end else begin
                            nibble_val = 0;
                        end
                        hex_value_low = (hex_value_low << 4) | nibble_val;
                    end
                    case(i)
                        4: golden_bank_e4[addr] = {hex_value_high, hex_value_low};
                        5: golden_bank_e5[addr] = {hex_value_high, hex_value_low};
                        6: golden_bank_e6[addr] = {hex_value_high, hex_value_low};
                        7: golden_bank_e7[addr] = {hex_value_high, hex_value_low};
                        8: golden_bank_e8[addr] = {hex_value_high, hex_value_low};
                        9: golden_bank_e9[addr] = {hex_value_high, hex_value_low};
                        10: golden_bank_e10[addr] = {hex_value_high, hex_value_low};
                        11: golden_bank_e11[addr] = {hex_value_high, hex_value_low};
                        12: golden_bank_e12[addr] = {hex_value_high, hex_value_low};
                        13: golden_bank_e13[addr] = {hex_value_high, hex_value_low};
                        14: golden_bank_e14[addr] = {hex_value_high, hex_value_low};
                        15: golden_bank_e15[addr] = {hex_value_high, hex_value_low};
                    endcase
                end
                
                addr = addr + 1;
            end
        end else begin
            // Layer 6,8: 128-bit fp64, 64 addresses, 16 banks
            // Layer 6: File format is 16 hex characters (real part only, FFT input), low is always 0
            // Layer 8: File format is high_low (32 hex characters with underscore separator)
            // 64 addresses * 16 banks = 1024 lines
            addr = 0;
            while(addr < 64 && !$feof(file_in)) begin
                if(LAYER == 6) begin
                    // Layer 6: Read 16 hex characters (real part only), low is always 0
                    // Read for bank0
                    char_idx = 0;
                    while(char_idx < 16) begin
                        hex_char = $fgetc(file_in);
                        if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                            for(i = char_idx; i < 16; i = i + 1) begin
                                hex_line[i] = "0";
                            end
                            char_idx = 16;
                        end else begin
                            hex_line[char_idx] = hex_char;
                            char_idx = char_idx + 1;
                        end
                    end
                    hex_char = $fgetc(file_in); // Consume newline
                    hex_value_high = 64'h0;
                    for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                        if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                            nibble_val = hex_line[char_idx] - "0";
                        end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                            nibble_val = hex_line[char_idx] - "a" + 10;
                        end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                            nibble_val = hex_line[char_idx] - "A" + 10;
                        end else begin
                            nibble_val = 0;
                        end
                        hex_value_high = (hex_value_high << 4) | nibble_val;
                    end
                    // high is [127:64] (real part), low is [63:0] (imaginary part, always 0 for layer 6)
                    golden_bank_e0[addr] = {hex_value_high, 64'h0};
                end else begin
                    // Layer 8: Read high_low format (32 hex characters with underscore separator)
                    // Read 16 hex characters for high 64-bit (before underscore)
                    char_idx = 0;
                    while(char_idx < 16) begin
                        hex_char = $fgetc(file_in);
                        if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                            for(i = char_idx; i < 16; i = i + 1) begin
                                hex_line[i] = "0";
                            end
                            char_idx = 16;
                        end else begin
                            hex_line[char_idx] = hex_char;
                            char_idx = char_idx + 1;
                        end
                    end
                    // Skip underscore
                    hex_char = $fgetc(file_in);
                    hex_value_high = 64'h0;
                    for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                        if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                            nibble_val = hex_line[char_idx] - "0";
                        end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                            nibble_val = hex_line[char_idx] - "a" + 10;
                        end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                            nibble_val = hex_line[char_idx] - "A" + 10;
                        end else begin
                            nibble_val = 0;
                        end
                        hex_value_high = (hex_value_high << 4) | nibble_val;
                    end
                    
                    // Read 16 hex characters for low 64-bit (after underscore)
                    char_idx = 0;
                    while(char_idx < 16) begin
                        hex_char = $fgetc(file_in);
                        if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                            for(i = char_idx; i < 16; i = i + 1) begin
                                hex_line[i] = "0";
                            end
                            char_idx = 16;
                        end else begin
                            hex_line[char_idx] = hex_char;
                            char_idx = char_idx + 1;
                        end
                    end
                    hex_char = $fgetc(file_in); // Consume newline
                    hex_value_low = 64'h0;
                    for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                        if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                            nibble_val = hex_line[char_idx] - "0";
                        end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                            nibble_val = hex_line[char_idx] - "a" + 10;
                        end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                            nibble_val = hex_line[char_idx] - "A" + 10;
                        end else begin
                            nibble_val = 0;
                        end
                        hex_value_low = (hex_value_low << 4) | nibble_val;
                    end
                    // high is [127:64] (real part), low is [63:0] (imaginary part)
                    golden_bank_e0[addr] = {hex_value_high, hex_value_low};
                end
                
                // Read for bank1-15
                for(i = 1; i < 16; i = i + 1) begin
                    if(LAYER == 6) begin
                        // Layer 6: Read 16 hex characters (real part only), low is always 0
                        char_idx = 0;
                        while(char_idx < 16) begin
                            hex_char = $fgetc(file_in);
                            if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                                for(j = char_idx; j < 16; j = j + 1) begin
                                    hex_line[j] = "0";
                                end
                                char_idx = 16;
                            end else begin
                                hex_line[char_idx] = hex_char;
                                char_idx = char_idx + 1;
                            end
                        end
                        hex_char = $fgetc(file_in); // Consume newline
                        hex_value_high = 64'h0;
                        for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                            if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                                nibble_val = hex_line[char_idx] - "0";
                            end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                                nibble_val = hex_line[char_idx] - "a" + 10;
                            end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                                nibble_val = hex_line[char_idx] - "A" + 10;
                            end else begin
                                nibble_val = 0;
                            end
                            hex_value_high = (hex_value_high << 4) | nibble_val;
                        end
                        // high is [127:64] (real part), low is [63:0] (imaginary part, always 0 for layer 6)
                        case(i)
                            1: golden_bank_e1[addr] = {hex_value_high, 64'h0};
                            2: golden_bank_e2[addr] = {hex_value_high, 64'h0};
                            3: golden_bank_e3[addr] = {hex_value_high, 64'h0};
                            4: golden_bank_e4[addr] = {hex_value_high, 64'h0};
                            5: golden_bank_e5[addr] = {hex_value_high, 64'h0};
                            6: golden_bank_e6[addr] = {hex_value_high, 64'h0};
                            7: golden_bank_e7[addr] = {hex_value_high, 64'h0};
                            8: golden_bank_e8[addr] = {hex_value_high, 64'h0};
                            9: golden_bank_e9[addr] = {hex_value_high, 64'h0};
                            10: golden_bank_e10[addr] = {hex_value_high, 64'h0};
                            11: golden_bank_e11[addr] = {hex_value_high, 64'h0};
                            12: golden_bank_e12[addr] = {hex_value_high, 64'h0};
                            13: golden_bank_e13[addr] = {hex_value_high, 64'h0};
                            14: golden_bank_e14[addr] = {hex_value_high, 64'h0};
                            15: golden_bank_e15[addr] = {hex_value_high, 64'h0};
                        endcase
                    end else begin
                        // Layer 8: Read high_low format (32 hex characters with underscore separator)
                        // Read 16 hex characters for high 64-bit (before underscore)
                        char_idx = 0;
                        while(char_idx < 16) begin
                            hex_char = $fgetc(file_in);
                            if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                                for(j = char_idx; j < 16; j = j + 1) begin
                                    hex_line[j] = "0";
                                end
                                char_idx = 16;
                            end else begin
                                hex_line[char_idx] = hex_char;
                                char_idx = char_idx + 1;
                            end
                        end
                        // Skip underscore
                        hex_char = $fgetc(file_in);
                        hex_value_high = 64'h0;
                        for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                            if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                                nibble_val = hex_line[char_idx] - "0";
                            end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                                nibble_val = hex_line[char_idx] - "a" + 10;
                            end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                                nibble_val = hex_line[char_idx] - "A" + 10;
                            end else begin
                                nibble_val = 0;
                            end
                            hex_value_high = (hex_value_high << 4) | nibble_val;
                        end
                        
                        // Read 16 hex characters for low 64-bit (after underscore)
                        char_idx = 0;
                        while(char_idx < 16) begin
                            hex_char = $fgetc(file_in);
                            if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                                for(j = char_idx; j < 16; j = j + 1) begin
                                    hex_line[j] = "0";
                                end
                                char_idx = 16;
                            end else begin
                                hex_line[char_idx] = hex_char;
                                char_idx = char_idx + 1;
                            end
                        end
                        hex_char = $fgetc(file_in); // Consume newline
                        hex_value_low = 64'h0;
                        for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                            if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                                nibble_val = hex_line[char_idx] - "0";
                            end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                                nibble_val = hex_line[char_idx] - "a" + 10;
                            end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                                nibble_val = hex_line[char_idx] - "A" + 10;
                            end else begin
                                nibble_val = 0;
                            end
                            hex_value_low = (hex_value_low << 4) | nibble_val;
                        end
                        // high is [127:64] (real part), low is [63:0] (imaginary part)
                        case(i)
                            1: golden_bank_e1[addr] = {hex_value_high, hex_value_low};
                            2: golden_bank_e2[addr] = {hex_value_high, hex_value_low};
                            3: golden_bank_e3[addr] = {hex_value_high, hex_value_low};
                            4: golden_bank_e4[addr] = {hex_value_high, hex_value_low};
                            5: golden_bank_e5[addr] = {hex_value_high, hex_value_low};
                            6: golden_bank_e6[addr] = {hex_value_high, hex_value_low};
                            7: golden_bank_e7[addr] = {hex_value_high, hex_value_low};
                            8: golden_bank_e8[addr] = {hex_value_high, hex_value_low};
                            9: golden_bank_e9[addr] = {hex_value_high, hex_value_low};
                            10: golden_bank_e10[addr] = {hex_value_high, hex_value_low};
                            11: golden_bank_e11[addr] = {hex_value_high, hex_value_low};
                            12: golden_bank_e12[addr] = {hex_value_high, hex_value_low};
                            13: golden_bank_e13[addr] = {hex_value_high, hex_value_low};
                            14: golden_bank_e14[addr] = {hex_value_high, hex_value_low};
                            15: golden_bank_e15[addr] = {hex_value_high, hex_value_low};
                        endcase
                    end
                end
                
                addr = addr + 1;
            end
        end
    end else begin
        // Layer 15-17: BMP files (similar to layer 2)
        // Skip header (54 bytes + 256*4 palette = 1078 bytes)
        for(i = 0; i < 1078; i = i + 1)
            r = $fgetc(file_in);
        
        // addr : 0~255
        addr = 0;
        for(row = 31; row >= 0; row = row - 1) begin  // BMP bottom-up
            for(col = 0; col < 32; col = col + 4) begin  // 4 pixel -> 4 bank
                // pixel0 -> golden_bank_b0 
                r = $fgetc(file_in);
                golden_bank_b0[addr] = r;  

                // pixel1 -> golden_bank_b1 
                r = $fgetc(file_in);
                golden_bank_b1[addr] = r;  

                // pixel2 -> golden_bank_b2 
                r = $fgetc(file_in);
                golden_bank_b2[addr] = r;  

                // pixel3 -> golden_bank_b3 
                r = $fgetc(file_in);
                golden_bank_b3[addr] = r; 

                addr = addr + 1;
            end
        end
    end

    $fclose(file_in);
end
endtask

// ===== Compare SRAM data with golden data ===== //
task compare_load;
    integer addr;
    integer bank_errors [0:15];
    integer total_errors;
    integer max_addr;
    integer j;  // Loop variable for banks
    real sram_val_fp64;  // For fp64 conversion from sramB (layer 2)
    real golden_val_fp64, sram_val_fp64_0, sram_val_fp64_1;
    real golden_val_fp64_0, golden_val_fp64_1;
    real golden_val_fp64_real, golden_val_fp64_imag, sram_val_fp64_real, sram_val_fp64_imag;
    real tolerance;  // Tolerance for fp64 comparison
    integer golden_val_uint8, sram_val_uint8;  // For uint8 comparison (layer 2)
    integer del;
begin
    total_errors = 0;
    bank_errors[0] = 0; bank_errors[1] = 0; bank_errors[2] = 0; bank_errors[3] = 0;
    bank_errors[4] = 0; bank_errors[5] = 0; bank_errors[6] = 0; bank_errors[7] = 0;
    bank_errors[8] = 0; bank_errors[9] = 0; bank_errors[10] = 0; bank_errors[11] = 0;
    bank_errors[12] = 0; bank_errors[13] = 0; bank_errors[14] = 0; bank_errors[15] = 0;
    del = 2;
    
    if(layer_value == 1) begin
        // Layer 1: Compare SRAM A (24-bit RGB)
        $display("\nSRAM A - Bank 0 Comparison (Address 0-255):");
        $display("Addr | Golden (R G B) | SRAM (R G B) | Match");
        $display("-----|----------------|--------------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            if(sram_a.bank0[addr] !== golden_bank_a0[addr]) begin
                bank_errors[0] = bank_errors[0] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | FAIL", 
                    addr,
                    golden_bank_a0[addr][23:16], golden_bank_a0[addr][15:8], golden_bank_a0[addr][7:0], golden_bank_a0[addr],
                    sram_a.bank0[addr][23:16], sram_a.bank0[addr][15:8], sram_a.bank0[addr][7:0], sram_a.bank0[addr]);
            end else begin
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | OK", 
                    addr,
                    golden_bank_a0[addr][23:16], golden_bank_a0[addr][15:8], golden_bank_a0[addr][7:0], golden_bank_a0[addr],
                    sram_a.bank0[addr][23:16], sram_a.bank0[addr][15:8], sram_a.bank0[addr][7:0], sram_a.bank0[addr]);
            end
        end
    
        $display("\nBank 1 Comparison (Address 0-255):");
        $display("Addr | Golden (R G B) | SRAM (R G B) | Match");
        $display("-----|----------------|--------------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            if(sram_a.bank1[addr] !== golden_bank_a1[addr]) begin
                bank_errors[1] = bank_errors[1] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | FAIL", 
                    addr,
                    golden_bank_a1[addr][23:16], golden_bank_a1[addr][15:8], golden_bank_a1[addr][7:0], golden_bank_a1[addr],
                    sram_a.bank1[addr][23:16], sram_a.bank1[addr][15:8], sram_a.bank1[addr][7:0], sram_a.bank1[addr]);
            end else begin
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | OK", 
                    addr,
                    golden_bank_a1[addr][23:16], golden_bank_a1[addr][15:8], golden_bank_a1[addr][7:0], golden_bank_a1[addr],
                    sram_a.bank1[addr][23:16], sram_a.bank1[addr][15:8], sram_a.bank1[addr][7:0], sram_a.bank1[addr]);
            end
        end
        
        $display("\nBank 2 Comparison (Address 0-255):");
        $display("Addr | Golden (R G B) | SRAM (R G B) | Match");
        $display("-----|----------------|--------------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            if(sram_a.bank2[addr] !== golden_bank_a2[addr]) begin
                bank_errors[2] = bank_errors[2] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | FAIL", 
                    addr,
                    golden_bank_a2[addr][23:16], golden_bank_a2[addr][15:8], golden_bank_a2[addr][7:0], golden_bank_a2[addr],
                    sram_a.bank2[addr][23:16], sram_a.bank2[addr][15:8], sram_a.bank2[addr][7:0], sram_a.bank2[addr]);
            end else begin
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | OK", 
                    addr,
                    golden_bank_a2[addr][23:16], golden_bank_a2[addr][15:8], golden_bank_a2[addr][7:0], golden_bank_a2[addr],
                    sram_a.bank2[addr][23:16], sram_a.bank2[addr][15:8], sram_a.bank2[addr][7:0], sram_a.bank2[addr]);
            end
        end
        
        $display("\nBank 3 Comparison (Address 0-255):");
        $display("Addr | Golden (R G B) | SRAM (R G B) | Match");
        $display("-----|----------------|--------------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            if(sram_a.bank3[addr] !== golden_bank_a3[addr]) begin
                bank_errors[3] = bank_errors[3] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | FAIL", 
                    addr,
                    golden_bank_a3[addr][23:16], golden_bank_a3[addr][15:8], golden_bank_a3[addr][7:0], golden_bank_a3[addr],
                    sram_a.bank3[addr][23:16], sram_a.bank3[addr][15:8], sram_a.bank3[addr][7:0], sram_a.bank3[addr]);
            end else begin
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | OK", 
                    addr,
                    golden_bank_a3[addr][23:16], golden_bank_a3[addr][15:8], golden_bank_a3[addr][7:0], golden_bank_a3[addr],
                    sram_a.bank3[addr][23:16], sram_a.bank3[addr][15:8], sram_a.bank3[addr][7:0], sram_a.bank3[addr]);
            end
        end
        
        // Summary
        $display("\n========================================================================");
        $display("Comparison Summary:");
        $display("  Bank 0 errors: %0d / 256", bank_errors[0]);
        $display("  Bank 1 errors: %0d / 256", bank_errors[1]);
        $display("  Bank 2 errors: %0d / 256", bank_errors[2]);
        $display("  Bank 3 errors: %0d / 256", bank_errors[3]);
        $display("  Total errors:  %0d / 1024", total_errors);
        
        if(total_errors == 0) begin
            $display("SUCCESS! All 1024 pixels match correctly!");
            $display("load_dat task loaded data successfully!");
        end else begin
            $display("FAIL! Found %0d errors out of 1024 pixels", total_errors);
            $display("load_dat task may have issues!");
        end
        $display("========================================================================");
    end else if(layer_value == 2) begin
        // Layer 2: Compare SRAM B (64-bit fp64, single channel)
        $display("\nSRAM B - Bank 0 Comparison (Address 0-255, fp64 IEEE754 -> uint8):");
        $display("Addr | Golden (IEEE754 fp64) | SRAM (IEEE754 fp64) | uint8 | Match");
        $display("-----|----------------------|---------------------|-------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            // golden_bank_b0 stores uint8 (0-255) directly, no conversion needed
            golden_val_uint8 = golden_bank_b0[addr];
            // Convert sramB fp64 (0.0-1.0) to uint8 (0-255) for comparison
            sram_val_fp64 = $bitstoreal(sram_b.bank0[addr]);
            sram_val_uint8 = $rtoi(sram_val_fp64 * 255.0);
            // Compare uint8 values
            
            if((golden_val_uint8 - del < sram_val_uint8) && (sram_val_uint8 < golden_val_uint8 + del)) begin
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | OK", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank0[addr]), sram_val_uint8);
            end else begin
                bank_errors[0] = bank_errors[0] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | FAIL", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank0[addr]), sram_val_uint8);
            end
        end
        
        $display("\nBank 1 Comparison (Address 0-255, fp64 IEEE754 -> uint8):");
        $display("Addr | Golden (uint8) | SRAM (IEEE754 fp64) | uint8 | Match");
        $display("-----|---------------|---------------------|-------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            // golden_bank_b1 stores uint8 (0-255) directly, no conversion needed
            golden_val_uint8 = golden_bank_b1[addr];
            // Convert sramB fp64 (0.0-1.0) to uint8 (0-255) for comparison
            sram_val_fp64 = $bitstoreal(sram_b.bank1[addr]);
            sram_val_uint8 = $rtoi(sram_val_fp64 * 255.0);
            // Compare uint8 values
            if((golden_val_uint8 - del < sram_val_uint8) && (sram_val_uint8 < golden_val_uint8 + del)) begin
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | OK", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank1[addr]), sram_val_uint8);
            end else begin
                bank_errors[1] = bank_errors[1] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | FAIL", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank1[addr]), sram_val_uint8);
            end
        end
        
        $display("\nBank 2 Comparison (Address 0-255, fp64 IEEE754 -> uint8):");
        $display("Addr | Golden (uint8) | SRAM (IEEE754 fp64) | uint8 | Match");
        $display("-----|---------------|---------------------|-------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            // golden_bank_b2 stores uint8 (0-255) directly, no conversion needed
            golden_val_uint8 = golden_bank_b2[addr];
            // Convert sramB fp64 (0.0-1.0) to uint8 (0-255) for comparison
            sram_val_fp64 = $bitstoreal(sram_b.bank2[addr]);
            sram_val_uint8 = $rtoi(sram_val_fp64 * 255.0);
            // Compare uint8 values
            if((golden_val_uint8 - del < sram_val_uint8) && (sram_val_uint8 < golden_val_uint8 + del)) begin
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | OK", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank2[addr]), sram_val_uint8);
            end else begin
                bank_errors[2] = bank_errors[2] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | FAIL", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank2[addr]), sram_val_uint8);
            end
        end
        
        $display("\nBank 3 Comparison (Address 0-255, fp64 IEEE754 -> uint8):");
        $display("Addr | Golden (uint8) | SRAM (IEEE754 fp64) | uint8 | Match");
        $display("-----|---------------|---------------------|-------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            // golden_bank_b3 stores uint8 (0-255) directly, no conversion needed
            golden_val_uint8 = golden_bank_b3[addr];
            // Convert sramB fp64 (0.0-1.0) to uint8 (0-255) for comparison
            sram_val_fp64 = $bitstoreal(sram_b.bank3[addr]);
            sram_val_uint8 = $rtoi(sram_val_fp64 * 255.0);
            // Compare uint8 values
            if((golden_val_uint8 - del < sram_val_uint8) && (sram_val_uint8 < golden_val_uint8 + del)) begin
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | OK", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank3[addr]), sram_val_uint8);
            end else begin
                bank_errors[3] = bank_errors[3] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | FAIL", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank3[addr]), sram_val_uint8);
            end
        end
        
        // Summary
        $display("\n========================================================================");
        $display("Comparison Summary:");
        $display("  Bank 0 errors: %0d / 256", bank_errors[0]);
        $display("  Bank 1 errors: %0d / 256", bank_errors[1]);
        $display("  Bank 2 errors: %0d / 256", bank_errors[2]);
        $display("  Bank 3 errors: %0d / 256", bank_errors[3]);
        $display("  Total errors:  %0d / 1024", total_errors);
        
        if(total_errors == 0) begin
            $display("SUCCESS! All 1024 pixels match correctly!");
            $display("load_dat task loaded data successfully!");
        end else begin
            $display("FAIL! Found %0d errors out of 1024 pixels", total_errors);
            $display("load_dat task may have issues!");
        end
        $display("========================================================================");
    end else if(layer_value >= 3 && layer_value <= 14) begin
        // Layer 3-14: Compare .dat files (binary fp64 data)
        tolerance = 4e-3;  // Tolerance for fp64 comparison
        
        // Determine address range and SRAM based on layer
        if(layer_value == 3 || layer_value == 4 || layer_value == 5 || 
           layer_value == 11 || layer_value == 12 || layer_value == 13 || layer_value == 14) begin
            // 64-bit fp64, 512 addresses (U, W, X, G, U, Z)
            max_addr = 512;
            
            // Determine which SRAM to compare
            if(layer_value == 3 || layer_value == 13) begin
                // SRAM U
                $display("\nSRAM U - Bank 0 Comparison (Address 0-511, fp64):");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u0[addr]);
                    sram_val_fp64 = $bitstoreal(sram_u.bank0[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[0] = bank_errors[0] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_u.bank0[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_u.bank0[addr], sram_val_fp64);
                    end
                end
                // Similar for banks 1, 2, 3...
                $display("\nBank 1 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u1[addr]);
                    sram_val_fp64 = $bitstoreal(sram_u.bank1[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[1] = bank_errors[1] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_u.bank1[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_u.bank1[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 2 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u2[addr]);
                    sram_val_fp64 = $bitstoreal(sram_u.bank2[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[2] = bank_errors[2] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_u.bank2[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_u.bank2[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 3 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u3[addr]);
                    sram_val_fp64 = $bitstoreal(sram_u.bank3[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[3] = bank_errors[3] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_u.bank3[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_u.bank3[addr], sram_val_fp64);
                    end
                end
            end else if(layer_value == 4) begin
                // SRAM W
                $display("\nSRAM W - Bank 0 Comparison (Address 0-511, fp64):");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u0[addr]);
                    sram_val_fp64 = $bitstoreal(sram_w.bank0[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[0] = bank_errors[0] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_w.bank0[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_w.bank0[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 1 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u1[addr]);
                    sram_val_fp64 = $bitstoreal(sram_w.bank1[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[1] = bank_errors[1] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_w.bank1[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_w.bank1[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 2 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u2[addr]);
                    sram_val_fp64 = $bitstoreal(sram_w.bank2[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[2] = bank_errors[2] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_w.bank2[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_w.bank2[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 3 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u3[addr]);
                    sram_val_fp64 = $bitstoreal(sram_w.bank3[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[3] = bank_errors[3] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_w.bank3[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_w.bank3[addr], sram_val_fp64);
                    end
                end
            end else if(layer_value == 5 || layer_value == 11) begin
                // SRAM X
                $display("\nSRAM X - Bank 0 Comparison (Address 0-511, fp64):");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u0[addr]);
                    sram_val_fp64 = $bitstoreal(sram_x.bank0[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[0] = bank_errors[0] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_x.bank0[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_x.bank0[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 1 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u1[addr]);
                    sram_val_fp64 = $bitstoreal(sram_x.bank1[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[1] = bank_errors[1] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_x.bank1[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_x.bank1[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 2 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u2[addr]);
                    sram_val_fp64 = $bitstoreal(sram_x.bank2[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[2] = bank_errors[2] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_x.bank2[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_x.bank2[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 3 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u3[addr]);
                    sram_val_fp64 = $bitstoreal(sram_x.bank3[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[3] = bank_errors[3] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_x.bank3[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_x.bank3[addr], sram_val_fp64);
                    end
                end
            end else if(layer_value == 12) begin
                // SRAM G
                $display("\nSRAM G - Bank 0 Comparison (Address 0-511, fp64):");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u0[addr]);
                    sram_val_fp64 = $bitstoreal(sram_g.bank0[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[0] = bank_errors[0] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_g.bank0[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_g.bank0[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 1 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u1[addr]);
                    sram_val_fp64 = $bitstoreal(sram_g.bank1[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[1] = bank_errors[1] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_g.bank1[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_g.bank1[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 2 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u2[addr]);
                    sram_val_fp64 = $bitstoreal(sram_g.bank2[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[2] = bank_errors[2] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_g.bank2[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_g.bank2[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 3 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u3[addr]);
                    sram_val_fp64 = $bitstoreal(sram_g.bank3[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[3] = bank_errors[3] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_g.bank3[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_g.bank3[addr], sram_val_fp64);
                    end
                end
            end else if(layer_value == 14) begin
                // SRAM Z
                $display("\nSRAM Z - Bank 0 Comparison (Address 0-511, fp64):");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u0[addr]);
                    sram_val_fp64 = $bitstoreal(sram_z.bank0[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[0] = bank_errors[0] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_z.bank0[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u0[addr], golden_val_fp64, sram_z.bank0[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 1 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u1[addr]);
                    sram_val_fp64 = $bitstoreal(sram_z.bank1[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[1] = bank_errors[1] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_z.bank1[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u1[addr], golden_val_fp64, sram_z.bank1[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 2 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u2[addr]);
                    sram_val_fp64 = $bitstoreal(sram_z.bank2[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[2] = bank_errors[2] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_z.bank2[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u2[addr], golden_val_fp64, sram_z.bank2[addr], sram_val_fp64);
                    end
                end
                $display("\nBank 3 Comparison:");
                $display("Addr | Golden (hex64) | Golden (fp64) | SRAM (hex64) | SRAM (fp64) | Match");
                $display("-----|---------------|--------------|-------------|------------|------");
                for(addr = 0; addr < max_addr; addr = addr + 1) begin
                    golden_val_fp64 = $bitstoreal(golden_bank_u3[addr]);
                    sram_val_fp64 = $bitstoreal(sram_z.bank3[addr]);
                    if((golden_val_fp64 > sram_val_fp64) ? (golden_val_fp64 - sram_val_fp64) : (sram_val_fp64 - golden_val_fp64) > tolerance) begin
                        bank_errors[3] = bank_errors[3] + 1;
                        total_errors = total_errors + 1;
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | FAIL", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_z.bank3[addr], sram_val_fp64);
                    end else begin
                        $display("%4d | %016h | %3.6e | %016h | %3.6e | OK", 
                            addr, golden_bank_u3[addr], golden_val_fp64, sram_z.bank3[addr], sram_val_fp64);
                    end
                end
            end
            
            // Summary for 64-bit SRAMs
            $display("\n========================================================================");
            $display("Comparison Summary (Layer %0d):", layer_value);
            if(layer_value == 6 || layer_value == 8) begin
                // SRAM E: 16 banks
                $display("  Bank 0 errors: %0d / %0d", bank_errors[0], max_addr);
                $display("  Bank 1 errors: %0d / %0d", bank_errors[1], max_addr);
                $display("  Bank 2 errors: %0d / %0d", bank_errors[2], max_addr);
                $display("  Bank 3 errors: %0d / %0d", bank_errors[3], max_addr);
                $display("  Bank 4 errors: %0d / %0d", bank_errors[4], max_addr);
                $display("  Bank 5 errors: %0d / %0d", bank_errors[5], max_addr);
                $display("  Bank 6 errors: %0d / %0d", bank_errors[6], max_addr);
                $display("  Bank 7 errors: %0d / %0d", bank_errors[7], max_addr);
                $display("  Bank 8 errors: %0d / %0d", bank_errors[8], max_addr);
                $display("  Bank 9 errors: %0d / %0d", bank_errors[9], max_addr);
                $display("  Bank 10 errors: %0d / %0d", bank_errors[10], max_addr);
                $display("  Bank 11 errors: %0d / %0d", bank_errors[11], max_addr);
                $display("  Bank 12 errors: %0d / %0d", bank_errors[12], max_addr);
                $display("  Bank 13 errors: %0d / %0d", bank_errors[13], max_addr);
                $display("  Bank 14 errors: %0d / %0d", bank_errors[14], max_addr);
                $display("  Bank 15 errors: %0d / %0d", bank_errors[15], max_addr);
                $display("  Total errors:  %0d / %0d", total_errors, max_addr * 16);
            end else begin
                // Other layers: 4 banks
                $display("  Bank 0 errors: %0d / %0d", bank_errors[0], max_addr);
                $display("  Bank 1 errors: %0d / %0d", bank_errors[1], max_addr);
                $display("  Bank 2 errors: %0d / %0d", bank_errors[2], max_addr);
                $display("  Bank 3 errors: %0d / %0d", bank_errors[3], max_addr);
                $display("  Total errors:  %0d / %0d", total_errors, max_addr * 4);
            end
            
            if(total_errors == 0) begin
                $display("SUCCESS! All data match correctly!");
            end else begin
                $display("FAIL! Found %0d errors", total_errors);
            end
            $display("========================================================================");
        end else begin
            // Layer 6,7,8,9,10: 128-bit fp64, 64 addresses, 16 banks (E, T, E, C, T)
            max_addr = 64;
            
            if(layer_value == 6 || layer_value == 8) begin
                // SRAM E (128-bit, 64 addresses, 16 banks)
                // Format: high_low, where high is [127:64] (real part), low is [63:0] (imaginary part)
                // For layer 6, only real part exists, so low is always 0
                for(j = 0; j < 16; j = j + 1) begin
                    $display("\nSRAM E - Bank %d Comparison (Address 0-63, 128-bit fp64):", j);
                    $display("Addr | Golden (hex128) | Golden (real) | Golden (imag) | SRAM (hex128) | SRAM (real) | SRAM (imag) | Match");
                    $display("-----|----------------|---------------|---------------|---------------|-------------|-------------|------");
                    for(addr = 0; addr < max_addr; addr = addr + 1) begin
                        // high = real part = [127:64], low = imaginary part = [63:0]
                        case(j)
                            0: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e0[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e0[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank0[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank0[addr][63:0]);
                            end
                            1: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e1[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e1[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank1[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank1[addr][63:0]);
                            end
                            2: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e2[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e2[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank2[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank2[addr][63:0]);
                            end
                            3: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e3[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e3[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank3[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank3[addr][63:0]);
                            end
                            4: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e4[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e4[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank4[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank4[addr][63:0]);
                            end
                            5: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e5[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e5[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank5[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank5[addr][63:0]);
                            end
                            6: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e6[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e6[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank6[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank6[addr][63:0]);
                            end
                            7: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e7[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e7[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank7[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank7[addr][63:0]);
                            end
                            8: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e8[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e8[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank8[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank8[addr][63:0]);
                            end
                            9: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e9[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e9[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank9[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank9[addr][63:0]);
                            end
                            10: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e10[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e10[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank10[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank10[addr][63:0]);
                            end
                            11: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e11[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e11[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank11[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank11[addr][63:0]);
                            end
                            12: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e12[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e12[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank12[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank12[addr][63:0]);
                            end
                            13: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e13[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e13[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank13[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank13[addr][63:0]);
                            end
                            14: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e14[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e14[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank14[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank14[addr][63:0]);
                            end
                            15: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e15[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e15[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_e.bank15[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_e.bank15[addr][63:0]);
                            end
                        endcase
                        if(((golden_val_fp64_real > sram_val_fp64_real) ? (golden_val_fp64_real - sram_val_fp64_real) : (sram_val_fp64_real - golden_val_fp64_real)) > tolerance || 
                           ((golden_val_fp64_imag > sram_val_fp64_imag) ? (golden_val_fp64_imag - sram_val_fp64_imag) : (sram_val_fp64_imag - golden_val_fp64_imag)) > tolerance) begin
                            bank_errors[j] = bank_errors[j] + 1;
                            total_errors = total_errors + 1;
                            case(j)
                                0: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e0[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank0[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                1: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e1[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank1[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                2: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e2[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank2[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                3: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e3[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank3[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                4: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e4[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank4[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                5: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e5[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank5[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                6: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e6[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank6[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                7: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e7[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank7[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                8: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e8[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank8[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                9: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e9[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank9[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                10: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e10[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank10[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                11: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e11[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank11[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                12: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e12[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank12[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                13: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e13[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank13[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                14: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e14[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank14[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                15: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e15[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank15[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                            endcase
                        end else begin
                            case(j)
                                0: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e0[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank0[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                1: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e1[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank1[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                2: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e2[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank2[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                3: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e3[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank3[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                4: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e4[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank4[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                5: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e5[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank5[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                6: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e6[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank6[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                7: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e7[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank7[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                8: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e8[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank8[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                9: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e9[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank9[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                10: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e10[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank10[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                11: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e11[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank11[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                12: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e12[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank12[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                13: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e13[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank13[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                14: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e14[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank14[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                15: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e15[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_e.bank15[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                            endcase
                        end
                    end
                end
            end else if(layer_value == 7 || layer_value == 10) begin
                // SRAM T (128-bit, 64 addresses, 16 banks)
                // File format: high_low, one line corresponds to one address of one bank, high=real part, low=imaginary part
                for(j = 0; j < 16; j = j + 1) begin
                    $display("\nSRAM T - Bank %d Comparison (Address 0-63, 128-bit fp64):", j);
                    $display("Addr | Golden (hex128) | Golden (real) | Golden (imag) | SRAM (hex128) | SRAM (real) | SRAM (imag) | Match");
                    $display("-----|----------------|---------------|---------------|---------------|-------------|-------------|------");
                    for(addr = 0; addr < max_addr; addr = addr + 1) begin
                        // high = real part = [127:64], low = imaginary part = [63:0]
                        case(j)
                            0: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e0[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e0[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank0[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank0[addr][63:0]);
                            end
                            1: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e1[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e1[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank1[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank1[addr][63:0]);
                            end
                            2: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e2[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e2[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank2[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank2[addr][63:0]);
                            end
                            3: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e3[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e3[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank3[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank3[addr][63:0]);
                            end
                            4: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e4[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e4[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank4[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank4[addr][63:0]);
                            end
                            5: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e5[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e5[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank5[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank5[addr][63:0]);
                            end
                            6: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e6[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e6[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank6[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank6[addr][63:0]);
                            end
                            7: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e7[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e7[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank7[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank7[addr][63:0]);
                            end
                            8: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e8[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e8[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank8[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank8[addr][63:0]);
                            end
                            9: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e9[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e9[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank9[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank9[addr][63:0]);
                            end
                            10: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e10[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e10[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank10[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank10[addr][63:0]);
                            end
                            11: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e11[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e11[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank11[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank11[addr][63:0]);
                            end
                            12: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e12[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e12[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank12[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank12[addr][63:0]);
                            end
                            13: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e13[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e13[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank13[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank13[addr][63:0]);
                            end
                            14: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e14[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e14[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank14[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank14[addr][63:0]);
                            end
                            15: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e15[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e15[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_t.bank15[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_t.bank15[addr][63:0]);
                            end
                        endcase
                        if(((golden_val_fp64_real > sram_val_fp64_real) ? (golden_val_fp64_real - sram_val_fp64_real) : (sram_val_fp64_real - golden_val_fp64_real)) > tolerance || 
                           ((golden_val_fp64_imag > sram_val_fp64_imag) ? (golden_val_fp64_imag - sram_val_fp64_imag) : (sram_val_fp64_imag - golden_val_fp64_imag)) > tolerance) begin
                            bank_errors[j] = bank_errors[j] + 1;
                            total_errors = total_errors + 1;
                            case(j)
                                0: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e0[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank0[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                1: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e1[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank1[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                2: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e2[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank2[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                3: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e3[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank3[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                4: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e4[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank4[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                5: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e5[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank5[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                6: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e6[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank6[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                7: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e7[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank7[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                8: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e8[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank8[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                9: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e9[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank9[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                10: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e10[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank10[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                11: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e11[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank11[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                12: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e12[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank12[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                13: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e13[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank13[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                14: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e14[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank14[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                15: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e15[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank15[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                            endcase
                        end else begin
                            case(j)
                                0: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e0[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank0[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                1: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e1[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank1[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                2: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e2[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank2[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                3: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e3[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank3[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                4: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e4[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank4[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                5: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e5[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank5[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                6: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e6[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank6[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                7: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e7[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank7[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                8: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e8[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank8[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                9: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e9[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank9[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                10: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e10[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank10[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                11: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e11[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank11[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                12: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e12[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank12[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                13: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e13[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank13[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                14: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e14[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank14[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                15: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e15[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_t.bank15[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                            endcase
                        end
                    end
                end
            end else if(layer_value == 9) begin
                // SRAM C (128-bit, 64 addresses, 16 banks)
                // File format: high_low, one line corresponds to one address of one bank, high=real part, low=imaginary part
                for(j = 0; j < 16; j = j + 1) begin
                    $display("\nSRAM C - Bank %d Comparison (Address 0-63, 128-bit fp64):", j);
                    $display("Addr | Golden (hex128) | Golden (real) | Golden (imag) | SRAM (hex128) | SRAM (real) | SRAM (imag) | Match");
                    $display("-----|----------------|---------------|---------------|---------------|-------------|-------------|------");
                    for(addr = 0; addr < max_addr; addr = addr + 1) begin
                        // high = real part = [127:64], low = imaginary part = [63:0]
                        case(j)
                            0: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e0[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e0[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank0[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank0[addr][63:0]);
                            end
                            1: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e1[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e1[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank1[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank1[addr][63:0]);
                            end
                            2: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e2[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e2[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank2[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank2[addr][63:0]);
                            end
                            3: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e3[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e3[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank3[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank3[addr][63:0]);
                            end
                            4: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e4[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e4[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank4[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank4[addr][63:0]);
                            end
                            5: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e5[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e5[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank5[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank5[addr][63:0]);
                            end
                            6: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e6[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e6[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank6[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank6[addr][63:0]);
                            end
                            7: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e7[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e7[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank7[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank7[addr][63:0]);
                            end
                            8: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e8[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e8[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank8[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank8[addr][63:0]);
                            end
                            9: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e9[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e9[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank9[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank9[addr][63:0]);
                            end
                            10: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e10[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e10[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank10[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank10[addr][63:0]);
                            end
                            11: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e11[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e11[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank11[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank11[addr][63:0]);
                            end
                            12: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e12[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e12[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank12[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank12[addr][63:0]);
                            end
                            13: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e13[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e13[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank13[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank13[addr][63:0]);
                            end
                            14: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e14[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e14[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank14[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank14[addr][63:0]);
                            end
                            15: begin
                                golden_val_fp64_real = $bitstoreal(golden_bank_e15[addr][127:64]);
                                golden_val_fp64_imag = $bitstoreal(golden_bank_e15[addr][63:0]);
                                sram_val_fp64_real = $bitstoreal(sram_c.bank15[addr][127:64]);
                                sram_val_fp64_imag = $bitstoreal(sram_c.bank15[addr][63:0]);
                            end
                        endcase
                        if(((golden_val_fp64_real > sram_val_fp64_real) ? (golden_val_fp64_real - sram_val_fp64_real) : (sram_val_fp64_real - golden_val_fp64_real)) > tolerance || 
                           ((golden_val_fp64_imag > sram_val_fp64_imag) ? (golden_val_fp64_imag - sram_val_fp64_imag) : (sram_val_fp64_imag - golden_val_fp64_imag)) > tolerance) begin
                            bank_errors[j] = bank_errors[j] + 1;
                            total_errors = total_errors + 1;
                            case(j)
                                0: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e0[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank0[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                1: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e1[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank1[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                2: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e2[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank2[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                3: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e3[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank3[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                4: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e4[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank4[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                5: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e5[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank5[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                6: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e6[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank6[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                7: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e7[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank7[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                8: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e8[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank8[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                9: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e9[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank9[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                10: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e10[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank10[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                11: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e11[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank11[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                12: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e12[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank12[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                13: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e13[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank13[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                14: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e14[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank14[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                15: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | FAIL", 
                                    addr, golden_bank_e15[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank15[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                            endcase
                        end else begin
                            case(j)
                                0: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e0[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank0[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                1: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e1[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank1[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                2: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e2[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank2[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                3: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e3[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank3[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                4: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e4[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank4[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                5: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e5[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank5[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                6: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e6[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank6[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                7: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e7[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank7[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                8: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e8[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank8[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                9: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e9[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank9[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                10: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e10[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank10[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                11: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e11[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank11[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                12: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e12[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank12[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                13: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e13[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank13[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                14: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e14[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank14[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                                15: $display("%4d | %032h | %3.6e | %3.6e | %032h | %3.6e | %3.6e | OK", 
                                    addr, golden_bank_e15[addr][127:0], golden_val_fp64_real, golden_val_fp64_imag, 
                                    sram_c.bank15[addr][127:0], sram_val_fp64_real, sram_val_fp64_imag);
                            endcase
                        end
                    end
                end
            end
            
            // Summary for 128-bit SRAMs (16 banks)
            $display("\n========================================================================");
            $display("Comparison Summary (Layer %0d):", layer_value);
            if(layer_value == 6 || layer_value == 8) begin
                // SRAM E: 16 banks
                $display("  Bank 0 errors: %0d / %0d", bank_errors[0], max_addr);
                $display("  Bank 1 errors: %0d / %0d", bank_errors[1], max_addr);
                $display("  Bank 2 errors: %0d / %0d", bank_errors[2], max_addr);
                $display("  Bank 3 errors: %0d / %0d", bank_errors[3], max_addr);
                $display("  Bank 4 errors: %0d / %0d", bank_errors[4], max_addr);
                $display("  Bank 5 errors: %0d / %0d", bank_errors[5], max_addr);
                $display("  Bank 6 errors: %0d / %0d", bank_errors[6], max_addr);
                $display("  Bank 7 errors: %0d / %0d", bank_errors[7], max_addr);
                $display("  Bank 8 errors: %0d / %0d", bank_errors[8], max_addr);
                $display("  Bank 9 errors: %0d / %0d", bank_errors[9], max_addr);
                $display("  Bank 10 errors: %0d / %0d", bank_errors[10], max_addr);
                $display("  Bank 11 errors: %0d / %0d", bank_errors[11], max_addr);
                $display("  Bank 12 errors: %0d / %0d", bank_errors[12], max_addr);
                $display("  Bank 13 errors: %0d / %0d", bank_errors[13], max_addr);
                $display("  Bank 14 errors: %0d / %0d", bank_errors[14], max_addr);
                $display("  Bank 15 errors: %0d / %0d", bank_errors[15], max_addr);
                $display("  Total errors:  %0d / %0d", total_errors, max_addr * 16);
            end else begin
                // Layer 7, 9, 10: 16 banks
                $display("  Bank 0 errors: %0d / %0d", bank_errors[0], max_addr);
                $display("  Bank 1 errors: %0d / %0d", bank_errors[1], max_addr);
                $display("  Bank 2 errors: %0d / %0d", bank_errors[2], max_addr);
                $display("  Bank 3 errors: %0d / %0d", bank_errors[3], max_addr);
                $display("  Bank 4 errors: %0d / %0d", bank_errors[4], max_addr);
                $display("  Bank 5 errors: %0d / %0d", bank_errors[5], max_addr);
                $display("  Bank 6 errors: %0d / %0d", bank_errors[6], max_addr);
                $display("  Bank 7 errors: %0d / %0d", bank_errors[7], max_addr);
                $display("  Bank 8 errors: %0d / %0d", bank_errors[8], max_addr);
                $display("  Bank 9 errors: %0d / %0d", bank_errors[9], max_addr);
                $display("  Bank 10 errors: %0d / %0d", bank_errors[10], max_addr);
                $display("  Bank 11 errors: %0d / %0d", bank_errors[11], max_addr);
                $display("  Bank 12 errors: %0d / %0d", bank_errors[12], max_addr);
                $display("  Bank 13 errors: %0d / %0d", bank_errors[13], max_addr);
                $display("  Bank 14 errors: %0d / %0d", bank_errors[14], max_addr);
                $display("  Bank 15 errors: %0d / %0d", bank_errors[15], max_addr);
                $display("  Total errors:  %0d / %0d", total_errors, max_addr * 16);
            end
            
            if(total_errors == 0) begin
                $display("SUCCESS! All data match correctly!");
            end else begin
                $display("FAIL! Found %0d errors", total_errors);
            end
            $display("========================================================================");
        end
    end
end
endtask

endmodule
