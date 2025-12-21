module IEC_top #(
    parameter BW_PER_ADDR_A = 24,
    parameter BW_PER_ADDR_B = 64,
    parameter BW_PER_ADDR_I = 64,
    parameter BW_PER_ADDR_U = 64,
    parameter BW_PER_ADDR_W = 64,
    parameter BW_PER_ADDR_X = 64,
    parameter BW_PER_ADDR_E = 128,
    parameter BW_PER_ADDR_T = 128,
    parameter BW_PER_ADDR_C = 128,
    parameter BW_PER_ADDR_G = 64,
    parameter BW_PER_ADDR_Z = 64,
    parameter BW_PER_ADDR_D = 128,
    parameter ADDR_WIDTH_A = 8,
    parameter ADDR_WIDTH_B = 8,
    parameter ADDR_WIDTH_I = 8,
    parameter ADDR_WIDTH_U = 9,
    parameter ADDR_WIDTH_W = 9,
    parameter ADDR_WIDTH_X = 9,
    parameter ADDR_WIDTH_E = 6,
    parameter ADDR_WIDTH_T = 6,
    parameter ADDR_WIDTH_C = 6,
    parameter ADDR_WIDTH_G = 9,
    parameter ADDR_WIDTH_Z = 9,
    parameter ADDR_WIDTH_D = 8,
    parameter pFP_WIDTH    = 64,
    parameter pINT_WIDTH    = 8,
    parameter mu0           = 64'h3f847ae147ae147b, // 0.01
    parameter mu0_recip     = 64'h4059000000000000, // 1 / 0.01
    parameter TWIDDLE_ADDR_WIDTH = 6
)(
    input clk,
    input rst_n,
    input enable, // sram initialization done, you can start from sramA fetch data
    output done,  // you are done, tb will start checking when receiving done

    // sram A(32x32x3x8)
    output reg sram_wen_a0, // low enable
    output reg sram_wen_a1,
    output reg sram_wen_a2,
    output reg sram_wen_a3,
    input [BW_PER_ADDR_A-1:0] sram_rdata_a0,
    input [BW_PER_ADDR_A-1:0] sram_rdata_a1,
    input [BW_PER_ADDR_A-1:0] sram_rdata_a2,
    input [BW_PER_ADDR_A-1:0] sram_rdata_a3,
    output reg [ADDR_WIDTH_A-1:0] sram_addr_a0,
    output reg [ADDR_WIDTH_A-1:0] sram_addr_a1,
    output reg [ADDR_WIDTH_A-1:0] sram_addr_a2,
    output reg [ADDR_WIDTH_A-1:0] sram_addr_a3,
    output [BW_PER_ADDR_A-1:0] sram_wdata_a0,
    output [BW_PER_ADDR_A-1:0] sram_wdata_a1,
    output [BW_PER_ADDR_A-1:0] sram_wdata_a2,
    output [BW_PER_ADDR_A-1:0] sram_wdata_a3,

    // sram B(32x32x1x64)
    output reg sram_wen_b0, // low enable
    output reg sram_wen_b1,
    output reg sram_wen_b2,
    output reg sram_wen_b3,
    input [BW_PER_ADDR_B-1:0] sram_rdata_b0,
    input [BW_PER_ADDR_B-1:0] sram_rdata_b1,
    input [BW_PER_ADDR_B-1:0] sram_rdata_b2,
    input [BW_PER_ADDR_B-1:0] sram_rdata_b3,
    output reg [ADDR_WIDTH_B-1:0] sram_addr_b0,
    output reg [ADDR_WIDTH_B-1:0] sram_addr_b1,
    output reg [ADDR_WIDTH_B-1:0] sram_addr_b2,
    output reg [ADDR_WIDTH_B-1:0] sram_addr_b3,
    output reg [BW_PER_ADDR_B-1:0] sram_wdata_b0,
    output reg [BW_PER_ADDR_B-1:0] sram_wdata_b1,
    output reg [BW_PER_ADDR_B-1:0] sram_wdata_b2,
    output reg [BW_PER_ADDR_B-1:0] sram_wdata_b3,

    // SRAM I(32x32x1x64)
    output reg sram_wen_i0, // low enable
    output reg sram_wen_i1,
    output reg sram_wen_i2,
    output reg sram_wen_i3,
    input [BW_PER_ADDR_I-1:0] sram_rdata_i0,
    input [BW_PER_ADDR_I-1:0] sram_rdata_i1,
    input [BW_PER_ADDR_I-1:0] sram_rdata_i2,
    input [BW_PER_ADDR_I-1:0] sram_rdata_i3,
    output reg [ADDR_WIDTH_I-1:0] sram_addr_i0,
    output reg [ADDR_WIDTH_I-1:0] sram_addr_i1,
    output reg [ADDR_WIDTH_I-1:0] sram_addr_i2,
    output reg [ADDR_WIDTH_I-1:0] sram_addr_i3,
    output reg [BW_PER_ADDR_I-1:0] sram_wdata_i0,
    output reg [BW_PER_ADDR_I-1:0] sram_wdata_i1,
    output reg [BW_PER_ADDR_I-1:0] sram_wdata_i2,
    output reg [BW_PER_ADDR_I-1:0] sram_wdata_i3,

    // SRAM U (64x32x1x64)
    output reg sram_wen_u0,
    output reg sram_wen_u1,
    output reg sram_wen_u2,
    output reg sram_wen_u3,
    input [BW_PER_ADDR_U-1:0] sram_rdata_u0,
    input [BW_PER_ADDR_U-1:0] sram_rdata_u1,
    input [BW_PER_ADDR_U-1:0] sram_rdata_u2,
    input [BW_PER_ADDR_U-1:0] sram_rdata_u3,
    output reg [ADDR_WIDTH_U-1:0] sram_addr_u0,
    output reg [ADDR_WIDTH_U-1:0] sram_addr_u1,
    output reg [ADDR_WIDTH_U-1:0] sram_addr_u2,
    output reg [ADDR_WIDTH_U-1:0] sram_addr_u3,
    output reg [BW_PER_ADDR_U-1:0] sram_wdata_u0,
    output reg [BW_PER_ADDR_U-1:0] sram_wdata_u1,
    output reg [BW_PER_ADDR_U-1:0] sram_wdata_u2,
    output reg [BW_PER_ADDR_U-1:0] sram_wdata_u3,

    // SRAM Z (64x32x1x64)
    output reg sram_wen_z0,
    output reg sram_wen_z1,
    output reg sram_wen_z2,
    output reg sram_wen_z3,
    input [BW_PER_ADDR_Z-1:0] sram_rdata_z0,
    input [BW_PER_ADDR_Z-1:0] sram_rdata_z1,
    input [BW_PER_ADDR_Z-1:0] sram_rdata_z2,
    input [BW_PER_ADDR_Z-1:0] sram_rdata_z3,
    output reg [ADDR_WIDTH_Z-1:0] sram_addr_z0,
    output reg [ADDR_WIDTH_Z-1:0] sram_addr_z1,
    output reg [ADDR_WIDTH_Z-1:0] sram_addr_z2,
    output reg [ADDR_WIDTH_Z-1:0] sram_addr_z3,
    output reg [BW_PER_ADDR_Z-1:0] sram_wdata_z0,
    output reg [BW_PER_ADDR_Z-1:0] sram_wdata_z1,
    output reg [BW_PER_ADDR_Z-1:0] sram_wdata_z2,
    output reg [BW_PER_ADDR_Z-1:0] sram_wdata_z3,

    // SRAM G (64x32x1x64)
    output reg sram_wen_g0,
    output reg sram_wen_g1,
    output reg sram_wen_g2,
    output reg sram_wen_g3,
    input [BW_PER_ADDR_G-1:0] sram_rdata_g0,
    input [BW_PER_ADDR_G-1:0] sram_rdata_g1,
    input [BW_PER_ADDR_G-1:0] sram_rdata_g2,
    input [BW_PER_ADDR_G-1:0] sram_rdata_g3,
    output reg [ADDR_WIDTH_G-1:0] sram_addr_g0,
    output reg [ADDR_WIDTH_G-1:0] sram_addr_g1,
    output reg [ADDR_WIDTH_G-1:0] sram_addr_g2,
    output reg [ADDR_WIDTH_G-1:0] sram_addr_g3,
    output reg [BW_PER_ADDR_G-1:0] sram_wdata_g0,
    output reg [BW_PER_ADDR_G-1:0] sram_wdata_g1,
    output reg [BW_PER_ADDR_G-1:0] sram_wdata_g2,
    output reg [BW_PER_ADDR_G-1:0] sram_wdata_g3,

    
    // SRAM E(32x32x1x128) - 16 banks
    output reg sram_wen_e0, sram_wen_e1, sram_wen_e2, sram_wen_e3,
    output reg sram_wen_e4, sram_wen_e5, sram_wen_e6, sram_wen_e7,
    output reg sram_wen_e8, sram_wen_e9, sram_wen_e10, sram_wen_e11,
    output reg sram_wen_e12, sram_wen_e13, sram_wen_e14, sram_wen_e15,
    input [BW_PER_ADDR_E-1:0] sram_rdata_e0, sram_rdata_e1, sram_rdata_e2, sram_rdata_e3,
    input [BW_PER_ADDR_E-1:0] sram_rdata_e4, sram_rdata_e5, sram_rdata_e6, sram_rdata_e7,
    input [BW_PER_ADDR_E-1:0] sram_rdata_e8, sram_rdata_e9, sram_rdata_e10, sram_rdata_e11,
    input [BW_PER_ADDR_E-1:0] sram_rdata_e12, sram_rdata_e13, sram_rdata_e14, sram_rdata_e15,
    output reg [ADDR_WIDTH_E-1:0] sram_addr_e0, sram_addr_e1, sram_addr_e2, sram_addr_e3,
    output reg [ADDR_WIDTH_E-1:0] sram_addr_e4, sram_addr_e5, sram_addr_e6, sram_addr_e7,
    output reg [ADDR_WIDTH_E-1:0] sram_addr_e8, sram_addr_e9, sram_addr_e10, sram_addr_e11,
    output reg [ADDR_WIDTH_E-1:0] sram_addr_e12, sram_addr_e13, sram_addr_e14, sram_addr_e15,
    output reg [BW_PER_ADDR_E-1:0] sram_wdata_e0, sram_wdata_e1, sram_wdata_e2, sram_wdata_e3,
    output reg [BW_PER_ADDR_E-1:0] sram_wdata_e4, sram_wdata_e5, sram_wdata_e6, sram_wdata_e7,
    output reg [BW_PER_ADDR_E-1:0] sram_wdata_e8, sram_wdata_e9, sram_wdata_e10, sram_wdata_e11,
    output reg [BW_PER_ADDR_E-1:0] sram_wdata_e12, sram_wdata_e13, sram_wdata_e14, sram_wdata_e15,

    // SRAM T(32x32x1x128) - 16 banks
    output reg sram_wen_t0, sram_wen_t1, sram_wen_t2, sram_wen_t3,
    output reg sram_wen_t4, sram_wen_t5, sram_wen_t6, sram_wen_t7,
    output reg sram_wen_t8, sram_wen_t9, sram_wen_t10, sram_wen_t11,
    output reg sram_wen_t12, sram_wen_t13, sram_wen_t14, sram_wen_t15,
    input [BW_PER_ADDR_T-1:0] sram_rdata_t0, sram_rdata_t1, sram_rdata_t2, sram_rdata_t3,
    input [BW_PER_ADDR_T-1:0] sram_rdata_t4, sram_rdata_t5, sram_rdata_t6, sram_rdata_t7,
    input [BW_PER_ADDR_T-1:0] sram_rdata_t8, sram_rdata_t9, sram_rdata_t10, sram_rdata_t11,
    input [BW_PER_ADDR_T-1:0] sram_rdata_t12, sram_rdata_t13, sram_rdata_t14, sram_rdata_t15,
    output reg [ADDR_WIDTH_T-1:0] sram_addr_t0, sram_addr_t1, sram_addr_t2, sram_addr_t3,
    output reg [ADDR_WIDTH_T-1:0] sram_addr_t4, sram_addr_t5, sram_addr_t6, sram_addr_t7,
    output reg [ADDR_WIDTH_T-1:0] sram_addr_t8, sram_addr_t9, sram_addr_t10, sram_addr_t11,
    output reg [ADDR_WIDTH_T-1:0] sram_addr_t12, sram_addr_t13, sram_addr_t14, sram_addr_t15,
    output reg [BW_PER_ADDR_T-1:0] sram_wdata_t0, sram_wdata_t1, sram_wdata_t2, sram_wdata_t3,
    output reg [BW_PER_ADDR_T-1:0] sram_wdata_t4, sram_wdata_t5, sram_wdata_t6, sram_wdata_t7,
    output reg [BW_PER_ADDR_T-1:0] sram_wdata_t8, sram_wdata_t9, sram_wdata_t10, sram_wdata_t11,
    output reg [BW_PER_ADDR_T-1:0] sram_wdata_t12, sram_wdata_t13, sram_wdata_t14, sram_wdata_t15,

    // SRAM C(32x32x1x128) - 16 banks
    output reg sram_wen_c0, sram_wen_c1, sram_wen_c2, sram_wen_c3,
    output reg sram_wen_c4, sram_wen_c5, sram_wen_c6, sram_wen_c7,
    output reg sram_wen_c8, sram_wen_c9, sram_wen_c10, sram_wen_c11,
    output reg sram_wen_c12, sram_wen_c13, sram_wen_c14, sram_wen_c15,
    input [BW_PER_ADDR_C-1:0] sram_rdata_c0, sram_rdata_c1, sram_rdata_c2, sram_rdata_c3,
    input [BW_PER_ADDR_C-1:0] sram_rdata_c4, sram_rdata_c5, sram_rdata_c6, sram_rdata_c7,
    input [BW_PER_ADDR_C-1:0] sram_rdata_c8, sram_rdata_c9, sram_rdata_c10, sram_rdata_c11,
    input [BW_PER_ADDR_C-1:0] sram_rdata_c12, sram_rdata_c13, sram_rdata_c14, sram_rdata_c15,
    output reg [ADDR_WIDTH_C-1:0] sram_addr_c0, sram_addr_c1, sram_addr_c2, sram_addr_c3,
    output reg [ADDR_WIDTH_C-1:0] sram_addr_c4, sram_addr_c5, sram_addr_c6, sram_addr_c7,
    output reg [ADDR_WIDTH_C-1:0] sram_addr_c8, sram_addr_c9, sram_addr_c10, sram_addr_c11,
    output reg [ADDR_WIDTH_C-1:0] sram_addr_c12, sram_addr_c13, sram_addr_c14, sram_addr_c15,
    output reg [BW_PER_ADDR_C-1:0] sram_wdata_c0, sram_wdata_c1, sram_wdata_c2, sram_wdata_c3,
    output reg [BW_PER_ADDR_C-1:0] sram_wdata_c4, sram_wdata_c5, sram_wdata_c6, sram_wdata_c7,
    output reg [BW_PER_ADDR_C-1:0] sram_wdata_c8, sram_wdata_c9, sram_wdata_c10, sram_wdata_c11,
    output reg [BW_PER_ADDR_C-1:0] sram_wdata_c12, sram_wdata_c13, sram_wdata_c14, sram_wdata_c15,

    // SRAM X (64x32x1x64)
    output reg sram_wen_x0,
    output reg sram_wen_x1,
    output reg sram_wen_x2,
    output reg sram_wen_x3,
    input [BW_PER_ADDR_X-1:0] sram_rdata_x0,
    input [BW_PER_ADDR_X-1:0] sram_rdata_x1,
    input [BW_PER_ADDR_X-1:0] sram_rdata_x2,
    input [BW_PER_ADDR_X-1:0] sram_rdata_x3,
    output reg [ADDR_WIDTH_X-1:0] sram_addr_x0,
    output reg [ADDR_WIDTH_X-1:0] sram_addr_x1,
    output reg [ADDR_WIDTH_X-1:0] sram_addr_x2,
    output reg [ADDR_WIDTH_X-1:0] sram_addr_x3,
    output reg [BW_PER_ADDR_X-1:0] sram_wdata_x0,
    output reg [BW_PER_ADDR_X-1:0] sram_wdata_x1,
    output reg [BW_PER_ADDR_X-1:0] sram_wdata_x2,
    output reg [BW_PER_ADDR_X-1:0] sram_wdata_x3,

    // SRAM W(64x32x1x64)
    output reg sram_wen_w0,
    output reg sram_wen_w1,
    output reg sram_wen_w2,
    output reg sram_wen_w3,
    input [BW_PER_ADDR_W-1:0] sram_rdata_w0,
    input [BW_PER_ADDR_W-1:0] sram_rdata_w1,
    input [BW_PER_ADDR_W-1:0] sram_rdata_w2,
    input [BW_PER_ADDR_W-1:0] sram_rdata_w3,
    output reg [ADDR_WIDTH_W-1:0] sram_addr_w0,
    output reg [ADDR_WIDTH_W-1:0] sram_addr_w1,
    output reg [ADDR_WIDTH_W-1:0] sram_addr_w2,
    output reg [ADDR_WIDTH_W-1:0] sram_addr_w3,
    output reg [BW_PER_ADDR_W-1:0] sram_wdata_w0,
    output reg [BW_PER_ADDR_W-1:0] sram_wdata_w1,
    output reg [BW_PER_ADDR_W-1:0] sram_wdata_w2,
    output reg [BW_PER_ADDR_W-1:0] sram_wdata_w3,

    // SRAM D
    output reg sram_wen_d0,
    output reg sram_wen_d1,
    output reg sram_wen_d2,
    output reg sram_wen_d3,
    input [BW_PER_ADDR_D-1:0] sram_rdata_d0,
    input [BW_PER_ADDR_D-1:0] sram_rdata_d1,
    input [BW_PER_ADDR_D-1:0] sram_rdata_d2,
    input [BW_PER_ADDR_D-1:0] sram_rdata_d3,
    output reg [ADDR_WIDTH_D-1:0] sram_addr_d0,
    output reg [ADDR_WIDTH_D-1:0] sram_addr_d1,
    output reg [ADDR_WIDTH_D-1:0] sram_addr_d2,
    output reg [ADDR_WIDTH_D-1:0] sram_addr_d3,
    output reg [BW_PER_ADDR_D-1:0] sram_wdata_d0,
    output reg [BW_PER_ADDR_D-1:0] sram_wdata_d1,
    output reg [BW_PER_ADDR_D-1:0] sram_wdata_d2,
    output reg [BW_PER_ADDR_D-1:0] sram_wdata_d3,

    // Twiddle ROM interface (16 banks)
    output wire [0:0] twiddle_addr_0, twiddle_addr_1, twiddle_addr_2, twiddle_addr_3,
    output wire [0:0] twiddle_addr_4, twiddle_addr_5, twiddle_addr_6, twiddle_addr_7,
    output wire [0:0] twiddle_addr_8, twiddle_addr_9, twiddle_addr_10, twiddle_addr_11,
    output wire [0:0] twiddle_addr_12, twiddle_addr_13, twiddle_addr_14, twiddle_addr_15,
    input [2*pFP_WIDTH-1:0] twiddle_data_0, twiddle_data_1, twiddle_data_2, twiddle_data_3,
    input [2*pFP_WIDTH-1:0] twiddle_data_4, twiddle_data_5, twiddle_data_6, twiddle_data_7,
    input [2*pFP_WIDTH-1:0] twiddle_data_8, twiddle_data_9, twiddle_data_10, twiddle_data_11,
    input [2*pFP_WIDTH-1:0] twiddle_data_12, twiddle_data_13, twiddle_data_14, twiddle_data_15
);

// ===== problem ===== //
// 1. The enable should only pull up one cycle
//    since we may need to test multiple patch

// ========================================================== //
// ===                   signal declar                    === //
// ========================================================== //
// ----- top state ----- //
reg [6:0] top_state;
reg [6:0] top_state_n;
// ----- read sram a ----- //
reg [(ADDR_WIDTH_A-1):0] sram_a_addr;
reg [(ADDR_WIDTH_A-1):0] sram_a_addr_n;
wire [7:0] R[0:3];
wire [7:0] G[0:3];
wire [7:0] B[0:3];
reg valid_1;
wire fp_valid[0:3];
wire [(pFP_WIDTH-1):0] fp_out[0:3];
reg [7:0] max_sel[0:3];
// ----- write sram i ----- //
reg [(ADDR_WIDTH_A-1):0] sram_i_addr;
reg [(ADDR_WIDTH_A-1):0] sram_i_addr_n;
// ----- write sram b ----- //
reg [(ADDR_WIDTH_A-1):0] sram_b_addr;
reg [(ADDR_WIDTH_A-1):0] sram_b_addr_n;
// ----- read sram z ----- //
reg [(ADDR_WIDTH_Z-1):0] sram_z_addr;
reg [(ADDR_WIDTH_Z-1):0] sram_z_addr_n;
// ----- write sram u ----- //
reg [(pFP_WIDTH-1):0] mu;
reg [(pFP_WIDTH-1):0] mu_recip;
reg [(ADDR_WIDTH_U-1):0] sram_u_addr;
reg [(ADDR_WIDTH_U-1):0] sram_u_addr_n;
// ----- computation resource ----- //
reg [(pINT_WIDTH-1):0] int2fp_in_int[0:3];
reg int2fp_in_valid[0:3];
wire int2fp_out_valid[0:3];
wire [(pFP_WIDTH-1):0]int2fp_out_fp[0:3];

reg [(2*pFP_WIDTH-1):0] mul0_ina;
reg [(2*pFP_WIDTH-1):0] mul0_inb;
reg [1:0]mul0_mode;
reg mul0_in_valid;
wire [(2*pFP_WIDTH-1):0] mul0_out;
wire mul0_out_valid;

reg [(2*pFP_WIDTH-1):0] mul1_ina;
reg [(2*pFP_WIDTH-1):0] mul1_inb;
reg [1:0]mul1_mode;
reg mul1_in_valid;
wire [(2*pFP_WIDTH-1):0] mul1_out;
wire mul1_out_valid;

reg [(pFP_WIDTH-1):0] add_ina   [0:7];
reg [(pFP_WIDTH-1):0] add_inb   [0:7];
reg                   add_in_valid [0:7];
wire [(pFP_WIDTH-1):0] add_result[0:7];
wire                   add_out_valid[0:7];
// ----- multrans addr gen ----- //
reg [3:0] cnt16_x;
reg [(ADDR_WIDTH_G-2):0] base_addr_x;
reg [(ADDR_WIDTH_G-1):0] trans_addr_x;
reg [(ADDR_WIDTH_G-1):0] trans_addr_x_n;
wire [(ADDR_WIDTH_G-1):0] mul_trans_addr_x;
reg phase;

reg trans_flag_x;
reg [(ADDR_WIDTH_G-1):0] sram_g_addr;
reg [(ADDR_WIDTH_G-1):0] sram_g_addr_n;
reg valid_4;
reg phase_d1;
reg phase_d2;
reg phase_d3;
reg phase_d4;
reg phase_d5;
reg phase_d6;
reg phase_d7;
reg store_en; // low en
reg [(pFP_WIDTH-1):0] g_minus_zmu_reg [0:3];
reg [(pFP_WIDTH-1):0] last_g_minus_zmu_reg;
reg [(ADDR_WIDTH_X-1):0] sram_x_addr;
reg [(ADDR_WIDTH_X-1):0] sram_x_addr_n;

reg  [3:0]  cnt16_y;                   
reg [(ADDR_WIDTH_X-1):0]  mul_trans_addr_y;
reg  [(ADDR_WIDTH_X-1):0]  mul_trans_addr_y_n;
reg         trans_flag_y; 
reg phase_y_r;  
reg trans_flag_y_n;
reg trans_flag_y_d1;

// delGy addr generator
reg [(ADDR_WIDTH_X-1):0] sram_x_delgy_addr;
reg [(ADDR_WIDTH_X-1):0] sram_x_delgy_addr_n;
wire rowoneblock;
reg [3:0]cnt16_2;
reg [4:0]cnt32;
reg phase_sramx_waddr;
reg phase_sramx_bank;

reg valid_5;
reg phase_y_w;

// pre-fft, read sram x
reg [(ADDR_WIDTH_X-2):0] sram_x_raddr_8b;
reg sram_x_raddr_msb;
wire [(ADDR_WIDTH_X-1):0]sram_x_raddr;

// pre-fft, write sram e
reg [1:0]cnt4; 
reg [(ADDR_WIDTH_E-1):0] sram_e_addr;
reg [(ADDR_WIDTH_E-1):0] sram_e_addr_n;
reg valid_7;

// FFT 
reg fft_mode;
wire fft_done;
reg fft_start;
// FFT module (DUT) output signals - 16 banks
// SRAM-E
wire sramA_csb_dut;
wire sramA_wsb_0_dut, sramA_wsb_1_dut, sramA_wsb_2_dut, sramA_wsb_3_dut, sramA_wsb_4_dut, sramA_wsb_5_dut, sramA_wsb_6_dut, sramA_wsb_7_dut;
wire sramA_wsb_8_dut, sramA_wsb_9_dut, sramA_wsb_10_dut, sramA_wsb_11_dut, sramA_wsb_12_dut, sramA_wsb_13_dut, sramA_wsb_14_dut, sramA_wsb_15_dut;
wire [(2*pFP_WIDTH-1):0] sramA_wdata_0_dut, sramA_wdata_1_dut, sramA_wdata_2_dut, sramA_wdata_3_dut, sramA_wdata_4_dut, sramA_wdata_5_dut, sramA_wdata_6_dut, sramA_wdata_7_dut;
wire [(2*pFP_WIDTH-1):0] sramA_wdata_8_dut, sramA_wdata_9_dut, sramA_wdata_10_dut, sramA_wdata_11_dut, sramA_wdata_12_dut, sramA_wdata_13_dut, sramA_wdata_14_dut, sramA_wdata_15_dut;
wire [ADDR_WIDTH_E-1:0] sramA_addr_0_dut, sramA_addr_1_dut, sramA_addr_2_dut, sramA_addr_3_dut, sramA_addr_4_dut, sramA_addr_5_dut, sramA_addr_6_dut, sramA_addr_7_dut;
wire [ADDR_WIDTH_E-1:0] sramA_addr_8_dut, sramA_addr_9_dut, sramA_addr_10_dut, sramA_addr_11_dut, sramA_addr_12_dut, sramA_addr_13_dut, sramA_addr_14_dut, sramA_addr_15_dut;
// SRAM-T
wire sramB_csb_dut;
wire sramB_wsb_0_dut, sramB_wsb_1_dut, sramB_wsb_2_dut, sramB_wsb_3_dut, sramB_wsb_4_dut, sramB_wsb_5_dut, sramB_wsb_6_dut, sramB_wsb_7_dut;
wire sramB_wsb_8_dut, sramB_wsb_9_dut, sramB_wsb_10_dut, sramB_wsb_11_dut, sramB_wsb_12_dut, sramB_wsb_13_dut, sramB_wsb_14_dut, sramB_wsb_15_dut;
wire [(2*pFP_WIDTH-1):0] sramB_wdata_0_dut, sramB_wdata_1_dut, sramB_wdata_2_dut, sramB_wdata_3_dut, sramB_wdata_4_dut, sramB_wdata_5_dut, sramB_wdata_6_dut, sramB_wdata_7_dut;
wire [(2*pFP_WIDTH-1):0] sramB_wdata_8_dut, sramB_wdata_9_dut, sramB_wdata_10_dut, sramB_wdata_11_dut, sramB_wdata_12_dut, sramB_wdata_13_dut, sramB_wdata_14_dut, sramB_wdata_15_dut;
wire [ADDR_WIDTH_T-1:0] sramB_addr_0_dut, sramB_addr_1_dut, sramB_addr_2_dut, sramB_addr_3_dut, sramB_addr_4_dut, sramB_addr_5_dut, sramB_addr_6_dut, sramB_addr_7_dut;
wire [ADDR_WIDTH_T-1:0] sramB_addr_8_dut, sramB_addr_9_dut, sramB_addr_10_dut, sramB_addr_11_dut, sramB_addr_12_dut, sramB_addr_13_dut, sramB_addr_14_dut, sramB_addr_15_dut;

// Mul interfaces 
// BPE 0 mul interface (128-bit: 64-bit real + 64-bit imag)
wire [(2*pFP_WIDTH-1):0] bpe0_mul_in_A;
wire [(2*pFP_WIDTH-1):0] bpe0_mul_in_B;
wire [1:0]   bpe0_mul_mode;
wire         bpe0_mul_in_valid;
wire [(2*pFP_WIDTH-1):0] bpe0_mul_result_c;
wire [(2*pFP_WIDTH-1):0] bpe0_mul_result_int;
wire         bpe0_mul_out_valid;

// BPE 1 mul interface (128-bit: 64-bit real + 64-bit imag)
wire [(2*pFP_WIDTH-1):0] bpe1_mul_in_A;
wire [(2*pFP_WIDTH-1):0] bpe1_mul_in_B;
wire [1:0]   bpe1_mul_mode;
wire         bpe1_mul_in_valid;
wire [(2*pFP_WIDTH-1):0] bpe1_mul_result_c;
wire [(2*pFP_WIDTH-1):0] bpe1_mul_result_int;
wire         bpe1_mul_out_valid;

// FP_ADD interfaces (from testbench, 4 per bpe, total 8)
// BPE 0 fp_add interfaces
wire [(pFP_WIDTH-1):0]  bpe0_fp_add_01_in_A, bpe0_fp_add_01_in_B;
wire         bpe0_fp_add_01_in_valid;
wire [(pFP_WIDTH-1):0]  bpe0_fp_add_01_result;
wire         bpe0_fp_add_01_out_valid;

wire [(pFP_WIDTH-1):0]  bpe0_fp_add_02_in_A, bpe0_fp_add_02_in_B;
wire         bpe0_fp_add_02_in_valid;
wire [(pFP_WIDTH-1):0]  bpe0_fp_add_02_result;
wire         bpe0_fp_add_02_out_valid;

wire [(pFP_WIDTH-1):0]  bpe0_fp_add_11_in_A, bpe0_fp_add_11_in_B;
wire         bpe0_fp_add_11_in_valid;
wire [(pFP_WIDTH-1):0]  bpe0_fp_add_11_result;
wire         bpe0_fp_add_11_out_valid;

wire [(pFP_WIDTH-1):0]  bpe0_fp_add_12_in_A, bpe0_fp_add_12_in_B;
wire         bpe0_fp_add_12_in_valid;
wire [(pFP_WIDTH-1):0]  bpe0_fp_add_12_result;
wire         bpe0_fp_add_12_out_valid;

// BPE 1 fp_add interfaces
wire [(pFP_WIDTH-1):0]  bpe1_fp_add_01_in_A, bpe1_fp_add_01_in_B;
wire         bpe1_fp_add_01_in_valid;
wire [(pFP_WIDTH-1):0]  bpe1_fp_add_01_result;
wire         bpe1_fp_add_01_out_valid;

wire [(pFP_WIDTH-1):0]  bpe1_fp_add_02_in_A, bpe1_fp_add_02_in_B;
wire         bpe1_fp_add_02_in_valid;
wire [(pFP_WIDTH-1):0]  bpe1_fp_add_02_result;
wire         bpe1_fp_add_02_out_valid;

wire [(pFP_WIDTH-1):0]  bpe1_fp_add_11_in_A, bpe1_fp_add_11_in_B;
wire         bpe1_fp_add_11_in_valid;
wire [(pFP_WIDTH-1):0]  bpe1_fp_add_11_result;
wire         bpe1_fp_add_11_out_valid;

wire [(pFP_WIDTH-1):0]  bpe1_fp_add_12_in_A, bpe1_fp_add_12_in_B;
wire         bpe1_fp_add_12_in_valid;
wire [(pFP_WIDTH-1):0]  bpe1_fp_add_12_result;
wire         bpe1_fp_add_12_out_valid;

// ----- read sram D
reg [(ADDR_WIDTH_D-1):0] sram_d_addr;
reg [(ADDR_WIDTH_D-1):0] sram_d_addr_n;
reg valid_8;
reg valid_8_n;
// ===== top state ===== //


localparam IDLE      = 7'd0;
localparam RGB_MAX   = 7'd1;
localparam RGB_MAX_t = 7'd2;
localparam NORMAL    = 7'd3;
localparam NORMAL_t  = 7'd4;
localparam Z_DIV_U   = 7'd5;
localparam Z_DIV_U_t = 7'd6;
localparam WRITE_X1  = 7'd7;
localparam WRITE_X1_t= 7'd8;
localparam WRITE_X2  = 7'd9;
localparam WRITE_X2_t= 7'd10;
localparam PRE_FFT   = 7'd11;
localparam PRE_FFT_t = 7'd12;
localparam FFT       = 7'd13;
localparam FFT_D     = 7'd14;
localparam FFT_D_t   = 7'd15;
localparam iFFT      = 7'd18;
localparam DONE      = 7'd20;

always @(*) begin
    case (top_state)
        IDLE: begin
            if (enable) begin
                top_state_n = RGB_MAX;
            end else begin
                top_state_n = IDLE;
            end
        end 
        RGB_MAX: begin
            if (sram_a_addr == 8'd255) begin
                top_state_n = RGB_MAX_t;
            end else begin
                top_state_n = RGB_MAX;
            end
        end
        RGB_MAX_t: begin
            if (sram_i_addr == 8'd255) begin
                top_state_n = NORMAL;
            end else begin
                top_state_n = RGB_MAX_t;
            end
        end
        NORMAL: begin
            if (sram_i_addr == 8'd255) begin
                top_state_n = NORMAL_t;
            end else begin
                top_state_n = NORMAL;
            end
        end
        NORMAL_t: begin
            if (sram_b_addr == 8'd255) begin
                top_state_n = Z_DIV_U;
            end else begin
                top_state_n = NORMAL_t;
            end
        end
        Z_DIV_U: begin
            if (sram_z_addr == 9'd511) begin
                top_state_n = Z_DIV_U_t;
            end else begin
                top_state_n = Z_DIV_U;
            end
        end
        Z_DIV_U_t: begin
            if (sram_u_addr == 9'd511) begin
                top_state_n = WRITE_X1;
            end else begin
                top_state_n = Z_DIV_U_t;
            end
        end
        WRITE_X1: begin
            if (trans_flag_x && mul_trans_addr_x == 9'd256) begin
                top_state_n = WRITE_X1_t;
            end else begin
                top_state_n = WRITE_X1;
            end
        end
        WRITE_X1_t: begin
            if (sram_x_addr == 1'b0 && sram_wen_x0 == 1'b0 && trans_flag_x == 1'b1) begin
                top_state_n = WRITE_X2;
            end else begin
                top_state_n = WRITE_X1_t;
            end
        end
        WRITE_X2: begin
            if (mul_trans_addr_y == 9'd511 && phase_y_r == 1'b1) begin
                top_state_n = WRITE_X2_t;
            end else begin
                top_state_n = WRITE_X2;
            end
        end
        WRITE_X2_t: begin
            if (phase_y_w == 1'b1 && phase_sramx_waddr && sram_x_delgy_addr == 9'd511) begin
                top_state_n = PRE_FFT;
            end else begin
                top_state_n = WRITE_X2_t;
            end
        end
        PRE_FFT: begin
            if (sram_x_raddr == 9'd511) begin
                top_state_n = PRE_FFT_t;
            end else begin
                top_state_n = PRE_FFT;
            end
        end
        PRE_FFT_t: begin
            if (sram_e_addr == 6'd63 && sram_wen_e15 == 1'b0) begin
                top_state_n = FFT;
            end else begin
                top_state_n = PRE_FFT_t;
            end
        end
        FFT: begin
            if (fft_done) begin
                top_state_n = FFT_D;
            end else begin
                top_state_n = FFT;
            end
        end
        FFT_D: begin
            if (sram_d_addr == 8'd255) begin
                top_state_n = FFT_D_t;
            end else begin
                top_state_n = FFT_D;
            end
        end
        FFT_D_t: begin
            if (sram_e_addr == 6'd63 && sram_wen_e15 == 1'b0) begin
                top_state_n = DONE;
            end else begin
                top_state_n = FFT_D_t;
            end
        end
        DONE: begin
            top_state_n = DONE;
        end
        default: begin
            top_state_n = top_state;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        top_state <= IDLE;
    end else begin
        top_state <= top_state_n;
    end
end

// ----- debug done ----- //
reg [10:0] done_cnt;
always @(posedge clk) begin
    if (!rst_n) begin
        done_cnt <= 0;
    end else if (top_state == DONE) begin
        done_cnt <= done_cnt + 1;
    end
end
assign done = (done_cnt == 10'd10)? 1:0;

// ===== stage 1 ===== //
// SRAM A(32x32x3x8) store the original bmp file
// each memory entry have 3-byte(RGB) with 4-bank memory access

// > addr0: 
// bank0 = (0, 0)
// bank1 = (1, 0)
// bank2 = (2, 0)
// bank3 = (3, 0)
// > addr1: 
// bank0 = (4, 0)
// bank1 = (5, 0)
// bank2 = (6, 0)
// bank3 = (7, 0)
// ...
// > addr7:
// bank0 = (28, 0)
// bank1 = (29, 0)
// bank2 = (30, 0)
// bank3 = (31, 0)
// > addr8: 
// bank0 = (0, 1)
// bank1 = (1, 1)
// bank2 = (2, 1)
// bank3 = (3, 1)
// ...
// > addr256:
// bank0 = (28, 31)
// bank1 = (29, 31)
// bank2 = (30, 31)
// bank3 = (31, 31)

// function:
// read SRAM A, choose the max{RGB} and trans to fp64
// write the result into SRAM I.

always @(*) begin
    case (top_state)
        RGB_MAX: begin
            sram_a_addr_n = sram_a_addr + 1;
        end 
        default: begin
            sram_a_addr_n = 0;
        end
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sram_a_addr <= 0;
    end else begin
        sram_a_addr <= sram_a_addr_n;
    end
end

always @(*) begin
    case (top_state)
        RGB_MAX: begin
            sram_wen_a0 = 1'b1;
            sram_wen_a1 = 1'b1;
            sram_wen_a2 = 1'b1;
            sram_wen_a3 = 1'b1;
            sram_addr_a0 = sram_a_addr;
            sram_addr_a1 = sram_a_addr;
            sram_addr_a2 = sram_a_addr;
            sram_addr_a3 = sram_a_addr;
        end 
        default: begin
            sram_wen_a0 = 1'b1;
            sram_wen_a1 = 1'b1;
            sram_wen_a2 = 1'b1;
            sram_wen_a3 = 1'b1;
            sram_addr_a0 = 0;
            sram_addr_a1 = 0;
            sram_addr_a2 = 0;
            sram_addr_a3 = 0;
        end
    endcase    
end



assign R[0] = sram_rdata_a0[23:16];
assign G[0] = sram_rdata_a0[15:8 ];
assign B[0] = sram_rdata_a0[7 :0 ];

assign R[1] = sram_rdata_a1[23:16];
assign G[1] = sram_rdata_a1[15:8 ];
assign B[1] = sram_rdata_a1[7 :0 ];

assign R[2] = sram_rdata_a2[23:16];
assign G[2] = sram_rdata_a2[15:8 ];
assign B[2] = sram_rdata_a2[7 :0 ];

assign R[3] = sram_rdata_a3[23:16];
assign G[3] = sram_rdata_a3[15:8 ];
assign B[3] = sram_rdata_a3[7 :0 ];


integer i;
always @(*) begin
    for (i=0; i<4; i=i+1) begin
        if (R[i] > G[i]) begin // R > G
            if (R[i] > B[i]) begin
                max_sel[i] = R[i]; // R > B
            end else begin 
                max_sel[i] = B[i]; // B > R
            end
        end else begin // R < G
            if (G[i] > B[i]) begin
                max_sel[i] = G[i]; // G > B
            end else begin
                max_sel[i] = B[i]; // B > G
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_1 <= 0;
    end else if (top_state == RGB_MAX) begin
        valid_1 <= 1;
    end else begin
        valid_1 <= 0;
    end
end

// ----- write SRAM I ----- //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sram_i_addr <= 0;
    end else begin
        sram_i_addr <= sram_i_addr_n;
    end
end
always @(*) begin
    case (top_state)
        RGB_MAX, RGB_MAX_t, NORMAL: begin
            sram_addr_i0 = sram_i_addr;
            sram_addr_i1 = sram_i_addr;
            sram_addr_i2 = sram_i_addr;
            sram_addr_i3 = sram_i_addr;
        end 
        default: begin
            sram_addr_i0 = 0;
            sram_addr_i1 = 0;
            sram_addr_i2 = 0;
            sram_addr_i3 = 0;
        end
    endcase
    
end

always @(*) begin
    sram_wdata_i0 = int2fp_out_fp[0];
    sram_wdata_i1 = int2fp_out_fp[1];
    sram_wdata_i2 = int2fp_out_fp[2];
    sram_wdata_i3 = int2fp_out_fp[3];
    case (top_state)
        RGB_MAX, RGB_MAX_t: begin
            if (int2fp_out_valid[0] && (top_state == RGB_MAX || top_state == RGB_MAX_t)) begin
                sram_i_addr_n = sram_i_addr + 1;
                sram_wen_i0 = 1'b0;
                sram_wen_i1 = 1'b0;
                sram_wen_i2 = 1'b0;
                sram_wen_i3 = 1'b0;
            end else begin
                sram_i_addr_n = sram_i_addr;
                sram_wen_i0 = 1'b1;
                sram_wen_i1 = 1'b1;
                sram_wen_i2 = 1'b1;
                sram_wen_i3 = 1'b1;
            end
        end 
        NORMAL: begin
            sram_i_addr_n = sram_i_addr + 1;
            sram_wen_i0 = 1'b1;
            sram_wen_i1 = 1'b1;
            sram_wen_i2 = 1'b1;
            sram_wen_i3 = 1'b1;
        end
        default: begin
            sram_i_addr_n = 0;
            sram_wen_i0 = 1'b1;
            sram_wen_i1 = 1'b1;
            sram_wen_i2 = 1'b1;
            sram_wen_i3 = 1'b1;
        end
    endcase
end

// ===== stage 2 ===== //
// in this stage, we normalize the data in SRAM I 
// 1/255 = 0.00392156862745098 = 64'h3f7064dd2f1a9fbe
// note that the address controll is in the previos
// code
// then we write the result into SRAM-B.
localparam recip_255 = 64'h3f70101010101010;

// SRAM I read out date valid
reg valid_2;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_2 <= 0;
    end else if (top_state == NORMAL) begin
        valid_2 <= 1;
    end else begin
        valid_2 <= 0;
    end
end

// ----- write SRAM B ----- //

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sram_b_addr <= 0;
    end else begin
        sram_b_addr <= sram_b_addr_n;
    end
end
always @(*) begin
    sram_wdata_b0 = mul0_out[(2*pFP_WIDTH-1):(pFP_WIDTH)];
    sram_wdata_b1 = mul0_out[(pFP_WIDTH-1):0];
    sram_wdata_b2 = mul1_out[(2*pFP_WIDTH-1):(pFP_WIDTH)];
    sram_wdata_b3 = mul1_out[(pFP_WIDTH-1):0];
    case (top_state)
        NORMAL, NORMAL_t: begin
            if (mul0_out_valid && mul1_out_valid) begin
                sram_b_addr_n = sram_b_addr + 1;
                sram_wen_b0 = 1'b0;
                sram_wen_b1 = 1'b0;
                sram_wen_b2 = 1'b0;
                sram_wen_b3 = 1'b0;
                sram_addr_b0 = sram_b_addr;
                sram_addr_b1 = sram_b_addr;
                sram_addr_b2 = sram_b_addr;
                sram_addr_b3 = sram_b_addr;
            end else begin
                sram_b_addr_n = sram_b_addr;
                sram_wen_b0 = 1'b1;
                sram_wen_b1 = 1'b1;
                sram_wen_b2 = 1'b1;
                sram_wen_b3 = 1'b1;
                sram_addr_b0 = 0;
                sram_addr_b1 = 0;
                sram_addr_b2 = 0;
                sram_addr_b3 = 0;
            end
        end 
        PRE_FFT, PRE_FFT_t: begin
            if (mul0_out_valid && mul1_out_valid) begin
                sram_b_addr_n = sram_b_addr + 1;
                sram_wen_b0 = 1'b1;
                sram_wen_b1 = 1'b1;
                sram_wen_b2 = 1'b1;
                sram_wen_b3 = 1'b1;
            end else begin
                sram_b_addr_n = sram_b_addr;
                sram_wen_b0 = 1'b1;
                sram_wen_b1 = 1'b1;
                sram_wen_b2 = 1'b1;
                sram_wen_b3 = 1'b1;
            end
            sram_addr_b0 = sram_b_addr;
            sram_addr_b1 = sram_b_addr;
            sram_addr_b2 = sram_b_addr;
            sram_addr_b3 = sram_b_addr;
        end
        default: begin
            sram_b_addr_n = 0;
            sram_wen_b0 = 1'b1;
            sram_wen_b1 = 1'b1;
            sram_wen_b2 = 1'b1;
            sram_wen_b3 = 1'b1;
            sram_addr_b0 = 0;
            sram_addr_b1 = 0;
            sram_addr_b2 = 0;
            sram_addr_b3 = 0;
        end
    endcase
end

// ===== stage 3 ===== //
// In this stage, we construct the weight matrix
// we take delT operation and store the result into SRAM W
// the size of SRAM W is 64x32x64
// this step needs fp_recip module(waiting for it).

// ===== stage 4 ===== //
// read SRAM Z(64x32x1x64) and then devided by mu
// write into SRAM U(64x32x1x64)



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mu <= mu0;
        mu_recip <= mu0_recip;
    end else begin // may be update at last stage
        mu <= mu0;
        mu_recip <= mu0_recip; 
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sram_z_addr <= 0;
    end else begin
        sram_z_addr <= sram_z_addr_n;
    end
end

always @(*) begin
    case (top_state)
        Z_DIV_U: begin
            sram_z_addr_n = sram_z_addr + 1;
            sram_wen_z0 = 1'b1;
            sram_wen_z1 = 1'b1;
            sram_wen_z2 = 1'b1;
            sram_wen_z3 = 1'b1;
            sram_addr_z0 = sram_z_addr;
            sram_addr_z1 = sram_z_addr;
            sram_addr_z2 = sram_z_addr;
            sram_addr_z3 = sram_z_addr;
        end 
        default: begin
            sram_z_addr_n = 0;
            sram_wen_z0 = 1'b1;
            sram_wen_z1 = 1'b1;
            sram_wen_z2 = 1'b1;
            sram_wen_z3 = 1'b1;
            sram_addr_z0 = 0;
            sram_addr_z1 = 0;
            sram_addr_z2 = 0;
            sram_addr_z3 = 0;
        end
    endcase
end

reg valid_3;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_3 <= 0;
    end else if (top_state == Z_DIV_U) begin
        valid_3 <= 1;
    end else begin
        valid_3 <= 0;
    end
end

// write u
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sram_u_addr <= 0;
    end else begin
        sram_u_addr <= sram_u_addr_n;
    end
end

always @(*) begin
    case (top_state)
        Z_DIV_U, Z_DIV_U_t: begin
            sram_addr_u0 = sram_u_addr;
            sram_addr_u1 = sram_u_addr;
            sram_addr_u2 = sram_u_addr;
            sram_addr_u3 = sram_u_addr;
            if (mul0_out_valid && mul1_out_valid) begin
                sram_u_addr_n = sram_u_addr + 1;
                sram_wen_u0 = 1'b0;
                sram_wen_u1 = 1'b0;
                sram_wen_u2 = 1'b0;
                sram_wen_u3 = 1'b0;
            end else begin
                sram_u_addr_n = sram_u_addr;
                sram_wen_u0 = 1'b1;
                sram_wen_u1 = 1'b1;
                sram_wen_u2 = 1'b1;
                sram_wen_u3 = 1'b1;
            end
            sram_wdata_u0 = mul0_out[(2*pFP_WIDTH-1):pFP_WIDTH];
            sram_wdata_u1 = mul0_out[(pFP_WIDTH-1):0];
            sram_wdata_u2 = mul1_out[(2*pFP_WIDTH-1):pFP_WIDTH];
            sram_wdata_u3 = mul1_out[(pFP_WIDTH-1):0];
        end 
        WRITE_X1: begin
            sram_addr_u0 = mul_trans_addr_x;
            sram_addr_u1 = mul_trans_addr_x;
            sram_addr_u2 = mul_trans_addr_x;
            sram_addr_u3 = mul_trans_addr_x;
            sram_u_addr_n = 0;
            sram_wen_u0 = 1'b1;
            sram_wen_u1 = 1'b1;
            sram_wen_u2 = 1'b1;
            sram_wen_u3 = 1'b1;
            sram_wdata_u0 = 0;
            sram_wdata_u1 = 0;
            sram_wdata_u2 = 0;
            sram_wdata_u3 = 0;
        end
        WRITE_X2: begin
            sram_addr_u0 = mul_trans_addr_y;
            sram_addr_u1 = mul_trans_addr_y;
            sram_addr_u2 = mul_trans_addr_y;
            sram_addr_u3 = mul_trans_addr_y;
            sram_u_addr_n = 0;
            sram_wen_u0 = 1'b1;
            sram_wen_u1 = 1'b1;
            sram_wen_u2 = 1'b1;
            sram_wen_u3 = 1'b1;
            sram_wdata_u0 = 0;
            sram_wdata_u1 = 0;
            sram_wdata_u2 = 0;
            sram_wdata_u3 = 0;
        end
        default: begin
            sram_addr_u0 = 0;
            sram_addr_u1 = 0;
            sram_addr_u2 = 0;
            sram_addr_u3 = 0;
            sram_u_addr_n = 0;
            sram_wen_u0 = 1'b1;
            sram_wen_u1 = 1'b1;
            sram_wen_u2 = 1'b1;
            sram_wen_u3 = 1'b1;
            sram_wdata_u0 = 0;
            sram_wdata_u1 = 0;
            sram_wdata_u2 = 0;
            sram_wdata_u3 = 0;
        end 
    endcase
end

// ===== stage 5 ===== //
// read SRAM U(64x32x1x64) and SRAM G(64x32x1x64)
// do G - U and D^T operation
// G - U is 64x32 matrix, we split it to two region
// left-side Gx 64x16 matrix, right side Gy 64x16 matrix
// note that the above two matrix need to be reshape into 
// 32x32 by column-major.
// for example:
// Gx: 
// mat64-col0  -> mat32-col0 and mat32-col1
// mat64-col1  -> mat32-col2 and mat32 col3
// ...
// mat64-col15 -> mat32-col30 and mat32-col31
// Gy
// mat64-col16 -> mat32-col0 and mat32-col1
// ...
// mat64-col30 -> mat32-col60 and mat32-col61
// mat64-col31 -> mat32-col62 and mat32-col63
// we multiply a 1st order differential matrix in py
// this operation may be reduce to col-wise or row-wise deviation.
// 1. delGx = Gx @ Dx 
// 2. delGy = Dy @ altGy 

// 1. delGx
// read SRAM U
// read SRAM G
// read mem addr access:
// 0 -> 256 -> 1 -> 257 -> 2 -> 258 -> 3 -> 259
// 8 -> 264 -> 9 -> 265 -> 10 -> 266 -> 11 -> 267 (+8)
// 16 -> 272 -> 17 -> 273 -> 18 -> 274 -> 19 -> 275 (+16)
// ... 
// 248 -> 504 -> 249 -> 505 -> 250 -> 506 -> 251 -> 507
// (pull up flag)-> 0 -> 256 -> finish


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        trans_flag_x <= 0;
    end else if (mul_trans_addr_x == 9'd507 && phase == 1'b1) begin
        trans_flag_x <= 1;
    end else if (top_state != WRITE_X1 && top_state != WRITE_X1_t) begin
        trans_flag_x <= 0;
    end else begin
        trans_flag_x <= trans_flag_x;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (top_state == WRITE_X1) begin
        cnt16_x <= cnt16_x + 1;
        base_addr_x <= (cnt16_x == 4'd15)? base_addr_x + 8: base_addr_x;
        trans_addr_x <= trans_addr_x_n;
    end else begin
        cnt16_x <= 0;
        base_addr_x <= 0;
        trans_addr_x <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phase <= 0;
    end else if (top_state == WRITE_X1) begin
        phase <= (cnt16_x[0])? ~phase: phase;
    end else begin
        phase <= 0;
    end
end

always @(*) begin
    if (trans_addr_x == 9'd259 && cnt16_x == 4'd15) begin
        trans_addr_x_n = 0;
    end else if (top_state == WRITE_X1) begin
        trans_addr_x_n[ADDR_WIDTH_G-1] = ~trans_addr_x[ADDR_WIDTH_G-1];
        trans_addr_x_n[(ADDR_WIDTH_G-2):0] = (cnt16_x[1:0] == 2'b11)? trans_addr_x[(ADDR_WIDTH_G-2):0] + 1
                                                    : trans_addr_x[(ADDR_WIDTH_G-2):0];
    end else begin
        trans_addr_x_n = 0;
    end
end

assign mul_trans_addr_x = trans_addr_x + base_addr_x;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sram_g_addr <= 0;
    end else begin
        sram_g_addr <= sram_g_addr_n;
    end
end

always @(*) begin
    case (top_state)
        WRITE_X1: begin
            sram_addr_g0 = mul_trans_addr_x;
            sram_addr_g1 = mul_trans_addr_x;
            sram_addr_g2 = mul_trans_addr_x;
            sram_addr_g3 = mul_trans_addr_x;
            sram_g_addr_n = 0;
            sram_wen_g0 = 1'b1;
            sram_wen_g1 = 1'b1;
            sram_wen_g2 = 1'b1;
            sram_wen_g3 = 1'b1;
        end 
        WRITE_X2: begin
            sram_addr_g0 = mul_trans_addr_y;
            sram_addr_g1 = mul_trans_addr_y;
            sram_addr_g2 = mul_trans_addr_y;
            sram_addr_g3 = mul_trans_addr_y;
            sram_g_addr_n = 0;
            sram_wen_g0 = 1'b1;
            sram_wen_g1 = 1'b1;
            sram_wen_g2 = 1'b1;
            sram_wen_g3 = 1'b1;
        end 
        default: begin
            sram_addr_g0 = 0;
            sram_addr_g1 = 0;
            sram_addr_g2 = 0;
            sram_addr_g3 = 0;
            sram_g_addr_n = 0;
            sram_wen_g0 = 1'b1;
            sram_wen_g1 = 1'b1;
            sram_wen_g2 = 1'b1;
            sram_wen_g3 = 1'b1;
        end
    endcase
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_4 <= 0;
    end else if (top_state == WRITE_X1) begin
        valid_4 <= 1;
    end else begin
        valid_4 <= 0;
    end
end
always @(posedge clk) begin
    phase_d1 <= phase;
    phase_d2 <= phase_d1;
    phase_d3 <= phase_d2;
    phase_d4 <= phase_d3;
    phase_d5 <= phase_d4;
    phase_d6 <= phase_d5;
    phase_d7 <= phase_d6;
end

// fetch data and do G - Z/mu (2 round)
// Each sequence may repeat 2 times
// 0 -> 256 -> 0 -> 256 -> 1 -> 257 -> 1 -> 257 -> ...
// for phase = 0
// do the first half col-wise subtract delGx

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        store_en <= 0;
    end else if (add_out_valid[0]==1 && (top_state == WRITE_X1 || top_state == WRITE_X1_t)) begin
        store_en <= ~store_en;
    end else begin
        store_en <= 0;
    end
end

always @(posedge clk) begin
    if (!store_en) begin
        for (i=0; i<4; i=i+1) begin
            g_minus_zmu_reg[i] <= add_result[i];
        end
    end 
end

always @(posedge clk) begin
    if (!rst_n) begin
        last_g_minus_zmu_reg <= 0;
    end else if (store_en) begin
        last_g_minus_zmu_reg <= add_result[3];
    end
end

// write into SRAM X(64x32x1x64)

// delGx: 
// write addr sequence: 
// 0 -> 1 -> 2 -> 3 ... -> 255
// delGy: 
// write addr sequence: 
// 264 -> 272 -> 280 -> ... -> 504

always @(posedge clk) begin
    if (top_state == WRITE_X2 || top_state == WRITE_X2_t) begin
        cnt32 <= (add_out_valid[4])? cnt32 + 1: cnt32; 
        // cnt16_2 <= (add_out_valid[4])? cnt16_2 + 1: cnt16_2;
    end else begin
        cnt32 <= 1;
        // cnt16_2 <= 1;
    end
end
always @(posedge clk) begin
    if (top_state == WRITE_X2 || top_state == WRITE_X2_t) begin
        phase_sramx_waddr <= (cnt32 == 5'd31)? ~phase_sramx_waddr: phase_sramx_waddr;
        // phase_sramx_bank <= (cnt16_2 == 4'd16)? ~phase_sramx_bank: phase_sramx_bank;
    end else begin
        phase_sramx_waddr <= 0;
        // phase_sramx_bank <= 0;
    end

end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sram_x_addr <= 0;
    end else begin
        sram_x_addr <= sram_x_addr_n;
    end
end

always @(*) begin
    case (top_state)
        WRITE_X1, WRITE_X1_t: begin
            sram_addr_x0 = sram_x_addr;
            sram_addr_x1 = sram_x_addr;
            sram_addr_x2 = sram_x_addr;
            sram_addr_x3 = sram_x_addr;
            sram_wdata_x0 = add_result[4];
            sram_wdata_x1 = add_result[5];
            sram_wdata_x2 = add_result[6];
            sram_wdata_x3 = add_result[7];
            if (add_out_valid[4]) begin
                sram_x_addr_n = (&sram_x_addr[7:0])? 0: sram_x_addr + 1;
                sram_wen_x0 = 1'b0;
                sram_wen_x1 = 1'b0;
                sram_wen_x2 = 1'b0; 
                sram_wen_x3 = 1'b0;
            end else begin
                sram_x_addr_n = sram_x_addr;
                sram_wen_x0 = 1'b1;
                sram_wen_x1 = 1'b1;
                sram_wen_x2 = 1'b1; 
                sram_wen_x3 = 1'b1;
            end
        end 
        WRITE_X2, WRITE_X2_t: begin
            sram_addr_x0 = sram_x_delgy_addr;
            sram_addr_x1 = sram_x_delgy_addr;
            sram_addr_x2 = sram_x_delgy_addr;
            sram_addr_x3 = sram_x_delgy_addr;
            
            sram_x_addr_n = 0;
            if (phase_y_w) begin
                sram_wdata_x0 = add_result[4];
                sram_wdata_x1 = add_result[4];
                sram_wdata_x2 = add_result[5];
                sram_wdata_x3 = add_result[5];
            end else begin
                sram_wdata_x0 = add_result[6];
                sram_wdata_x1 = add_result[6];
                sram_wdata_x2 = add_result[7];
                sram_wdata_x3 = add_result[7];
            end
            if (phase_sramx_waddr == 1'b0) begin
                sram_wen_x0 = 1'b0 || !(add_out_valid[4] && rowoneblock);
                sram_wen_x1 = 1'b1 || !(add_out_valid[4] && rowoneblock);
                sram_wen_x2 = 1'b0 || !(add_out_valid[4] && rowoneblock); 
                sram_wen_x3 = 1'b1 || !(add_out_valid[4] && rowoneblock);
            end else begin
                sram_wen_x0 = 1'b1 || !(add_out_valid[4] && rowoneblock);
                sram_wen_x1 = 1'b0 || !(add_out_valid[4] && rowoneblock);
                sram_wen_x2 = 1'b1 || !(add_out_valid[4] && rowoneblock); 
                sram_wen_x3 = 1'b0 || !(add_out_valid[4] && rowoneblock);
            end
        end
        PRE_FFT, PRE_FFT: begin
            sram_addr_x0 = sram_x_raddr;
            sram_addr_x1 = sram_x_raddr;
            sram_addr_x2 = sram_x_raddr;
            sram_addr_x3 = sram_x_raddr;
            sram_wen_x0 = 1'b1; //read only
            sram_wen_x1 = 1'b1;
            sram_wen_x2 = 1'b1;
            sram_wen_x3 = 1'b1;
            sram_wdata_x0 = 0;
            sram_wdata_x1 = 0;
            sram_wdata_x2 = 0;
            sram_wdata_x3 = 0;
        end
        default: begin
            sram_addr_x0 = 0;
            sram_addr_x1 = 0;
            sram_addr_x2 = 0;
            sram_addr_x3 = 0;
            sram_x_addr_n = 0;
            sram_wdata_x0 = 0;
            sram_wdata_x1 = 0;
            sram_wdata_x2 = 0;
            sram_wdata_x3 = 0;
            sram_wen_x0 = 1'b1;
            sram_wen_x1 = 1'b1;
            sram_wen_x2 = 1'b1; 
            sram_wen_x3 = 1'b1;
        end 
    endcase
end

// 2. delGy
// read SRAM U and SRAM G
// memory access sequence: (do this sequence 2 times)
// 4 -> 12 -> 20 -> .. 260 -> 268 -> .. 508 
// 5 -> 13 -> 21 -> .. 261 -> 269 -> .. 509 
// 6 -> 14 -> 22 -> .. 262 -> 270 -> .. 510 
// 7 -> 15 -> 23 -> .. 263 -> 271 -> .. 511 
 
// phase_y_r represent which round of sequence now(0 or 1)
// phase_y_w represent which round of sequence now(for write)
// use this signal to determine the bank to be write

always @(posedge clk) begin
    if (top_state == WRITE_X2) begin
        if (mul_trans_addr_y == 9'd511) begin
            phase_y_r <= 1;
        end
        valid_5 <= 1'b1;
    end else begin
        phase_y_r <= 0;
        valid_5 <= 1'b0;
    end
end

always @(posedge clk) begin
    if (top_state == WRITE_X2 || top_state == WRITE_X2_t) begin
        if (sram_x_delgy_addr == 9'd510 && phase_sramx_waddr == 1'b1) begin
            phase_y_w <= 1;
        end else begin
            phase_y_w <= phase_y_w;
        end
    end else begin
        phase_y_w <= 0;
    end
end

// address generator of delGy
always @(posedge clk) begin
    if (top_state == WRITE_X2) begin
        cnt16_y <= cnt16_y + 1;
        mul_trans_addr_y <= mul_trans_addr_y_n;
        trans_flag_y <= trans_flag_y_n;
        trans_flag_y_d1 <= trans_flag_y;
    end else begin
        cnt16_y <= 0;
        mul_trans_addr_y <= 4;
        trans_flag_y <= 0;
        trans_flag_y_d1 <= 0;
    end
end


always @(*) begin
    case (mul_trans_addr_y)
        9'd508: begin
            mul_trans_addr_y_n = 9'd5;
            trans_flag_y_n = 1;
        end 
        9'd509: begin
            mul_trans_addr_y_n = 9'd6;
            trans_flag_y_n = 1;
        end 
        9'd510: begin
            mul_trans_addr_y_n = 9'd7;
            trans_flag_y_n = 1;
        end 
        9'd511: begin
            mul_trans_addr_y_n = 9'd4; 
            trans_flag_y_n = 1;
        end 
        default: begin
            mul_trans_addr_y_n = mul_trans_addr_y + 8;
            trans_flag_y_n = 0;
        end 
    endcase
end

reg [(pFP_WIDTH-1):0] fp64_reg [0:3];
reg fp_add_out_valid_d1;
wire dont_fresh;
reg dont_fresh_d1;
reg dont_fresh_d2;
reg dont_fresh_d3;
reg dont_fresh_d4;
reg dont_fresh_d5; 
reg dont_fresh_d6;
reg dont_fresh_d7;
reg dont_fresh_d8;
wire dont_fresh_d7_d8;
assign dont_fresh_d7_d8 = dont_fresh_d7 | dont_fresh_d8;

assign dont_fresh =  trans_flag_y;
always @(posedge clk) begin
    fp_add_out_valid_d1 <= add_out_valid[0];
    dont_fresh_d1 <= dont_fresh;
    dont_fresh_d2 <= dont_fresh_d1;
    dont_fresh_d3 <= dont_fresh_d2;
    dont_fresh_d4 <= dont_fresh_d3;
    dont_fresh_d5 <= dont_fresh_d4;
    dont_fresh_d6 <= dont_fresh_d5;
    dont_fresh_d7 <= dont_fresh_d6;
    dont_fresh_d8 <= dont_fresh_d7;
    // for (i=0; i<4; i=i+1) begin
    //     fp64_reg[i] <= (dont_fresh_d7)? fp64_reg[i]: add_result[i];
    // end
    for (i=0; i<4; i=i+1) begin
        fp64_reg[i] <= add_result[i];
    end
end

// ----- sram x write address ----- //
// addr sequence: 
// 256(skip) -> 264 -> ... -> 504 ->
// 258(skip) -> 266 -> ... -> 506 ->
// 260(skip) -> 268 -> ... -> 508 ->
// 262(skip) -> 270 -> ... -> 510 -> 
// 257(skip) -> 265 -> ... -> 505 ->
// 259(skip) -> 267 -> ... -> 507 -> 
// 261(skip) -> 269 -> ... -> 509 -> 
// 263(skip) -> 271 -> ... -> 511  

// delGy addr generator
assign rowoneblock = (sram_x_delgy_addr[(ADDR_WIDTH_X-1):(ADDR_WIDTH_X-6)]!=6'b100000)? 1:0;

always @(posedge clk) begin
    if (top_state == WRITE_X2 || top_state == WRITE_X2_t) begin
        sram_x_delgy_addr <= (add_out_valid[4])? sram_x_delgy_addr_n: sram_x_delgy_addr;
    end else begin
        sram_x_delgy_addr <= 9'd264;
    end
end

always @(*) begin
    case (sram_x_delgy_addr)
        9'd504: sram_x_delgy_addr_n = (phase_sramx_waddr)? 9'd258: 9'd256;
        9'd506: sram_x_delgy_addr_n = (phase_sramx_waddr)? 9'd260: 9'd258;
        9'd508: sram_x_delgy_addr_n = (phase_sramx_waddr)? 9'd262: 9'd260;
        9'd510: sram_x_delgy_addr_n = (phase_sramx_waddr)? 9'd257: 9'd262;

        9'd505: sram_x_delgy_addr_n = (phase_sramx_waddr)? 9'd259: 9'd257;
        9'd507: sram_x_delgy_addr_n = (phase_sramx_waddr)? 9'd261: 9'd259;
        9'd509: sram_x_delgy_addr_n = (phase_sramx_waddr)? 9'd263: 9'd261;
        9'd511: sram_x_delgy_addr_n = (phase_sramx_waddr)? 9'd256: 9'd263;
        default: sram_x_delgy_addr_n = sram_x_delgy_addr + 8;
    endcase
end


// ----- pre fft stage ----- //
// prepare data before fft
// 1. delGx + delGy (element-wise add)
// 2. mu * (delGx + delGy)
// 3. 2Ti + mu * (delGx + delGy)

// step1: read sram X
// delGx: sram X addr 0-255
// delGy: sram X addr 0-256
// sram X read addr sequence: 
// 0 -> 256 -> 1 -> 257 -> ... -> 255 -> 511
// 0_0000_0000 -> 1_0000_0000 -> 0_0000_0001 -> 1_0000_0001 -> ...
// -> 0_1111_1111 -> 1_1111_1111

// since sram x can only read 4-data 1-cyc, we read delGx and delGy interleave
// first cycle : read delGx and store 4 data of delGx
// second cycle: read delGy and get 4 data of delGy
// add them up to get 4 add_result 

always @(posedge clk) begin
    if (top_state == PRE_FFT) begin
        sram_x_raddr_8b  <= (sram_x_raddr_msb == 1'b1)? sram_x_raddr_8b + 1: sram_x_raddr_8b;
        sram_x_raddr_msb <= ~sram_x_raddr_msb;
    end else begin
        sram_x_raddr_8b  <= 0;
        sram_x_raddr_msb <= 0;
    end
end
assign sram_x_raddr = {sram_x_raddr_msb, sram_x_raddr_8b};

reg [(pFP_WIDTH-1):0] fp64_reg_2 [0:3]; // may be resouce sharing, fix later
always @(posedge clk) begin
    if (!rst_n) begin
        for (i=0; i<4; i=i+1) begin
            fp64_reg_2[i] <= 0;
        end
    end else if (sram_x_raddr_msb == 1'b1) begin // latch delGx data
        fp64_reg_2[0] <= sram_rdata_x0;
        fp64_reg_2[1] <= sram_rdata_x1;
        fp64_reg_2[2] <= sram_rdata_x2;
        fp64_reg_2[3] <= sram_rdata_x3;
    end
end

reg valid_6;
always @(posedge clk) begin
    valid_6 <= sram_x_raddr_msb;
end

// ----- 2 * Ti ----- //
// Ti is generated from (0~255)/255, so Ti ∈ [0,1] and Ti is always non-negative.
// The minimum non-zero value is 1/255 ≈ 3.92e-3, which is far larger than
// the minimum normal fp64 value 2^-1022 ≈ 2.23e-308.
// Therefore, Ti will never be subnormal (exp==0 && frac!=0). We only need:
//   - zero passthrough
//   - normal case: exponent + 1

wire [(pFP_WIDTH-1):0] sram_b_rdata[0:3];
assign sram_b_rdata[0] = sram_rdata_b0;
assign sram_b_rdata[1] = sram_rdata_b1;
assign sram_b_rdata[2] = sram_rdata_b2;
assign sram_b_rdata[3] = sram_rdata_b3;

reg [63:0] sram_b_rdata_x2 [0:3];

always @(*) begin
    for (i = 0; i < 4; i = i + 1) begin
        // extract fields
        if (sram_b_rdata[i][62:0] == 63'd0) begin
            // +0 (exp==0 && frac==0)
            sram_b_rdata_x2[i] = sram_b_rdata[i];
        end else begin
            // normal number -> exponent + 1
            sram_b_rdata_x2[i] = {
                sram_b_rdata[i][63],               // sign
                sram_b_rdata[i][62:52] + 11'd1,    // exponent + 1
                sram_b_rdata[i][51:0]              // fraction
            };
        end
    end
end


// ----- write SRAM E ----- //
// SRAM E(32x32x64) is a 16 bank sram
// addr range from 0 to 32/16*32-1 = (0,63)



always @(posedge clk) begin
    if (top_state == PRE_FFT || top_state == PRE_FFT_t) begin
        valid_7 <= (sram_addr_b0 == 1)? 1:valid_7;
    end else begin
        valid_7 <= 0;
    end
end
// since sram e has 16 bank, but we only produce 4 data
// in the pre-fft stage, so we need cnt4 to control 
// wen and address
always @(posedge clk) begin
    if (top_state == PRE_FFT || top_state == PRE_FFT_t) begin
        cnt4 <= (add_out_valid[4] && valid_7)? cnt4 + 1: cnt4;
    end else if (top_state == FFT_D || top_state == FFT_D_t) begin
        cnt4 <= (add_out_valid[0])? cnt4 + 1: cnt4;
    end else begin
        cnt4 <= 0;
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        sram_e_addr <= 0;
    end else begin
        sram_e_addr <= sram_e_addr_n;
    end
end

always @(*) begin
    case (top_state)
        PRE_FFT, PRE_FFT_t: begin
            sram_e_addr_n = (cnt4 == 2'b11 && add_out_valid[4])? sram_e_addr + 1: sram_e_addr;
            sram_addr_e0  = sram_e_addr; sram_addr_e1  = sram_e_addr;
            sram_addr_e2  = sram_e_addr; sram_addr_e3  = sram_e_addr;

            sram_addr_e4  = sram_e_addr; sram_addr_e5  = sram_e_addr;
            sram_addr_e6  = sram_e_addr; sram_addr_e7  = sram_e_addr;

            sram_addr_e8  = sram_e_addr; sram_addr_e9  = sram_e_addr;
            sram_addr_e10 = sram_e_addr; sram_addr_e11 = sram_e_addr;

            sram_addr_e12 = sram_e_addr; sram_addr_e13 = sram_e_addr;
            sram_addr_e14 = sram_e_addr; sram_addr_e15 = sram_e_addr;

            sram_wdata_e0  = {add_result[4], 64'b0}; sram_wdata_e1  = {add_result[5], 64'b0};
            sram_wdata_e2  = {add_result[6], 64'b0}; sram_wdata_e3  = {add_result[7], 64'b0};

            sram_wdata_e4  = {add_result[4], 64'b0}; sram_wdata_e5  = {add_result[5], 64'b0};
            sram_wdata_e6  = {add_result[6], 64'b0}; sram_wdata_e7  = {add_result[7], 64'b0};

            sram_wdata_e8  = {add_result[4], 64'b0}; sram_wdata_e9  = {add_result[5], 64'b0};
            sram_wdata_e10 = {add_result[6], 64'b0}; sram_wdata_e11 = {add_result[7], 64'b0};

            sram_wdata_e12 = {add_result[4], 64'b0}; sram_wdata_e13 = {add_result[5], 64'b0};
            sram_wdata_e14 = {add_result[6], 64'b0}; sram_wdata_e15 = {add_result[7], 64'b0};

            if (add_out_valid[4]) begin
                sram_wen_e0  = (cnt4 == 2'b00)? 1'b0: 1'b1; sram_wen_e1  = (cnt4 == 2'b00)? 1'b0: 1'b1; 
                sram_wen_e2  = (cnt4 == 2'b00)? 1'b0: 1'b1; sram_wen_e3  = (cnt4 == 2'b00)? 1'b0: 1'b1;

                sram_wen_e4  = (cnt4 == 2'b01)? 1'b0: 1'b1; sram_wen_e5  = (cnt4 == 2'b01)? 1'b0: 1'b1;
                sram_wen_e6  = (cnt4 == 2'b01)? 1'b0: 1'b1; sram_wen_e7  = (cnt4 == 2'b01)? 1'b0: 1'b1;

                sram_wen_e8  = (cnt4 == 2'b10)? 1'b0: 1'b1; sram_wen_e9  = (cnt4 == 2'b10)? 1'b0: 1'b1;
                sram_wen_e10 = (cnt4 == 2'b10)? 1'b0: 1'b1; sram_wen_e11 = (cnt4 == 2'b10)? 1'b0: 1'b1;

                sram_wen_e12 = (cnt4 == 2'b11)? 1'b0: 1'b1; sram_wen_e13 = (cnt4 == 2'b11)? 1'b0: 1'b1;
                sram_wen_e14 = (cnt4 == 2'b11)? 1'b0: 1'b1; sram_wen_e15 = (cnt4 == 2'b11)? 1'b0: 1'b1;
            end else begin
                sram_wen_e0  = 1'b1; sram_wen_e1  = 1'b1; sram_wen_e2  = 1'b1; sram_wen_e3  = 1'b1;
                sram_wen_e4  = 1'b1; sram_wen_e5  = 1'b1; sram_wen_e6  = 1'b1; sram_wen_e7  = 1'b1;
                sram_wen_e8  = 1'b1; sram_wen_e9  = 1'b1; sram_wen_e10 = 1'b1; sram_wen_e11 = 1'b1;
                sram_wen_e12 = 1'b1; sram_wen_e13 = 1'b1; sram_wen_e14 = 1'b1; sram_wen_e15 = 1'b1;
            end
        end
        FFT: begin
            sram_e_addr_n = 0;
            sram_addr_e0  = sram_e_addr; sram_addr_e1  = sram_e_addr;
            sram_addr_e2  = sram_e_addr; sram_addr_e3  = sram_e_addr;

            sram_addr_e4  = sram_e_addr; sram_addr_e5  = sram_e_addr;
            sram_addr_e6  = sram_e_addr; sram_addr_e7  = sram_e_addr;

            sram_addr_e8  = sram_e_addr; sram_addr_e9  = sram_e_addr;
            sram_addr_e10 = sram_e_addr; sram_addr_e11 = sram_e_addr;

            sram_addr_e12 = sram_e_addr; sram_addr_e13 = sram_e_addr;
            sram_addr_e14 = sram_e_addr; sram_addr_e15 = sram_e_addr;

            sram_wdata_e0  = {add_result[4], 64'b0}; sram_wdata_e1  = {add_result[5], 64'b0};
            sram_wdata_e2  = {add_result[6], 64'b0}; sram_wdata_e3  = {add_result[7], 64'b0};

            sram_wdata_e4  = {add_result[4], 64'b0}; sram_wdata_e5  = {add_result[5], 64'b0};
            sram_wdata_e6  = {add_result[6], 64'b0}; sram_wdata_e7  = {add_result[7], 64'b0};

            sram_wdata_e8  = {add_result[4], 64'b0}; sram_wdata_e9  = {add_result[5], 64'b0};
            sram_wdata_e10 = {add_result[6], 64'b0}; sram_wdata_e11 = {add_result[7], 64'b0};

            sram_wdata_e12 = {add_result[4], 64'b0}; sram_wdata_e13 = {add_result[5], 64'b0};
            sram_wdata_e14 = {add_result[6], 64'b0}; sram_wdata_e15 = {add_result[7], 64'b0};

            // addr from DUT
            sram_addr_e0  = sramA_addr_0_dut;  sram_addr_e1  = sramA_addr_1_dut;
            sram_addr_e2  = sramA_addr_2_dut;  sram_addr_e3  = sramA_addr_3_dut;
            sram_addr_e4  = sramA_addr_4_dut;  sram_addr_e5  = sramA_addr_5_dut;
            sram_addr_e6  = sramA_addr_6_dut;  sram_addr_e7  = sramA_addr_7_dut;
            sram_addr_e8  = sramA_addr_8_dut;  sram_addr_e9  = sramA_addr_9_dut;
            sram_addr_e10 = sramA_addr_10_dut; sram_addr_e11 = sramA_addr_11_dut;
            sram_addr_e12 = sramA_addr_12_dut; sram_addr_e13 = sramA_addr_13_dut;
            sram_addr_e14 = sramA_addr_14_dut; sram_addr_e15 = sramA_addr_15_dut;

            // wdata from DUT
            sram_wdata_e0  = sramA_wdata_0_dut;  sram_wdata_e1  = sramA_wdata_1_dut;
            sram_wdata_e2  = sramA_wdata_2_dut;  sram_wdata_e3  = sramA_wdata_3_dut;
            sram_wdata_e4  = sramA_wdata_4_dut;  sram_wdata_e5  = sramA_wdata_5_dut;
            sram_wdata_e6  = sramA_wdata_6_dut;  sram_wdata_e7  = sramA_wdata_7_dut;
            sram_wdata_e8  = sramA_wdata_8_dut;  sram_wdata_e9  = sramA_wdata_9_dut;
            sram_wdata_e10 = sramA_wdata_10_dut; sram_wdata_e11 = sramA_wdata_11_dut;
            sram_wdata_e12 = sramA_wdata_12_dut; sram_wdata_e13 = sramA_wdata_13_dut;
            sram_wdata_e14 = sramA_wdata_14_dut; sram_wdata_e15 = sramA_wdata_15_dut;

            // wen from DUT
            sram_wen_e0  = sramA_wsb_0_dut;  sram_wen_e1  = sramA_wsb_1_dut;
            sram_wen_e2  = sramA_wsb_2_dut;  sram_wen_e3  = sramA_wsb_3_dut;
            sram_wen_e4  = sramA_wsb_4_dut;  sram_wen_e5  = sramA_wsb_5_dut;
            sram_wen_e6  = sramA_wsb_6_dut;  sram_wen_e7  = sramA_wsb_7_dut;
            sram_wen_e8  = sramA_wsb_8_dut;  sram_wen_e9  = sramA_wsb_9_dut;
            sram_wen_e10 = sramA_wsb_10_dut; sram_wen_e11 = sramA_wsb_11_dut;
            sram_wen_e12 = sramA_wsb_12_dut; sram_wen_e13 = sramA_wsb_13_dut;
            sram_wen_e14 = sramA_wsb_14_dut; sram_wen_e15 = sramA_wsb_15_dut;
        end
        FFT_D, FFT_D_t: begin
            
            sram_e_addr_n = (cnt4 == 2'b11 && add_out_valid[0])? sram_e_addr + 1: sram_e_addr;

            sram_wdata_e0  = {add_result[0], 64'b0}; sram_wdata_e1  = {add_result[1], 64'b0};
            sram_wdata_e2  = {add_result[2], 64'b0}; sram_wdata_e3  = {add_result[3], 64'b0};

            sram_wdata_e4  = {add_result[0], 64'b0}; sram_wdata_e5  = {add_result[1], 64'b0};
            sram_wdata_e6  = {add_result[2], 64'b0}; sram_wdata_e7  = {add_result[3], 64'b0};

            sram_wdata_e8  = {add_result[0], 64'b0}; sram_wdata_e9  = {add_result[1], 64'b0};
            sram_wdata_e10 = {add_result[2], 64'b0}; sram_wdata_e11 = {add_result[3], 64'b0};

            sram_wdata_e12 = {add_result[0], 64'b0}; sram_wdata_e13 = {add_result[1], 64'b0};
            sram_wdata_e14 = {add_result[2], 64'b0}; sram_wdata_e15 = {add_result[3], 64'b0};

            sram_addr_e0  = sram_e_addr; sram_addr_e1  = sram_e_addr;
            sram_addr_e2  = sram_e_addr; sram_addr_e3  = sram_e_addr;

            sram_addr_e4  = sram_e_addr; sram_addr_e5  = sram_e_addr;
            sram_addr_e6  = sram_e_addr; sram_addr_e7  = sram_e_addr;

            sram_addr_e8  = sram_e_addr; sram_addr_e9  = sram_e_addr;
            sram_addr_e10 = sram_e_addr; sram_addr_e11 = sram_e_addr;

            sram_addr_e12 = sram_e_addr; sram_addr_e13 = sram_e_addr;
            sram_addr_e14 = sram_e_addr; sram_addr_e15 = sram_e_addr;

            if (add_out_valid[0]) begin
                sram_wen_e0  = (cnt4 == 2'b00)? 1'b0: 1'b1; sram_wen_e1  = (cnt4 == 2'b00)? 1'b0: 1'b1; 
                sram_wen_e2  = (cnt4 == 2'b00)? 1'b0: 1'b1; sram_wen_e3  = (cnt4 == 2'b00)? 1'b0: 1'b1;

                sram_wen_e4  = (cnt4 == 2'b01)? 1'b0: 1'b1; sram_wen_e5  = (cnt4 == 2'b01)? 1'b0: 1'b1;
                sram_wen_e6  = (cnt4 == 2'b01)? 1'b0: 1'b1; sram_wen_e7  = (cnt4 == 2'b01)? 1'b0: 1'b1;

                sram_wen_e8  = (cnt4 == 2'b10)? 1'b0: 1'b1; sram_wen_e9  = (cnt4 == 2'b10)? 1'b0: 1'b1;
                sram_wen_e10 = (cnt4 == 2'b10)? 1'b0: 1'b1; sram_wen_e11 = (cnt4 == 2'b10)? 1'b0: 1'b1;

                sram_wen_e12 = (cnt4 == 2'b11)? 1'b0: 1'b1; sram_wen_e13 = (cnt4 == 2'b11)? 1'b0: 1'b1;
                sram_wen_e14 = (cnt4 == 2'b11)? 1'b0: 1'b1; sram_wen_e15 = (cnt4 == 2'b11)? 1'b0: 1'b1;
            end else begin
                sram_wen_e0  = 1'b1; sram_wen_e1  = 1'b1; sram_wen_e2  = 1'b1; sram_wen_e3  = 1'b1;
                sram_wen_e4  = 1'b1; sram_wen_e5  = 1'b1; sram_wen_e6  = 1'b1; sram_wen_e7  = 1'b1;
                sram_wen_e8  = 1'b1; sram_wen_e9  = 1'b1; sram_wen_e10 = 1'b1; sram_wen_e11 = 1'b1;
                sram_wen_e12 = 1'b1; sram_wen_e13 = 1'b1; sram_wen_e14 = 1'b1; sram_wen_e15 = 1'b1;
            end
        end
        default: begin
            sram_e_addr_n = 0;

            sram_wen_e0  = 1'b1; sram_wen_e1  = 1'b1; sram_wen_e2  = 1'b1; sram_wen_e3  = 1'b1;
            sram_wen_e4  = 1'b1; sram_wen_e5  = 1'b1; sram_wen_e6  = 1'b1; sram_wen_e7  = 1'b1;
            sram_wen_e8  = 1'b1; sram_wen_e9  = 1'b1; sram_wen_e10 = 1'b1; sram_wen_e11 = 1'b1;
            sram_wen_e12 = 1'b1; sram_wen_e13 = 1'b1; sram_wen_e14 = 1'b1; sram_wen_e15 = 1'b1;

            sram_addr_e0  = 0; sram_addr_e1  = 0; sram_addr_e2  = 0; sram_addr_e3  = 0;
            sram_addr_e4  = 0; sram_addr_e5  = 0; sram_addr_e6  = 0; sram_addr_e7  = 0;
            sram_addr_e8  = 0; sram_addr_e9  = 0; sram_addr_e10 = 0; sram_addr_e11 = 0;
            sram_addr_e12 = 0; sram_addr_e13 = 0; sram_addr_e14 = 0; sram_addr_e15 = 0;

            sram_wdata_e0  = 0; sram_wdata_e1  = 0; sram_wdata_e2  = 0; sram_wdata_e3  = 0;
            sram_wdata_e4  = 0; sram_wdata_e5  = 0; sram_wdata_e6  = 0; sram_wdata_e7  = 0;
            sram_wdata_e8  = 0; sram_wdata_e9  = 0; sram_wdata_e10 = 0; sram_wdata_e11 = 0;
            sram_wdata_e12 = 0; sram_wdata_e13 = 0; sram_wdata_e14 = 0; sram_wdata_e15 = 0;
        end 
    endcase
end

// ----- fft stage ----- //
// fft module(addr generator) connect to 3 sram: 
// SRAM-E(32x32x128), SRAM-T(32x32x128), twiddle-rom(31x128)

reg fft_start_flag;
reg fft_start_flag_d1;
// generate 1 cycle fft start

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fft_start_flag <= 0;
        fft_start_flag_d1 <= 0;
    end else if (top_state == FFT) begin
        fft_start_flag <= 1;
        fft_start_flag_d1 <= fft_start_flag;
    end else begin
        fft_start_flag <= 0;
        fft_start_flag_d1 <= 0;
    end
end

always @(*) begin
    fft_start = fft_start_flag ^ fft_start_flag_d1;
    if (top_state == FFT) begin
        fft_mode = 0; 
    end else if (top_state == iFFT) begin
        fft_mode = 1;
    end else begin
        fft_mode = 0;
    end
end

fft u_fft (
    .clk(clk),
    .rst_n(rst_n),
    .mode(fft_mode),

    // ----- output (SRAM-E)
    // .sramA_csb(sramA_csb_dut),
    .sramA_wsb_0(sramA_wsb_0_dut), .sramA_wsb_1(sramA_wsb_1_dut), .sramA_wsb_2(sramA_wsb_2_dut), .sramA_wsb_3(sramA_wsb_3_dut),
    .sramA_wsb_4(sramA_wsb_4_dut), .sramA_wsb_5(sramA_wsb_5_dut), .sramA_wsb_6(sramA_wsb_6_dut), .sramA_wsb_7(sramA_wsb_7_dut),
    .sramA_wsb_8(sramA_wsb_8_dut), .sramA_wsb_9(sramA_wsb_9_dut), .sramA_wsb_10(sramA_wsb_10_dut), .sramA_wsb_11(sramA_wsb_11_dut),
    .sramA_wsb_12(sramA_wsb_12_dut), .sramA_wsb_13(sramA_wsb_13_dut), .sramA_wsb_14(sramA_wsb_14_dut), .sramA_wsb_15(sramA_wsb_15_dut),
    .sramA_wdata_0(sramA_wdata_0_dut), .sramA_wdata_1(sramA_wdata_1_dut), .sramA_wdata_2(sramA_wdata_2_dut), .sramA_wdata_3(sramA_wdata_3_dut),
    .sramA_wdata_4(sramA_wdata_4_dut), .sramA_wdata_5(sramA_wdata_5_dut), .sramA_wdata_6(sramA_wdata_6_dut), .sramA_wdata_7(sramA_wdata_7_dut),
    .sramA_wdata_8(sramA_wdata_8_dut), .sramA_wdata_9(sramA_wdata_9_dut), .sramA_wdata_10(sramA_wdata_10_dut), .sramA_wdata_11(sramA_wdata_11_dut),
    .sramA_wdata_12(sramA_wdata_12_dut), .sramA_wdata_13(sramA_wdata_13_dut), .sramA_wdata_14(sramA_wdata_14_dut), .sramA_wdata_15(sramA_wdata_15_dut),
    .sramA_addr_0(sramA_addr_0_dut), .sramA_addr_1(sramA_addr_1_dut), .sramA_addr_2(sramA_addr_2_dut), .sramA_addr_3(sramA_addr_3_dut),
    .sramA_addr_4(sramA_addr_4_dut), .sramA_addr_5(sramA_addr_5_dut), .sramA_addr_6(sramA_addr_6_dut), .sramA_addr_7(sramA_addr_7_dut),
    .sramA_addr_8(sramA_addr_8_dut), .sramA_addr_9(sramA_addr_9_dut), .sramA_addr_10(sramA_addr_10_dut), .sramA_addr_11(sramA_addr_11_dut),
    .sramA_addr_12(sramA_addr_12_dut), .sramA_addr_13(sramA_addr_13_dut), .sramA_addr_14(sramA_addr_14_dut), .sramA_addr_15(sramA_addr_15_dut),

    // ----- input (SRAM-E)
    .sramA_rdata_0 (sram_rdata_e0 ), .sramA_rdata_1 (sram_rdata_e1 ), .sramA_rdata_2 (sram_rdata_e2 ), .sramA_rdata_3 (sram_rdata_e3 ),
    .sramA_rdata_4 (sram_rdata_e4 ), .sramA_rdata_5 (sram_rdata_e5 ), .sramA_rdata_6 (sram_rdata_e6 ), .sramA_rdata_7 (sram_rdata_e7 ),
    .sramA_rdata_8 (sram_rdata_e8 ), .sramA_rdata_9 (sram_rdata_e9 ), .sramA_rdata_10(sram_rdata_e10), .sramA_rdata_11(sram_rdata_e11),
    .sramA_rdata_12(sram_rdata_e12), .sramA_rdata_13(sram_rdata_e13), .sramA_rdata_14(sram_rdata_e14), .sramA_rdata_15(sram_rdata_e15),

    // ----- output (SRAM-T)
    // .sramB_csb(sramB_csb_dut),
    .sramB_wsb_0(sramB_wsb_0_dut), .sramB_wsb_1(sramB_wsb_1_dut), .sramB_wsb_2(sramB_wsb_2_dut), .sramB_wsb_3(sramB_wsb_3_dut),
    .sramB_wsb_4(sramB_wsb_4_dut), .sramB_wsb_5(sramB_wsb_5_dut), .sramB_wsb_6(sramB_wsb_6_dut), .sramB_wsb_7(sramB_wsb_7_dut),
    .sramB_wsb_8(sramB_wsb_8_dut), .sramB_wsb_9(sramB_wsb_9_dut), .sramB_wsb_10(sramB_wsb_10_dut), .sramB_wsb_11(sramB_wsb_11_dut),
    .sramB_wsb_12(sramB_wsb_12_dut), .sramB_wsb_13(sramB_wsb_13_dut), .sramB_wsb_14(sramB_wsb_14_dut), .sramB_wsb_15(sramB_wsb_15_dut),
    .sramB_wdata_0(sramB_wdata_0_dut), .sramB_wdata_1(sramB_wdata_1_dut), .sramB_wdata_2(sramB_wdata_2_dut), .sramB_wdata_3(sramB_wdata_3_dut),
    .sramB_wdata_4(sramB_wdata_4_dut), .sramB_wdata_5(sramB_wdata_5_dut), .sramB_wdata_6(sramB_wdata_6_dut), .sramB_wdata_7(sramB_wdata_7_dut),
    .sramB_wdata_8(sramB_wdata_8_dut), .sramB_wdata_9(sramB_wdata_9_dut), .sramB_wdata_10(sramB_wdata_10_dut), .sramB_wdata_11(sramB_wdata_11_dut),
    .sramB_wdata_12(sramB_wdata_12_dut), .sramB_wdata_13(sramB_wdata_13_dut), .sramB_wdata_14(sramB_wdata_14_dut), .sramB_wdata_15(sramB_wdata_15_dut),
    .sramB_addr_0(sramB_addr_0_dut), .sramB_addr_1(sramB_addr_1_dut), .sramB_addr_2(sramB_addr_2_dut), .sramB_addr_3(sramB_addr_3_dut),
    .sramB_addr_4(sramB_addr_4_dut), .sramB_addr_5(sramB_addr_5_dut), .sramB_addr_6(sramB_addr_6_dut), .sramB_addr_7(sramB_addr_7_dut),
    .sramB_addr_8(sramB_addr_8_dut), .sramB_addr_9(sramB_addr_9_dut), .sramB_addr_10(sramB_addr_10_dut), .sramB_addr_11(sramB_addr_11_dut),
    .sramB_addr_12(sramB_addr_12_dut), .sramB_addr_13(sramB_addr_13_dut), .sramB_addr_14(sramB_addr_14_dut), .sramB_addr_15(sramB_addr_15_dut),

    // ----- input (SRAM-T)
    .sramB_rdata_0 (sram_rdata_t0 ), .sramB_rdata_1 (sram_rdata_t1 ), .sramB_rdata_2 (sram_rdata_t2 ), .sramB_rdata_3 (sram_rdata_t3 ),
    .sramB_rdata_4 (sram_rdata_t4 ), .sramB_rdata_5 (sram_rdata_t5 ), .sramB_rdata_6 (sram_rdata_t6 ), .sramB_rdata_7 (sram_rdata_t7 ),
    .sramB_rdata_8 (sram_rdata_t8 ), .sramB_rdata_9 (sram_rdata_t9 ), .sramB_rdata_10(sram_rdata_t10), .sramB_rdata_11(sram_rdata_t11),
    .sramB_rdata_12(sram_rdata_t12), .sramB_rdata_13(sram_rdata_t13), .sramB_rdata_14(sram_rdata_t14), .sramB_rdata_15(sram_rdata_t15),

    // ----- output 
    .twiddle_addr_0(twiddle_addr_0), .twiddle_addr_1(twiddle_addr_1), .twiddle_addr_2(twiddle_addr_2), .twiddle_addr_3(twiddle_addr_3),
    .twiddle_addr_4(twiddle_addr_4), .twiddle_addr_5(twiddle_addr_5), .twiddle_addr_6(twiddle_addr_6), .twiddle_addr_7(twiddle_addr_7),
    .twiddle_addr_8(twiddle_addr_8), .twiddle_addr_9(twiddle_addr_9), .twiddle_addr_10(twiddle_addr_10), .twiddle_addr_11(twiddle_addr_11),
    .twiddle_addr_12(twiddle_addr_12), .twiddle_addr_13(twiddle_addr_13), .twiddle_addr_14(twiddle_addr_14), .twiddle_addr_15(twiddle_addr_15),

    // ----- input
    .twiddle_data_0(twiddle_data_0), .twiddle_data_1(twiddle_data_1), .twiddle_data_2(twiddle_data_2), .twiddle_data_3(twiddle_data_3),
    .twiddle_data_4(twiddle_data_4), .twiddle_data_5(twiddle_data_5), .twiddle_data_6(twiddle_data_6), .twiddle_data_7(twiddle_data_7),
    .twiddle_data_8(twiddle_data_8), .twiddle_data_9(twiddle_data_9), .twiddle_data_10(twiddle_data_10), .twiddle_data_11(twiddle_data_11),
    .twiddle_data_12(twiddle_data_12), .twiddle_data_13(twiddle_data_13), .twiddle_data_14(twiddle_data_14), .twiddle_data_15(twiddle_data_15),

    // ----- input 
    .start(fft_start),
    // ----- output 
    .done(fft_done),

    // BPE 0 mul interface
    // ----- output 
    .bpe0_mul_in_A(bpe0_mul_in_A),
    .bpe0_mul_in_B(bpe0_mul_in_B),
    .bpe0_mul_mode(bpe0_mul_mode),
    .bpe0_mul_in_valid(bpe0_mul_in_valid),
    // ----- input 
    .bpe0_mul_result_c(mul0_out),
    .bpe0_mul_result_int(mul0_out),
    .bpe0_mul_out_valid(mul0_out_valid),

    // BPE 0 fp_add interfaces
    // ----- output (FFT -> top add input)
    .bpe0_fp_add_01_in_A     (bpe0_fp_add_01_in_A),
    .bpe0_fp_add_01_in_B     (bpe0_fp_add_01_in_B),
    .bpe0_fp_add_01_in_valid (bpe0_fp_add_01_in_valid),
    // ----- input  (top add output -> FFT)
    .bpe0_fp_add_01_result   (add_result[0]),
    .bpe0_fp_add_01_out_valid(add_out_valid[0]),

    .bpe0_fp_add_02_in_A     (bpe0_fp_add_02_in_A),
    .bpe0_fp_add_02_in_B     (bpe0_fp_add_02_in_B),
    .bpe0_fp_add_02_in_valid (bpe0_fp_add_02_in_valid),
    .bpe0_fp_add_02_result   (add_result[1]),
    .bpe0_fp_add_02_out_valid(add_out_valid[1]),

    .bpe0_fp_add_11_in_A     (bpe0_fp_add_11_in_A),
    .bpe0_fp_add_11_in_B     (bpe0_fp_add_11_in_B),
    .bpe0_fp_add_11_in_valid (bpe0_fp_add_11_in_valid),
    .bpe0_fp_add_11_result   (add_result[2]),
    .bpe0_fp_add_11_out_valid(add_out_valid[2]),

    .bpe0_fp_add_12_in_A     (bpe0_fp_add_12_in_A),
    .bpe0_fp_add_12_in_B     (bpe0_fp_add_12_in_B),
    .bpe0_fp_add_12_in_valid (bpe0_fp_add_12_in_valid),
    .bpe0_fp_add_12_result   (add_result[3]),
    .bpe0_fp_add_12_out_valid(add_out_valid[3]),


    // BPE 1 mul interface
    // ----- output 
    .bpe1_mul_in_A(bpe1_mul_in_A),
    .bpe1_mul_in_B(bpe1_mul_in_B),
    .bpe1_mul_mode(bpe1_mul_mode),
    .bpe1_mul_in_valid(bpe1_mul_in_valid),
    // ----- input 
    .bpe1_mul_result_c(mul1_out),
    .bpe1_mul_result_int(mul1_out),
    .bpe1_mul_out_valid(mul1_out_valid),

    // ======================================================
    // BPE 1 fp_add interfaces
    // ======================================================

    // ----- output (FFT -> top add input)
    .bpe1_fp_add_01_in_A     (bpe1_fp_add_01_in_A),
    .bpe1_fp_add_01_in_B     (bpe1_fp_add_01_in_B),
    .bpe1_fp_add_01_in_valid (bpe1_fp_add_01_in_valid),
    // ----- input  (top add output -> FFT)
    .bpe1_fp_add_01_result   (add_result[4]),
    .bpe1_fp_add_01_out_valid(add_out_valid[4]),

    // ----- output (FFT -> top add input)
    .bpe1_fp_add_02_in_A     (bpe1_fp_add_02_in_A),
    .bpe1_fp_add_02_in_B     (bpe1_fp_add_02_in_B),
    .bpe1_fp_add_02_in_valid (bpe1_fp_add_02_in_valid),
    // ----- input  (top add output -> FFT)
    .bpe1_fp_add_02_result   (add_result[5]),
    .bpe1_fp_add_02_out_valid(add_out_valid[5]),

    // ----- output (FFT -> top add input)
    .bpe1_fp_add_11_in_A     (bpe1_fp_add_11_in_A),
    .bpe1_fp_add_11_in_B     (bpe1_fp_add_11_in_B),
    .bpe1_fp_add_11_in_valid (bpe1_fp_add_11_in_valid),
    // ----- input  (top add output -> FFT)
    .bpe1_fp_add_11_result   (add_result[6]),
    .bpe1_fp_add_11_out_valid(add_out_valid[6]),

    // ----- output (FFT -> top add input)
    .bpe1_fp_add_12_in_A     (bpe1_fp_add_12_in_A),
    .bpe1_fp_add_12_in_B     (bpe1_fp_add_12_in_B),
    .bpe1_fp_add_12_in_valid (bpe1_fp_add_12_in_valid),
    // ----- input  (top add output -> FFT)
    .bpe1_fp_add_12_result   (add_result[7]),
    .bpe1_fp_add_12_out_valid(add_out_valid[7])

);



// ----- SRAM T control ----- //
always @(*) begin
    case (top_state)
        FFT: begin
            // write enable (low active)
            sram_wen_t0  = sramB_wsb_0_dut;   sram_wen_t1  = sramB_wsb_1_dut;   sram_wen_t2  = sramB_wsb_2_dut;   sram_wen_t3  = sramB_wsb_3_dut;
            sram_wen_t4  = sramB_wsb_4_dut;   sram_wen_t5  = sramB_wsb_5_dut;   sram_wen_t6  = sramB_wsb_6_dut;   sram_wen_t7  = sramB_wsb_7_dut;
            sram_wen_t8  = sramB_wsb_8_dut;   sram_wen_t9  = sramB_wsb_9_dut;   sram_wen_t10 = sramB_wsb_10_dut;  sram_wen_t11 = sramB_wsb_11_dut;
            sram_wen_t12 = sramB_wsb_12_dut;  sram_wen_t13 = sramB_wsb_13_dut;  sram_wen_t14 = sramB_wsb_14_dut;  sram_wen_t15 = sramB_wsb_15_dut;

            // address
            sram_addr_t0  = sramB_addr_0_dut;   sram_addr_t1  = sramB_addr_1_dut;   sram_addr_t2  = sramB_addr_2_dut;   sram_addr_t3  = sramB_addr_3_dut;
            sram_addr_t4  = sramB_addr_4_dut;   sram_addr_t5  = sramB_addr_5_dut;   sram_addr_t6  = sramB_addr_6_dut;   sram_addr_t7  = sramB_addr_7_dut;
            sram_addr_t8  = sramB_addr_8_dut;   sram_addr_t9  = sramB_addr_9_dut;   sram_addr_t10 = sramB_addr_10_dut;  sram_addr_t11 = sramB_addr_11_dut;
            sram_addr_t12 = sramB_addr_12_dut;  sram_addr_t13 = sramB_addr_13_dut;  sram_addr_t14 = sramB_addr_14_dut;  sram_addr_t15 = sramB_addr_15_dut;

            // write data
            sram_wdata_t0  = sramB_wdata_0_dut;   sram_wdata_t1  = sramB_wdata_1_dut;   sram_wdata_t2  = sramB_wdata_2_dut;   sram_wdata_t3  = sramB_wdata_3_dut;
            sram_wdata_t4  = sramB_wdata_4_dut;   sram_wdata_t5  = sramB_wdata_5_dut;   sram_wdata_t6  = sramB_wdata_6_dut;   sram_wdata_t7  = sramB_wdata_7_dut;
            sram_wdata_t8  = sramB_wdata_8_dut;   sram_wdata_t9  = sramB_wdata_9_dut;   sram_wdata_t10 = sramB_wdata_10_dut;  sram_wdata_t11 = sramB_wdata_11_dut;
            sram_wdata_t12 = sramB_wdata_12_dut;  sram_wdata_t13 = sramB_wdata_13_dut;  sram_wdata_t14 = sramB_wdata_14_dut;  sram_wdata_t15 = sramB_wdata_15_dut;
        end

        default: begin
            // idle: disable write
            sram_wen_t0  = 1'b1;  sram_wen_t1  = 1'b1;  sram_wen_t2  = 1'b1;  sram_wen_t3  = 1'b1;
            sram_wen_t4  = 1'b1;  sram_wen_t5  = 1'b1;  sram_wen_t6  = 1'b1;  sram_wen_t7  = 1'b1;
            sram_wen_t8  = 1'b1;  sram_wen_t9  = 1'b1;  sram_wen_t10 = 1'b1;  sram_wen_t11 = 1'b1;
            sram_wen_t12 = 1'b1;  sram_wen_t13 = 1'b1;  sram_wen_t14 = 1'b1;  sram_wen_t15 = 1'b1;

            sram_addr_t0  = 0;  sram_addr_t1  = 0;  sram_addr_t2  = 0;  sram_addr_t3  = 0;
            sram_addr_t4  = 0;  sram_addr_t5  = 0;  sram_addr_t6  = 0;  sram_addr_t7  = 0;
            sram_addr_t8  = 0;  sram_addr_t9  = 0;  sram_addr_t10 = 0;  sram_addr_t11 = 0;
            sram_addr_t12 = 0;  sram_addr_t13 = 0;  sram_addr_t14 = 0;  sram_addr_t15 = 0;

            sram_wdata_t0  = 0;  sram_wdata_t1  = 0;  sram_wdata_t2  = 0;  sram_wdata_t3  = 0;
            sram_wdata_t4  = 0;  sram_wdata_t5  = 0;  sram_wdata_t6  = 0;  sram_wdata_t7  = 0;
            sram_wdata_t8  = 0;  sram_wdata_t9  = 0;  sram_wdata_t10 = 0;  sram_wdata_t11 = 0;
            sram_wdata_t12 = 0;  sram_wdata_t13 = 0;  sram_wdata_t14 = 0;  sram_wdata_t15 = 0;
        end
    endcase
end

// ----- read sram D ----- //
// in this stage, we read 4 data per cycle from sram D, and 
// multiply by mu and 2 than store into sram e.
localparam two_hex = 64'h4000000000000000;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sram_d_addr <= 0;
        valid_8 <= 0;
    end else begin
        sram_d_addr <= sram_d_addr_n;
        valid_8 <= valid_8_n;
    end
end

always @(*) begin
    case (top_state)
        FFT_D: begin
            sram_d_addr_n = sram_d_addr + 1;
            valid_8_n = 1;
        end 
        default: begin
            sram_d_addr_n = 0;
            valid_8_n = 0;
        end
    endcase
    // read-only
    sram_addr_d0 = sram_d_addr;
    sram_addr_d1 = sram_d_addr;
    sram_addr_d2 = sram_d_addr;
    sram_addr_d3 = sram_d_addr;
    sram_wdata_d0 = 0;
    sram_wdata_d1 = 0;
    sram_wdata_d2 = 0;
    sram_wdata_d3 = 0;
    sram_wen_d0 = 1'b1;
    sram_wen_d1 = 1'b1;
    sram_wen_d2 = 1'b1;
    sram_wen_d3 = 1'b1;
end

// ========================================================== //
// ===               computation resource                 === //
// ========================================================== //


always @(*) begin
    case (top_state)
        RGB_MAX, RGB_MAX_t: begin
            for (i=0; i<4; i=i+1) begin
                int2fp_in_int[i] = max_sel[i];
                int2fp_in_valid[i] = valid_1;
            end
        end 
        default: begin
            for (i=0; i<4; i=i+1) begin
                int2fp_in_int[i] = 0;
                int2fp_in_valid[i] = 0;
            end
        end
    endcase
end

int2fp int2fp_U0(
    .in_int   (int2fp_in_int[0]),
    .in_valid (int2fp_in_valid[0]),
    .clk      (clk),
    .out_valid(int2fp_out_valid[0]),
    .out_fp   (int2fp_out_fp[0])
);
int2fp int2fp_U1(
    .in_int   (int2fp_in_int[1]),
    .in_valid (int2fp_in_valid[1]),
    .clk      (clk),
    .out_valid(int2fp_out_valid[1]),
    .out_fp   (int2fp_out_fp[1])
);
int2fp int2fp_U2(
    .in_int   (int2fp_in_int[2]),
    .in_valid (int2fp_in_valid[2]),
    .clk      (clk),
    .out_valid(int2fp_out_valid[2]),
    .out_fp   (int2fp_out_fp[2])
);
int2fp int2fp_U3(
    .in_int   (int2fp_in_int[3]),
    .in_valid (int2fp_in_valid[3]),
    .clk      (clk),
    .out_valid(int2fp_out_valid[3]),
    .out_fp   (int2fp_out_fp[3])
);

always @(posedge clk) begin
    case (top_state)
        NORMAL, NORMAL_t: begin
            mul0_ina <= {sram_rdata_i0, sram_rdata_i1};
            mul0_inb <= {recip_255, recip_255};
            mul0_mode <= 2'b10; // float mul
            mul0_in_valid <= valid_2;
            mul1_ina <= {sram_rdata_i2, sram_rdata_i3};
            mul1_inb <= {recip_255, recip_255};
            mul1_mode <= 2'b10; // float mul
            mul1_in_valid <= valid_2;
        end 
        Z_DIV_U, Z_DIV_U_t: begin
            mul0_ina <= {sram_rdata_z0, sram_rdata_z1};
            mul0_inb <= {mu_recip, mu_recip};
            mul0_mode <= 2'b10; // float mul
            mul0_in_valid <= valid_3;
            mul1_ina <= {sram_rdata_z2, sram_rdata_z3};
            mul1_inb <= {mu_recip, mu_recip};
            mul1_mode <= 2'b10; // float mul
            mul1_in_valid <= valid_3;
        end
        PRE_FFT, PRE_FFT_t: begin
            mul0_ina <= {add_result[0], add_result[1]};
            mul0_inb <= {mu, mu};
            mul0_mode <= 2'b10; // float mul
            mul0_in_valid <= add_out_valid[0];
            mul1_ina <= {add_result[2], add_result[3]};
            mul1_inb <= {mu, mu};
            mul1_mode <= 2'b10; 
            mul1_in_valid <= add_out_valid[2];
        end
        FFT: begin
            mul0_ina      <= bpe0_mul_in_A;
            mul0_inb      <= bpe0_mul_in_B;
            mul0_mode     <= bpe0_mul_mode;
            mul0_in_valid <= bpe0_mul_in_valid;

            mul1_ina      <= bpe1_mul_in_A;
            mul1_inb      <= bpe1_mul_in_B;
            mul1_mode     <= bpe1_mul_mode;
            mul1_in_valid <= bpe1_mul_in_valid;
        end
        FFT_D, FFT_D_t: begin
            mul0_ina      <= {sram_rdata_d0[(pFP_WIDTH*2-1):(pFP_WIDTH)], sram_rdata_d1[(2*pFP_WIDTH-1):(pFP_WIDTH)]};
            mul0_inb      <= {mu, mu};
            mul0_mode     <= 2'b10;
            mul0_in_valid <= valid_8;
            mul1_ina      <= {sram_rdata_d2[(pFP_WIDTH*2-1):(pFP_WIDTH)], sram_rdata_d3[(pFP_WIDTH*2-1):(pFP_WIDTH)]};
            mul1_inb      <= {mu, mu};
            mul1_mode     <= 2'b10;
            mul1_in_valid <= valid_8;
        end
        default: begin
            mul0_ina <= 0;
            mul0_inb <= 0;
            mul0_mode <= 0;
            mul0_in_valid <= 0;
            mul1_ina <= 0;
            mul1_inb <= 0;
            mul1_mode <= 0;
            mul1_in_valid <= 0;
        end 
    endcase
end

mul mul_U0(
    .in_A(mul0_ina),
    .in_B(mul0_inb),
    .mode(mul0_mode),
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(mul0_in_valid),
    .result_c(mul0_out),
    .out_valid(mul0_out_valid)
);
mul mul_U1(
    .in_A(mul1_ina),
    .in_B(mul1_inb),
    .mode(mul1_mode),
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(mul1_in_valid),
    .result_c(mul1_out),
    .out_valid(mul1_out_valid)
);



always @(posedge clk) begin
    case (top_state)
        WRITE_X1, WRITE_X1_t: begin // G - Z/mu
            add_ina[0] <= sram_rdata_g0;
            add_inb[0] <= {~sram_rdata_u0[pFP_WIDTH-1], sram_rdata_u0[(pFP_WIDTH-2):0]};
            add_ina[1] <= sram_rdata_g1;
            add_inb[1] <= {~sram_rdata_u1[pFP_WIDTH-1], sram_rdata_u1[(pFP_WIDTH-2):0]};
            add_ina[2] <= sram_rdata_g2;
            add_inb[2] <= {~sram_rdata_u2[pFP_WIDTH-1], sram_rdata_u2[(pFP_WIDTH-2):0]};
            add_ina[3] <= sram_rdata_g3;
            add_inb[3] <= {~sram_rdata_u3[pFP_WIDTH-1], sram_rdata_u3[(pFP_WIDTH-2):0]};
            add_in_valid[0] <= valid_4;
            add_in_valid[1] <= valid_4;
            add_in_valid[2] <= valid_4;
            add_in_valid[3] <= valid_4;

            if (!phase_d7) begin
                add_ina[4] <= last_g_minus_zmu_reg;
                add_inb[4] <= {~g_minus_zmu_reg[0][pFP_WIDTH-1], g_minus_zmu_reg[0][(pFP_WIDTH-2):0]};
                add_ina[5] <= g_minus_zmu_reg[0];
                add_inb[5] <= {~add_result[0][pFP_WIDTH-1], add_result[0][(pFP_WIDTH-2):0]};
                add_ina[6] <= add_result[0];
                add_inb[6] <= {~g_minus_zmu_reg[1][pFP_WIDTH-1], g_minus_zmu_reg[1][(pFP_WIDTH-2):0]};
                add_ina[7] <= g_minus_zmu_reg[1];
                add_inb[7] <= {~add_result[1][pFP_WIDTH-1], add_result[1][(pFP_WIDTH-2):0]};
            end else begin
                add_ina[4] <= add_result[1];
                add_inb[4] <= {~g_minus_zmu_reg[2][pFP_WIDTH-1], g_minus_zmu_reg[2][(pFP_WIDTH-2):0]};
                add_ina[5] <= g_minus_zmu_reg[2];
                add_inb[5] <= {~add_result[2][pFP_WIDTH-1], add_result[2][(pFP_WIDTH-2):0]};
                add_ina[6] <= add_result[2];
                add_inb[6] <= {~g_minus_zmu_reg[3][pFP_WIDTH-1], g_minus_zmu_reg[3][(pFP_WIDTH-2):0]};
                add_ina[7] <= g_minus_zmu_reg[3];
                add_inb[7] <= {~add_result[3][pFP_WIDTH-1], add_result[3][(pFP_WIDTH-2):0]};
            end
            add_in_valid[4] <= store_en;
            add_in_valid[5] <= store_en;
            add_in_valid[6] <= store_en;
            add_in_valid[7] <= store_en;
        end
        WRITE_X2, WRITE_X2_t: begin
            add_ina[0] <= sram_rdata_g0;
            add_inb[0] <= {~sram_rdata_u0[pFP_WIDTH-1], sram_rdata_u0[(pFP_WIDTH-2):0]};
            add_ina[1] <= sram_rdata_g1;
            add_inb[1] <= {~sram_rdata_u1[pFP_WIDTH-1], sram_rdata_u1[(pFP_WIDTH-2):0]};
            add_ina[2] <= sram_rdata_g2;
            add_inb[2] <= {~sram_rdata_u2[pFP_WIDTH-1], sram_rdata_u2[(pFP_WIDTH-2):0]};
            add_ina[3] <= sram_rdata_g3;
            add_inb[3] <= {~sram_rdata_u3[pFP_WIDTH-1], sram_rdata_u3[(pFP_WIDTH-2):0]};
            add_in_valid[0] <= valid_5;
            add_in_valid[1] <= valid_5;
            add_in_valid[2] <= valid_5;
            add_in_valid[3] <= valid_5;

            
            add_ina[4] <= fp64_reg[0];
            add_inb[4] <= {~add_result[0][pFP_WIDTH-1], add_result[0][(pFP_WIDTH-2):0]};
            add_ina[5] <= fp64_reg[1];
            add_inb[5] <= {~add_result[1][pFP_WIDTH-1], add_result[1][(pFP_WIDTH-2):0]};
            add_ina[6] <= fp64_reg[2];
            add_inb[6] <= {~add_result[2][pFP_WIDTH-1], add_result[2][(pFP_WIDTH-2):0]};
            add_ina[7] <= fp64_reg[3];
            add_inb[7] <= {~add_result[3][pFP_WIDTH-1], add_result[3][(pFP_WIDTH-2):0]};
            add_in_valid[4] <= fp_add_out_valid_d1;
            add_in_valid[5] <= fp_add_out_valid_d1;
            add_in_valid[6] <= fp_add_out_valid_d1;
            add_in_valid[7] <= fp_add_out_valid_d1;   
        end
        PRE_FFT, PRE_FFT_t: begin
            // delGx + delGy
            add_ina[0] <= fp64_reg_2[0];
            add_inb[0] <= sram_rdata_x0;
            add_ina[1] <= fp64_reg_2[1];
            add_inb[1] <= sram_rdata_x1;
            add_ina[2] <= fp64_reg_2[2];
            add_inb[2] <= sram_rdata_x2;
            add_ina[3] <= fp64_reg_2[3];
            add_inb[3] <= sram_rdata_x3;
            add_in_valid[0] <= valid_6;
            add_in_valid[1] <= valid_6;
            add_in_valid[2] <= valid_6;
            add_in_valid[3] <= valid_6;

            add_ina[4] <= mul0_out[(2*pFP_WIDTH-1):(pFP_WIDTH)];
            add_inb[4] <= sram_b_rdata_x2[0];
            add_ina[5] <= mul0_out[(pFP_WIDTH-1):0];
            add_inb[5] <= sram_b_rdata_x2[1];
            add_ina[6] <= mul1_out[(2*pFP_WIDTH-1):(pFP_WIDTH)];
            add_inb[6] <= sram_b_rdata_x2[2];
            add_ina[7] <= mul1_out[(pFP_WIDTH-1):0];
            add_inb[7] <= sram_b_rdata_x2[3];
            add_in_valid[4] <= mul0_out_valid;
            add_in_valid[5] <= mul0_out_valid;
            add_in_valid[6] <= mul1_out_valid;
            add_in_valid[7] <= mul1_out_valid;
        end
        FFT: begin
            // ===== BPE0 (4 fp_add) -> add[0..3] =====
            add_ina[0]      <= bpe0_fp_add_01_in_A;
            add_inb[0]      <= bpe0_fp_add_01_in_B;
            add_in_valid[0] <= bpe0_fp_add_01_in_valid;

            add_ina[1]      <= bpe0_fp_add_02_in_A;
            add_inb[1]      <= bpe0_fp_add_02_in_B;
            add_in_valid[1] <= bpe0_fp_add_02_in_valid;

            add_ina[2]      <= bpe0_fp_add_11_in_A;
            add_inb[2]      <= bpe0_fp_add_11_in_B;
            add_in_valid[2] <= bpe0_fp_add_11_in_valid;

            add_ina[3]      <= bpe0_fp_add_12_in_A;
            add_inb[3]      <= bpe0_fp_add_12_in_B;
            add_in_valid[3] <= bpe0_fp_add_12_in_valid;

            // ===== BPE1 (4 fp_add) -> add[4..7] =====
            add_ina[4]      <= bpe1_fp_add_01_in_A;
            add_inb[4]      <= bpe1_fp_add_01_in_B;
            add_in_valid[4] <= bpe1_fp_add_01_in_valid;

            add_ina[5]      <= bpe1_fp_add_02_in_A;
            add_inb[5]      <= bpe1_fp_add_02_in_B;
            add_in_valid[5] <= bpe1_fp_add_02_in_valid;

            add_ina[6]      <= bpe1_fp_add_11_in_A;
            add_inb[6]      <= bpe1_fp_add_11_in_B;
            add_in_valid[6] <= bpe1_fp_add_11_in_valid;

            add_ina[7]      <= bpe1_fp_add_12_in_A;
            add_inb[7]      <= bpe1_fp_add_12_in_B;
            add_in_valid[7] <= bpe1_fp_add_12_in_valid;
        end
        FFT_D, FFT_D_t: begin
            add_ina[0]      <= mul0_out[(pFP_WIDTH*2-1):(pFP_WIDTH)];
            add_inb[0]      <= two_hex;
            add_in_valid[0] <= mul0_out_valid;

            add_ina[1]      <= mul0_out[(pFP_WIDTH-1):0];
            add_inb[1]      <= two_hex;
            add_in_valid[1] <= mul0_out_valid;

            add_ina[2]      <= mul1_out[(pFP_WIDTH*2-1):(pFP_WIDTH)];
            add_inb[2]      <= two_hex;
            add_in_valid[2] <= mul1_out_valid;

            add_ina[3]      <= mul1_out[(pFP_WIDTH-1):0];
            add_inb[3]      <= two_hex;
            add_in_valid[3] <= mul1_out_valid;

            for (i = 4; i < 8; i = i + 1) begin
                add_ina[i] <= {pFP_WIDTH{1'b0}};
                add_inb[i] <= {pFP_WIDTH{1'b0}};
                add_in_valid[i] <= 1'b0;
            end
        end 
        default: begin
            for (i = 0; i < 8; i = i + 1) begin
                add_ina[i] <= {pFP_WIDTH{1'b0}};
                add_inb[i] <= {pFP_WIDTH{1'b0}};
                add_in_valid[i] <= 1'b0;
            end
        end
    endcase
end


genvar k;
generate
    for (k = 0; k < 8; k = k + 1) begin : GEN_FP_ADD
        fp_add add_U (
            .in_A     (add_ina[k]),
            .in_B     (add_inb[k]),
            .clk      (clk),
            .rst_n    (rst_n),
            .in_valid (add_in_valid[k]),
            .result   (add_result[k]),
            .out_valid(add_out_valid[k])
        );
    end
endgenerate


endmodule
