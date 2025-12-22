module fft #(
    parameter BW_PER_ADDR = 128,  // 64-bit real + 64-bit imag
    parameter ADDR_WIDTH = 6,     // 64 addresses per bank
    parameter TWIDDLE_ADDR_WIDTH = 6  // 31 twiddle factors
)(
    input clk,
    input rst_n,
    input mode, // 0: FFT, 1: IFFT
    // SRAM A interface (for ping-pong)
    output reg sramA_csb,
    output reg sramA_wsb_0, sramA_wsb_1, sramA_wsb_2, sramA_wsb_3, sramA_wsb_4, sramA_wsb_5, sramA_wsb_6, sramA_wsb_7,
    output reg sramA_wsb_8, sramA_wsb_9, sramA_wsb_10, sramA_wsb_11, sramA_wsb_12, sramA_wsb_13, sramA_wsb_14, sramA_wsb_15,
    output reg [BW_PER_ADDR-1:0] sramA_wdata_0, sramA_wdata_1, sramA_wdata_2, sramA_wdata_3, sramA_wdata_4, sramA_wdata_5, sramA_wdata_6, sramA_wdata_7,
    output reg [BW_PER_ADDR-1:0] sramA_wdata_8, sramA_wdata_9, sramA_wdata_10, sramA_wdata_11, sramA_wdata_12, sramA_wdata_13, sramA_wdata_14, sramA_wdata_15,
    output reg [ADDR_WIDTH-1:0] sramA_addr_0, sramA_addr_1, sramA_addr_2, sramA_addr_3, sramA_addr_4, sramA_addr_5, sramA_addr_6, sramA_addr_7,
    output reg [ADDR_WIDTH-1:0] sramA_addr_8, sramA_addr_9, sramA_addr_10, sramA_addr_11, sramA_addr_12, sramA_addr_13, sramA_addr_14, sramA_addr_15,
    input [BW_PER_ADDR-1:0] sramA_rdata_0, sramA_rdata_1, sramA_rdata_2, sramA_rdata_3, sramA_rdata_4, sramA_rdata_5, sramA_rdata_6, sramA_rdata_7,
    input [BW_PER_ADDR-1:0] sramA_rdata_8, sramA_rdata_9, sramA_rdata_10, sramA_rdata_11, sramA_rdata_12, sramA_rdata_13, sramA_rdata_14, sramA_rdata_15,
    
    // SRAM B interface (for ping-pong)
    output reg sramB_csb,
    output reg sramB_wsb_0, sramB_wsb_1, sramB_wsb_2, sramB_wsb_3, sramB_wsb_4, sramB_wsb_5, sramB_wsb_6, sramB_wsb_7,
    output reg sramB_wsb_8, sramB_wsb_9, sramB_wsb_10, sramB_wsb_11, sramB_wsb_12, sramB_wsb_13, sramB_wsb_14, sramB_wsb_15,
    output reg [BW_PER_ADDR-1:0] sramB_wdata_0, sramB_wdata_1, sramB_wdata_2, sramB_wdata_3, sramB_wdata_4, sramB_wdata_5, sramB_wdata_6, sramB_wdata_7,
    output reg [BW_PER_ADDR-1:0] sramB_wdata_8, sramB_wdata_9, sramB_wdata_10, sramB_wdata_11, sramB_wdata_12, sramB_wdata_13, sramB_wdata_14, sramB_wdata_15,
    output reg [ADDR_WIDTH-1:0] sramB_addr_0, sramB_addr_1, sramB_addr_2, sramB_addr_3, sramB_addr_4, sramB_addr_5, sramB_addr_6, sramB_addr_7,
    output reg [ADDR_WIDTH-1:0] sramB_addr_8, sramB_addr_9, sramB_addr_10, sramB_addr_11, sramB_addr_12, sramB_addr_13, sramB_addr_14, sramB_addr_15,
    input [BW_PER_ADDR-1:0] sramB_rdata_0, sramB_rdata_1, sramB_rdata_2, sramB_rdata_3, sramB_rdata_4, sramB_rdata_5, sramB_rdata_6, sramB_rdata_7,
    input [BW_PER_ADDR-1:0] sramB_rdata_8, sramB_rdata_9, sramB_rdata_10, sramB_rdata_11, sramB_rdata_12, sramB_rdata_13, sramB_rdata_14, sramB_rdata_15,
    
    // Twiddle ROM interface (16 banks)
    output reg [0:0] twiddle_addr_0, twiddle_addr_1, twiddle_addr_2, twiddle_addr_3,
    output reg [0:0] twiddle_addr_4, twiddle_addr_5, twiddle_addr_6, twiddle_addr_7,
    output reg [0:0] twiddle_addr_8, twiddle_addr_9, twiddle_addr_10, twiddle_addr_11,
    output reg [0:0] twiddle_addr_12, twiddle_addr_13, twiddle_addr_14, twiddle_addr_15,
    input [BW_PER_ADDR-1:0] twiddle_data_0, twiddle_data_1, twiddle_data_2, twiddle_data_3,
    input [BW_PER_ADDR-1:0] twiddle_data_4, twiddle_data_5, twiddle_data_6, twiddle_data_7,
    input [BW_PER_ADDR-1:0] twiddle_data_8, twiddle_data_9, twiddle_data_10, twiddle_data_11,
    input [BW_PER_ADDR-1:0] twiddle_data_12, twiddle_data_13, twiddle_data_14, twiddle_data_15,
    
    // Control signals
    input start,
    output  done,

    // Mul interfaces (from testbench, shared by bpe instances)
    // BPE 0 mul interface (128-bit: 64-bit real + 64-bit imag)
    output  wire [127:0] bpe0_mul_in_A,
    output  wire [127:0] bpe0_mul_in_B,
    output  wire [1:0]   bpe0_mul_mode,
    output  wire         bpe0_mul_in_valid,
    input   wire [127:0] bpe0_mul_result_c,
    input   wire [127:0] bpe0_mul_result_int,
    input   wire         bpe0_mul_out_valid,

    // BPE 1 mul interface (128-bit: 64-bit real + 64-bit imag)
    output  wire [127:0] bpe1_mul_in_A,
    output  wire [127:0] bpe1_mul_in_B,
    output  wire [1:0]   bpe1_mul_mode,
    output  wire         bpe1_mul_in_valid,
    input   wire [127:0] bpe1_mul_result_c,
    input   wire [127:0] bpe1_mul_result_int,
    input   wire         bpe1_mul_out_valid,

    // FP_ADD interfaces (from testbench, 4 per bpe, total 8)
    // BPE 0 fp_add interfaces
    output  wire [63:0]  bpe0_fp_add_01_in_A, bpe0_fp_add_01_in_B,
    output  wire         bpe0_fp_add_01_in_valid,
    input   wire [63:0]  bpe0_fp_add_01_result,
    input   wire         bpe0_fp_add_01_out_valid,

    output  wire [63:0]  bpe0_fp_add_02_in_A, bpe0_fp_add_02_in_B,
    output  wire         bpe0_fp_add_02_in_valid,
    input   wire [63:0]  bpe0_fp_add_02_result,
    input   wire         bpe0_fp_add_02_out_valid,

    output  wire [63:0]  bpe0_fp_add_11_in_A, bpe0_fp_add_11_in_B,
    output  wire         bpe0_fp_add_11_in_valid,
    input   wire [63:0]  bpe0_fp_add_11_result,
    input   wire         bpe0_fp_add_11_out_valid,

    output  wire [63:0]  bpe0_fp_add_12_in_A, bpe0_fp_add_12_in_B,
    output  wire         bpe0_fp_add_12_in_valid,
    input   wire [63:0]  bpe0_fp_add_12_result,
    input   wire         bpe0_fp_add_12_out_valid,

    // BPE 1 fp_add interfaces
    output  wire [63:0]  bpe1_fp_add_01_in_A, bpe1_fp_add_01_in_B,
    output  wire         bpe1_fp_add_01_in_valid,
    input   wire [63:0]  bpe1_fp_add_01_result,
    input   wire         bpe1_fp_add_01_out_valid,

    output  wire [63:0]  bpe1_fp_add_02_in_A, bpe1_fp_add_02_in_B,
    output  wire         bpe1_fp_add_02_in_valid,
    input   wire [63:0]  bpe1_fp_add_02_result,
    input   wire         bpe1_fp_add_02_out_valid,

    output  wire [63:0]  bpe1_fp_add_11_in_A, bpe1_fp_add_11_in_B,
    output  wire         bpe1_fp_add_11_in_valid,
    input   wire [63:0]  bpe1_fp_add_11_result,
    input   wire         bpe1_fp_add_11_out_valid,

    output  wire [63:0]  bpe1_fp_add_12_in_A, bpe1_fp_add_12_in_B,
    output  wire         bpe1_fp_add_12_in_valid,
    input   wire [63:0]  bpe1_fp_add_12_result,
    input   wire         bpe1_fp_add_12_out_valid
);

// == states == //
localparam IDLE = 4'b0000;
localparam REV  = 4'b0001;
localparam S1   = 4'b0010;
localparam S2   = 4'b0011;
localparam S3   = 4'b0100;
localparam S4   = 4'b0101;
localparam S5   = 4'b0110;
localparam R2C  = 4'b0111;
localparam MOVE = 4'b1000;
localparam MS = 4'b1001;
// == parameter == //
reg [3:0] stage, nxt_stage;
reg [9:0] cnt_in, cnt_out, nxt_cnt_in, nxt_cnt_out, cnt_in_prv;
reg [5:0] round_cnt, nxt_round_cnt;
reg col, col_nxt;
// == Internal signals == //
// BPE input/output signals
reg [BW_PER_ADDR-1:0] bpe0_ai, bpe0_bi;
wire [BW_PER_ADDR-1:0]bpe0_ao, bpe0_bo;
reg [BW_PER_ADDR-1:0] bpe1_ai, bpe1_bi;
wire [BW_PER_ADDR-1:0]bpe1_ao, bpe1_bo;
reg [BW_PER_ADDR-1:0] bpe0_gm, bpe1_gm;

reg bpe0_i_vld, bpe0_o_rdy, bpe1_i_vld, bpe1_o_rdy;
wire bpe0_i_rdy, bpe0_o_vld, bpe1_i_rdy, bpe1_o_vld;


// BPE output valid/ready 
wire BPE_o_vld, BPE_o_rdy;
assign BPE_o_vld = bpe0_o_vld & bpe1_o_vld;
assign BPE_o_rdy = bpe0_o_rdy & bpe1_o_rdy;
// buffer
reg [BW_PER_ADDR-1:0] buf0, buf1;
reg [BW_PER_ADDR-1:0] bpe0_bi_reg, bpe1_bi_reg, buf1_reg, buf0_reg;
reg [BW_PER_ADDR-1:0] bpe0_gm_reg, bpe1_gm_reg;
reg [BW_PER_ADDR-1:0] sramB_data;

assign done = (stage == R2C && cnt_out == 1023 && col == 1);
// done signal: asserted when bit reverse stage completes (for both row and column FFT/IFFT)
// assign done = (stage == S1 && cnt_out == 7);
// assign done = (stage == REV && cnt_out == 3);
// twiddle 
reg [BW_PER_ADDR-1:0] twiddle_data_0_in;
reg [BW_PER_ADDR-1:0] twiddle_data_1_in;
reg [BW_PER_ADDR-1:0] twiddle_data_2_in;
reg [BW_PER_ADDR-1:0] twiddle_data_3_in;
reg [BW_PER_ADDR-1:0] twiddle_data_4_in;
reg [BW_PER_ADDR-1:0] twiddle_data_5_in;
reg [BW_PER_ADDR-1:0] twiddle_data_6_in;
reg [BW_PER_ADDR-1:0] twiddle_data_7_in;
reg [BW_PER_ADDR-1:0] twiddle_data_8_in;
reg [BW_PER_ADDR-1:0] twiddle_data_9_in;
reg [BW_PER_ADDR-1:0] twiddle_data_10_in;
reg [BW_PER_ADDR-1:0] twiddle_data_11_in;
reg [BW_PER_ADDR-1:0] twiddle_data_12_in;
reg [BW_PER_ADDR-1:0] twiddle_data_13_in;
reg [BW_PER_ADDR-1:0] twiddle_data_14_in;
reg [BW_PER_ADDR-1:0] twiddle_data_15_in;

always@* begin
    case(mode)
        0: begin
            twiddle_data_0_in  = twiddle_data_0;
            twiddle_data_1_in  = twiddle_data_1;
            twiddle_data_2_in  = twiddle_data_2;
            twiddle_data_3_in  = twiddle_data_3;
            twiddle_data_4_in  = twiddle_data_4;
            twiddle_data_5_in  = twiddle_data_5;
            twiddle_data_6_in  = twiddle_data_6;
            twiddle_data_7_in  = twiddle_data_7;
            twiddle_data_8_in  = twiddle_data_8;
            twiddle_data_9_in  = twiddle_data_9;
            twiddle_data_10_in = twiddle_data_10;
            twiddle_data_11_in = twiddle_data_11;
            twiddle_data_12_in = twiddle_data_12;
            twiddle_data_13_in = twiddle_data_13;
            twiddle_data_14_in = twiddle_data_14;
            twiddle_data_15_in = twiddle_data_15;
        end 
        1: begin
            twiddle_data_0_in  = {twiddle_data_0[127:64], ~twiddle_data_0[63], twiddle_data_0[62:0]};
            twiddle_data_1_in  = {twiddle_data_1[127:64], ~twiddle_data_1[63], twiddle_data_1[62:0]};
            twiddle_data_2_in  = {twiddle_data_2[127:64], ~twiddle_data_2[63], twiddle_data_2[62:0]};
            twiddle_data_3_in  = {twiddle_data_3[127:64], ~twiddle_data_3[63], twiddle_data_3[62:0]};
            twiddle_data_4_in  = {twiddle_data_4[127:64], ~twiddle_data_4[63], twiddle_data_4[62:0]};
            twiddle_data_5_in  = {twiddle_data_5[127:64], ~twiddle_data_5[63], twiddle_data_5[62:0]};
            twiddle_data_6_in  = {twiddle_data_6[127:64], ~twiddle_data_6[63], twiddle_data_6[62:0]};
            twiddle_data_7_in  = {twiddle_data_7[127:64], ~twiddle_data_7[63], twiddle_data_7[62:0]};
            twiddle_data_8_in  = {twiddle_data_8[127:64], ~twiddle_data_8[63], twiddle_data_8[62:0]};
            twiddle_data_9_in  = {twiddle_data_9[127:64], ~twiddle_data_9[63], twiddle_data_9[62:0]};
            twiddle_data_10_in = {twiddle_data_10[127:64], ~twiddle_data_10[63], twiddle_data_10[62:0]};
            twiddle_data_11_in = {twiddle_data_11[127:64], ~twiddle_data_11[63], twiddle_data_11[62:0]};
            twiddle_data_12_in = {twiddle_data_12[127:64], ~twiddle_data_12[63], twiddle_data_12[62:0]};
            twiddle_data_13_in = {twiddle_data_13[127:64], ~twiddle_data_13[63], twiddle_data_13[62:0]};
            twiddle_data_14_in = {twiddle_data_14[127:64], ~twiddle_data_14[63], twiddle_data_14[62:0]};
            twiddle_data_15_in = {twiddle_data_15[127:64], ~twiddle_data_15[63], twiddle_data_15[62:0]};
        end
        default: begin
            twiddle_data_0_in  = 0;
            twiddle_data_1_in  = 0;
            twiddle_data_2_in  = 0;
            twiddle_data_3_in  = 0;
            twiddle_data_4_in  = 0;
            twiddle_data_5_in  = 0;
            twiddle_data_6_in  = 0;
            twiddle_data_7_in  = 0;
            twiddle_data_8_in  = 0;
            twiddle_data_9_in  = 0;
            twiddle_data_10_in = 0;
            twiddle_data_11_in = 0;
            twiddle_data_12_in = 0;
            twiddle_data_13_in = 0;
            twiddle_data_14_in = 0;
            twiddle_data_15_in = 0;
        end
    endcase
end
// == stage operations == //
always@* begin
    nxt_stage = IDLE;
    nxt_cnt_in = 0;
    nxt_cnt_out = 0;
    nxt_round_cnt = round_cnt;

    sramA_wsb_0  = 1;
    sramA_wsb_1  = 1;
    sramA_wsb_2  = 1;
    sramA_wsb_3  = 1;
    sramA_wsb_4  = 1;
    sramA_wsb_5  = 1;
    sramA_wsb_6  = 1;
    sramA_wsb_7  = 1;
    sramA_wsb_8  = 1;
    sramA_wsb_9  = 1;
    sramA_wsb_10 = 1;
    sramA_wsb_11 = 1;
    sramA_wsb_12 = 1;
    sramA_wsb_13 = 1;
    sramA_wsb_14 = 1;
    sramA_wsb_15 = 1;

    sramB_wsb_0  = 1;
    sramB_wsb_1  = 1;
    sramB_wsb_2  = 1;
    sramB_wsb_3  = 1;
    sramB_wsb_4  = 1;
    sramB_wsb_5  = 1;
    sramB_wsb_6  = 1;
    sramB_wsb_7  = 1;
    sramB_wsb_8  = 1;
    sramB_wsb_9  = 1;
    sramB_wsb_10 = 1;
    sramB_wsb_11 = 1;
    sramB_wsb_12 = 1;
    sramB_wsb_13 = 1;
    sramB_wsb_14 = 1;
    sramB_wsb_15 = 1;

    sramA_addr_0 =  0;
    sramA_addr_1 =  0;
    sramA_addr_2 =  0;
    sramA_addr_3 =  0;
    sramA_addr_4 =  0;
    sramA_addr_5 =  0;
    sramA_addr_6 =  0;
    sramA_addr_7 =  0;
    sramA_addr_8 =  0;
    sramA_addr_9 =  0;
    sramA_addr_10 = 0;
    sramA_addr_11 = 0;
    sramA_addr_12 = 0;
    sramA_addr_13 = 0;
    sramA_addr_14 = 0;
    sramA_addr_15 = 0;
    
    sramB_addr_0  = 0;
    sramB_addr_1  = 0;
    sramB_addr_2  = 0;
    sramB_addr_3  = 0;
    sramB_addr_4  = 0;
    sramB_addr_5  = 0;
    sramB_addr_6  = 0;
    sramB_addr_7  = 0;
    sramB_addr_8  = 0;
    sramB_addr_9  = 0;
    sramB_addr_10 = 0;
    sramB_addr_11 = 0;
    sramB_addr_12 = 0;
    sramB_addr_13 = 0;
    sramB_addr_14 = 0;
    sramB_addr_15 = 0;
    
    twiddle_addr_0  = 0;
    twiddle_addr_1  = 0;
    twiddle_addr_2  = 0;
    twiddle_addr_3  = 0;
    twiddle_addr_4  = 0;
    twiddle_addr_5  = 0;
    twiddle_addr_6  = 0;
    twiddle_addr_7  = 0;
    twiddle_addr_8  = 0;
    twiddle_addr_9  = 0;
    twiddle_addr_10 = 0;
    twiddle_addr_11 = 0;
    twiddle_addr_12 = 0;
    twiddle_addr_13 = 0;
    twiddle_addr_14 = 0;
    twiddle_addr_15 = 0;
    
    sramB_wdata_0  = 0;
    sramB_wdata_1  = 0;
    sramB_wdata_2  = 0;
    sramB_wdata_3  = 0;
    sramB_wdata_4  = 0;
    sramB_wdata_5  = 0;
    sramB_wdata_6  = 0;
    sramB_wdata_7  = 0;
    sramB_wdata_8  = 0;
    sramB_wdata_9  = 0;
    sramB_wdata_10 = 0;
    sramB_wdata_11 = 0;
    sramB_wdata_12 = 0;
    sramB_wdata_13 = 0;
    sramB_wdata_14 = 0;
    sramB_wdata_15 = 0;

    sramA_wdata_0  = 0;
    sramA_wdata_1  = 0;
    sramA_wdata_2  = 0;
    sramA_wdata_3  = 0;
    sramA_wdata_4  = 0;
    sramA_wdata_5  = 0;
    sramA_wdata_6  = 0;
    sramA_wdata_7  = 0;
    sramA_wdata_8  = 0;
    sramA_wdata_9  = 0;
    sramA_wdata_10 = 0;
    sramA_wdata_11 = 0;
    sramA_wdata_12 = 0;
    sramA_wdata_13 = 0;
    sramA_wdata_14 = 0;
    sramA_wdata_15 = 0;

    bpe0_i_vld = 0;
    bpe1_i_vld = 0;
    bpe0_o_rdy = 0;
    bpe1_o_rdy = 0;

    bpe0_ai = 0;
    bpe0_bi = 0;
    bpe1_ai = 0;
    bpe1_bi = 0;
    bpe0_gm = 0;
    bpe1_gm = 0;

    col_nxt = col;
    case(stage)
        IDLE: begin
            nxt_stage = (start) ? REV : IDLE;
            nxt_cnt_in = 0;
            nxt_cnt_out = 0;
            nxt_round_cnt = (start) ? 0 : round_cnt;
        end
        REV : begin
            nxt_stage = (cnt_out == 3) ? (mode == 1) ? MS : S1 : REV;
            
            nxt_cnt_in = (cnt_out == 3) ? 0: cnt_in + 1;
            nxt_cnt_out = (cnt_out == 3) ? 0 : (cnt_in);

            // Enable SRAM for bit reverse operation
            sramA_csb = 0;  // Enable SRAM A for reading
            sramB_csb = 0;  // Enable SRAM B for writing

            sramA_wsb_0  = 1;
            sramA_wsb_1  = 1;
            sramA_wsb_2  = 1;
            sramA_wsb_3  = 1;
            sramA_wsb_4  = 1;
            sramA_wsb_5  = 1;
            sramA_wsb_6  = 1;
            sramA_wsb_7  = 1;
            sramA_wsb_8  = 1;
            sramA_wsb_9  = 1;
            sramA_wsb_10 = 1;
            sramA_wsb_11 = 1;
            sramA_wsb_12 = 1;
            sramA_wsb_13 = 1;
            sramA_wsb_14 = 1;
            sramA_wsb_15 = 1;

            sramB_wsb_0  = (cnt_out<= 3) ? (cnt_out[1]) : 1;
            sramB_wsb_1  = (cnt_out<= 3) ? (~cnt_out[1]) : 1;
            sramB_wsb_2  = (cnt_out<= 3) ? (cnt_out[1]) : 1;
            sramB_wsb_3  = (cnt_out<= 3) ? (~cnt_out[1]) : 1;
            sramB_wsb_4  = (cnt_out<= 3) ? (cnt_out[1]) : 1;
            sramB_wsb_5  = (cnt_out<= 3) ? (~cnt_out[1]) : 1;
            sramB_wsb_6  = (cnt_out<= 3) ? (cnt_out[1]) : 1;
            sramB_wsb_7  = (cnt_out<= 3) ? (~cnt_out[1]) : 1;
            sramB_wsb_8  = (cnt_out<= 3) ? (cnt_out[1]) : 1;
            sramB_wsb_9  = (cnt_out<= 3) ? (~cnt_out[1]) : 1;
            sramB_wsb_10 = (cnt_out<= 3) ? (cnt_out[1]) : 1;
            sramB_wsb_11 = (cnt_out<= 3) ? (~cnt_out[1]) : 1;
            sramB_wsb_12 = (cnt_out<= 3) ? (cnt_out[1]) : 1;
            sramB_wsb_13 = (cnt_out<= 3) ? (~cnt_out[1]) : 1; 
            sramB_wsb_14 = (cnt_out<= 3) ? (cnt_out[1]) : 1;
            sramB_wsb_15 = (cnt_out<= 3) ? (~cnt_out[1]) : 1; 

            sramA_addr_0 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_1 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_2 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_3 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_4 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_5 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_6 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_7 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_8 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_9 = (cnt_in[1])  ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_10 = (cnt_in[1]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_11 = (cnt_in[1]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_12 = (cnt_in[1]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_13 = (cnt_in[1]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_14 = (cnt_in[1]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_15 = (cnt_in[1]) ?  (round_cnt << 1) + 1 : round_cnt << 1;

            sramB_addr_0 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_1 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_2 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_3 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_4 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_5 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_6 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_7 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_8 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_9 =  (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_10 = (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_11 = (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_12 = (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_13 = (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_14 = (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_15 = (cnt_out[0]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            
            sramB_wdata_0  = (cnt_out[0]) ? sramA_rdata_1  : sramA_rdata_0;
            sramB_wdata_1  = (cnt_out[0]) ? sramA_rdata_1  : sramA_rdata_0;
            sramB_wdata_2  = (cnt_out[0]) ? sramA_rdata_9  : sramA_rdata_8;
            sramB_wdata_3  = (cnt_out[0]) ? sramA_rdata_9  : sramA_rdata_8;
            sramB_wdata_4  = (cnt_out[0]) ? sramA_rdata_5  : sramA_rdata_4;
            sramB_wdata_5  = (cnt_out[0]) ? sramA_rdata_5  : sramA_rdata_4;
            sramB_wdata_6  = (cnt_out[0]) ? sramA_rdata_13 : sramA_rdata_12;
            sramB_wdata_7  = (cnt_out[0]) ? sramA_rdata_13 : sramA_rdata_12;
            sramB_wdata_8  = (cnt_out[0]) ? sramA_rdata_3  : sramA_rdata_2;
            sramB_wdata_9  = (cnt_out[0]) ? sramA_rdata_3  : sramA_rdata_2;
            sramB_wdata_10 = (cnt_out[0]) ? sramA_rdata_11 : sramA_rdata_10;
            sramB_wdata_11 = (cnt_out[0]) ? sramA_rdata_11 : sramA_rdata_10;
            sramB_wdata_12 = (cnt_out[0]) ? sramA_rdata_7  : sramA_rdata_6;
            sramB_wdata_13 = (cnt_out[0]) ? sramA_rdata_7  : sramA_rdata_6;
            sramB_wdata_14 = (cnt_out[0]) ? sramA_rdata_15 : sramA_rdata_14;
            sramB_wdata_15 = (cnt_out[0]) ? sramA_rdata_15 : sramA_rdata_14;

        end
        MS : begin
            nxt_stage = (cnt_in == 60) ? S1 : MS;
            
            nxt_cnt_in = (cnt_in == 60) ? 0: cnt_in + 1;
            nxt_cnt_out = 0;

            bpe0_i_vld = (cnt_in == 0 || cnt_in == 28);
            bpe1_i_vld = (cnt_in == 0 || cnt_in == 28);
            
            sramA_wsb_0  = 1;
            sramA_wsb_1  = 1;
            sramA_wsb_2  = 1;
            sramA_wsb_3  = 1;
            sramA_wsb_4  = 1;
            sramA_wsb_5  = 1;
            sramA_wsb_6  = 1;
            sramA_wsb_7  = 1;
            sramA_wsb_8  = 1;
            sramA_wsb_9  = 1;
            sramA_wsb_10 = 1;
            sramA_wsb_11 = 1;
            sramA_wsb_12 = 1;
            sramA_wsb_13 = 1;
            sramA_wsb_14 = 1;
            sramA_wsb_15 = 1;

            sramB_wsb_0  = 1;
            sramB_wsb_1  = 1;
            sramB_wsb_2  = 1;
            sramB_wsb_3  = 1;
            sramB_wsb_4  = 1;
            sramB_wsb_5  = 1;
            sramB_wsb_6  = 1;
            sramB_wsb_7  = 1;
            sramB_wsb_8  = 1;
            sramB_wsb_9  = 1;
            sramB_wsb_10 = 1;
            sramB_wsb_11 = 1;
            sramB_wsb_12 = 1;
            sramB_wsb_13 = 1;
            sramB_wsb_14 = 1;
            sramB_wsb_15 = 1;
        end
        S1  : begin
            nxt_stage = (cnt_out == 7) ? S2 : S1;
            
            nxt_cnt_in = (cnt_out == 7) ? 0 : (cnt_in == 9) ? cnt_in : cnt_in + 1;
            nxt_cnt_out = (cnt_out == 7) ? 0  : (BPE_o_vld & BPE_o_rdy) ? cnt_out + 1 : cnt_out;

            sramA_wsb_0  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_1  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_2  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_3  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_4  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_5  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_6  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_7  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_8  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_9  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_10 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_11 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_12 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramA_wsb_13 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramA_wsb_14 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramA_wsb_15 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);

            sramB_wsb_0  = 1;
            sramB_wsb_1  = 1;
            sramB_wsb_2  = 1;
            sramB_wsb_3  = 1;
            sramB_wsb_4  = 1;
            sramB_wsb_5  = 1;
            sramB_wsb_6  = 1;
            sramB_wsb_7  = 1;
            sramB_wsb_8  = 1;
            sramB_wsb_9  = 1;
            sramB_wsb_10 = 1;
            sramB_wsb_11 = 1;
            sramB_wsb_12 = 1;
            sramB_wsb_13 = 1;
            sramB_wsb_14 = 1;
            sramB_wsb_15 = 1;

            sramA_addr_0  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_1  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_2  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_3  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_4  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_5  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_6  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_7  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_8  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_9  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_10 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_11 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_12 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_13 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_14 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_15 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;

            sramB_addr_0 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_1 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_2 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_3 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_4 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_5 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_6 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_7 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_8 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_9 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_10 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_11 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_12 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_13 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_14 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramB_addr_15 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            
            twiddle_addr_0  = 1'b0;
            twiddle_addr_1  = 1'b0;
            twiddle_addr_2  = 1'b0;
            twiddle_addr_3  = 1'b0;
            twiddle_addr_4  = 1'b0;
            twiddle_addr_5  = 1'b0;
            twiddle_addr_6  = 1'b0;
            twiddle_addr_7  = 1'b0;
            twiddle_addr_8  = 1'b0;
            twiddle_addr_9  = 1'b0;
            twiddle_addr_10 = 1'b0;
            twiddle_addr_11 = 1'b0;
            twiddle_addr_12 = 1'b0;
            twiddle_addr_13 = 1'b0;
            twiddle_addr_14 = 1'b0;
            twiddle_addr_15 = 1'b0;
            
            sramA_wdata_0  = bpe0_ao;
            sramA_wdata_1  = bpe0_bo;
            sramA_wdata_2  = bpe1_ao;
            sramA_wdata_3  = bpe1_bo;
            sramA_wdata_4  = bpe0_ao;
            sramA_wdata_5  = bpe0_bo;
            sramA_wdata_6  = bpe1_ao;
            sramA_wdata_7  = bpe1_bo;
            sramA_wdata_8  = bpe0_ao;
            sramA_wdata_9  = bpe0_bo;
            sramA_wdata_10 = bpe1_ao;
            sramA_wdata_11 = bpe1_bo;
            sramA_wdata_12 = bpe0_ao;
            sramA_wdata_13 = bpe0_bo;
            sramA_wdata_14 = bpe1_ao;
            sramA_wdata_15 = bpe1_bo;

            bpe0_i_vld = (stage == S1 && cnt_in <= 8 && cnt_in >= 1);
            bpe1_i_vld = (stage == S1 && cnt_in <= 8 && cnt_in >= 1);
            bpe0_o_rdy = 1'b1;
            bpe1_o_rdy = 1'b1;

            bpe0_ai = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramB_rdata_12 : sramB_rdata_8) : (cnt_in_prv[0] ? sramB_rdata_4 : sramB_rdata_0);
            bpe0_bi = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramB_rdata_13 : sramB_rdata_9) : (cnt_in_prv[0] ? sramB_rdata_5 : sramB_rdata_1);
            bpe1_ai = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramB_rdata_14 : sramB_rdata_10) : (cnt_in_prv[0] ? sramB_rdata_6 : sramB_rdata_2);
            bpe1_bi = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramB_rdata_15 : sramB_rdata_11) : (cnt_in_prv[0] ? sramB_rdata_7 : sramB_rdata_3);
            bpe0_gm = twiddle_data_0_in;
            bpe1_gm = twiddle_data_0_in;
        end
        S2  : begin
            nxt_stage = (cnt_out == 7) ? S3 : S2;
            
            nxt_cnt_in = (cnt_out == 7) ? 0 : (cnt_in == 9) ? cnt_in : cnt_in + 1;
            nxt_cnt_out = (cnt_out == 7) ? 0  : (BPE_o_vld & BPE_o_rdy) ? cnt_out + 1 : cnt_out;

            sramA_wsb_0  = 1;
            sramA_wsb_1  = 1;
            sramA_wsb_2  = 1;
            sramA_wsb_3  = 1;
            sramA_wsb_4  = 1;
            sramA_wsb_5  = 1;
            sramA_wsb_6  = 1;
            sramA_wsb_7  = 1;
            sramA_wsb_8  = 1;
            sramA_wsb_9  = 1;
            sramA_wsb_10 = 1;
            sramA_wsb_11 = 1;
            sramA_wsb_12 = 1;
            sramA_wsb_13 = 1;
            sramA_wsb_14 = 1;
            sramA_wsb_15 = 1;

            sramB_wsb_0  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramB_wsb_1  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramB_wsb_2  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramB_wsb_3  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramB_wsb_4  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramB_wsb_5  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramB_wsb_6  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramB_wsb_7  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramB_wsb_8  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramB_wsb_9  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramB_wsb_10 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramB_wsb_11 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramB_wsb_12 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramB_wsb_13 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramB_wsb_14 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramB_wsb_15 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);

            sramA_addr_0 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_1 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_2 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_3 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_4 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_5 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_6 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_7 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_8 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_9 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_10 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_11 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_12 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_13 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_14 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_15 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            
            sramB_addr_0  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_1  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_2  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_3  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_4  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_5  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_6  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_7  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_8  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_9  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_10 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_11 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_12 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_13 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_14 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_15 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            
            twiddle_addr_0  = 0;
            twiddle_addr_1  = 0;
            twiddle_addr_2  = 0;
            twiddle_addr_3  = 0;
            twiddle_addr_4  = 0;
            twiddle_addr_5  = 0;
            twiddle_addr_6  = 0;
            twiddle_addr_7  = 0;
            twiddle_addr_8  = 0;
            twiddle_addr_9  = 0;
            twiddle_addr_10 = 0;
            twiddle_addr_11 = 0;
            twiddle_addr_12 = 0;
            twiddle_addr_13 = 0;
            twiddle_addr_14 = 0;
            twiddle_addr_15 = 0;
            
            sramB_wdata_0  = bpe0_ao;
            sramB_wdata_1  = bpe1_ao;
            sramB_wdata_2  = bpe0_bo;
            sramB_wdata_3  = bpe1_bo;
            sramB_wdata_4  = bpe0_ao;
            sramB_wdata_5  = bpe1_ao;
            sramB_wdata_6  = bpe0_bo;
            sramB_wdata_7  = bpe1_bo;
            sramB_wdata_8  = bpe0_ao;
            sramB_wdata_9  = bpe1_ao;
            sramB_wdata_10 = bpe0_bo;
            sramB_wdata_11 = bpe1_bo;
            sramB_wdata_12 = bpe0_ao;
            sramB_wdata_13 = bpe1_ao;
            sramB_wdata_14 = bpe0_bo;
            sramB_wdata_15 = bpe1_bo;

            bpe0_i_vld = (stage == S2 && cnt_in <= 8 && cnt_in >= 1);
            bpe1_i_vld = (stage == S2 && cnt_in <= 8 && cnt_in >= 1);
            bpe0_o_rdy = 1'b1;
            bpe1_o_rdy = 1'b1;

            bpe0_ai = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramA_rdata_12 : sramA_rdata_8)  : (cnt_in_prv[0] ? sramA_rdata_4 : sramA_rdata_0);
            bpe0_bi = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramA_rdata_14 : sramA_rdata_10) : (cnt_in_prv[0] ? sramA_rdata_6 : sramA_rdata_2);
            bpe1_ai = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramA_rdata_13 : sramA_rdata_9)  : (cnt_in_prv[0] ? sramA_rdata_5 : sramA_rdata_1);
            bpe1_bi = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramA_rdata_15 : sramA_rdata_11) : (cnt_in_prv[0] ? sramA_rdata_7 : sramA_rdata_3);
            bpe0_gm = twiddle_data_1_in;
            bpe1_gm = twiddle_data_2_in;
        end
        S3  : begin
            nxt_stage = (cnt_out == 7) ? S4 : S3;
            
            nxt_cnt_in = (cnt_out == 7) ? 0 : (cnt_in == 9) ? cnt_in : cnt_in + 1;
            nxt_cnt_out = (cnt_out == 7) ? 0  : (BPE_o_vld & BPE_o_rdy) ? cnt_out + 1 : cnt_out;

            sramB_wsb_0  = 1;
            sramB_wsb_1  = 1;
            sramB_wsb_2  = 1;
            sramB_wsb_3  = 1;
            sramB_wsb_4  = 1;
            sramB_wsb_5  = 1;
            sramB_wsb_6  = 1;
            sramB_wsb_7  = 1;
            sramB_wsb_8  = 1;
            sramB_wsb_9  = 1;
            sramB_wsb_10 = 1;
            sramB_wsb_11 = 1;
            sramB_wsb_12 = 1;
            sramB_wsb_13 = 1;
            sramB_wsb_14 = 1;
            sramB_wsb_15 = 1;


            sramA_wsb_0  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_1  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_2  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_3  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_4  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_5  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_6  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_7  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_8  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_9  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_10 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramA_wsb_11 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramA_wsb_12 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_13 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_14 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramA_wsb_15 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);

            sramA_addr_0 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_1 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_2 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_3 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_4 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_5 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_6 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_7 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_8 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_9 =  (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_10 = (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_11 = (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_12 = (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_13 = (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_14 = (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_15 = (cnt_out[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            
            sramB_addr_0  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_1  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_2  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_3  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_4  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_5  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_6  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_7  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_8  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_9  = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_10 = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_11 = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_12 = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_13 = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_14 = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_15 = (cnt_in[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            
            twiddle_addr_0  = 0;
            twiddle_addr_1  = 0;
            twiddle_addr_2  = 0;
            twiddle_addr_3  = 0;
            twiddle_addr_4  = 0;
            twiddle_addr_5  = 0;
            twiddle_addr_6  = 0;
            twiddle_addr_7  = 0;
            twiddle_addr_8  = 0;
            twiddle_addr_9  = 0;
            twiddle_addr_10 = 0;
            twiddle_addr_11 = 0;
            twiddle_addr_12 = 0;
            twiddle_addr_13 = 0;
            twiddle_addr_14 = 0;
            twiddle_addr_15 = 0;
            
            sramA_wdata_0  = bpe0_ao;
            sramA_wdata_1  = bpe1_ao;
            sramA_wdata_2  = bpe0_ao;
            sramA_wdata_3  = bpe1_ao;
            sramA_wdata_4  = bpe0_bo;
            sramA_wdata_5  = bpe1_bo;
            sramA_wdata_6  = bpe0_bo;
            sramA_wdata_7  = bpe1_bo;
            sramA_wdata_8  = bpe0_ao;
            sramA_wdata_9  = bpe1_ao;
            sramA_wdata_10 = bpe0_ao;
            sramA_wdata_11 = bpe1_ao;
            sramA_wdata_12 = bpe0_bo;
            sramA_wdata_13 = bpe1_bo;
            sramA_wdata_14 = bpe0_bo;
            sramA_wdata_15 = bpe1_bo;

            bpe0_i_vld = (stage == S3 && cnt_in <= 8 && cnt_in >= 1);
            bpe1_i_vld = (stage == S3 && cnt_in <= 8 && cnt_in >= 1);
            bpe0_o_rdy = 1'b1;
            bpe1_o_rdy = 1'b1;

            bpe0_ai = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramB_rdata_10 : sramB_rdata_8)  : (cnt_in_prv[0] ? sramB_rdata_2 : sramB_rdata_0);
            bpe0_bi = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramB_rdata_14 : sramB_rdata_12) : (cnt_in_prv[0] ? sramB_rdata_6 : sramB_rdata_4);
            bpe1_ai = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramB_rdata_11 : sramB_rdata_9)  : (cnt_in_prv[0] ? sramB_rdata_3 : sramB_rdata_1);
            bpe1_bi = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramB_rdata_15 : sramB_rdata_13) : (cnt_in_prv[0] ? sramB_rdata_7 : sramB_rdata_5);
            bpe0_gm = (cnt_in[0]) ? twiddle_data_3_in : twiddle_data_5_in;
            bpe1_gm = (cnt_in[0]) ? twiddle_data_4_in : twiddle_data_6_in;
        end
        S4  : begin
            nxt_stage = (cnt_out == 7) ? S5 : S4;
            
            nxt_cnt_in = (cnt_out == 7) ? 0 : (cnt_in == 9) ? cnt_in : cnt_in + 1;
            nxt_cnt_out = (cnt_out == 7) ? 0  : (BPE_o_vld & BPE_o_rdy) ? cnt_out + 1 : cnt_out;

            sramA_wsb_0  = 1;
            sramA_wsb_1  = 1;
            sramA_wsb_2  = 1;
            sramA_wsb_3  = 1;
            sramA_wsb_4  = 1;
            sramA_wsb_5  = 1;
            sramA_wsb_6  = 1;
            sramA_wsb_7  = 1;
            sramA_wsb_8  = 1;
            sramA_wsb_9  = 1;
            sramA_wsb_10 = 1;
            sramA_wsb_11 = 1;
            sramA_wsb_12 = 1;
            sramA_wsb_13 = 1;
            sramA_wsb_14 = 1;
            sramA_wsb_15 = 1;


            sramB_wsb_0  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramB_wsb_1  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramB_wsb_2  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramB_wsb_3  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramB_wsb_4  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramB_wsb_5  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramB_wsb_6  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramB_wsb_7  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramB_wsb_8  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramB_wsb_9  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramB_wsb_10 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramB_wsb_11 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramB_wsb_12 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramB_wsb_13 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramB_wsb_14 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramB_wsb_15 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);

            

            sramA_addr_0 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_1 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_2 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_3 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_4 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_5 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_6 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_7 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_8 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_9 =  (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_10 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_11 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_12 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_13 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_14 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            sramA_addr_15 = (cnt_in[2]) ? (round_cnt << 1) + 1: (round_cnt << 1);
            
            sramB_addr_0  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_1  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_2  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_3  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_4  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_5  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_6  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_7  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_8  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_9  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_10 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_11 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_12 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_13 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_14 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramB_addr_15 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            
            twiddle_addr_0  = 0;
            twiddle_addr_1  = 0;
            twiddle_addr_2  = 0;
            twiddle_addr_3  = 0;
            twiddle_addr_4  = 0;
            twiddle_addr_5  = 0;
            twiddle_addr_6  = 0;
            twiddle_addr_7  = 0;
            twiddle_addr_8  = 0;
            twiddle_addr_9  = 0;
            twiddle_addr_10 = 0;
            twiddle_addr_11 = 0;
            twiddle_addr_12 = 0;
            twiddle_addr_13 = 0;
            twiddle_addr_14 = 0;
            twiddle_addr_15 = 0;
            
            sramB_wdata_0  = bpe0_ao;
            sramB_wdata_1  = bpe1_ao;
            sramB_wdata_2  = bpe0_ao;
            sramB_wdata_3  = bpe1_ao;
            sramB_wdata_4  = bpe0_ao;
            sramB_wdata_5  = bpe1_ao;
            sramB_wdata_6  = bpe0_ao;
            sramB_wdata_7  = bpe1_ao;
            sramB_wdata_8  = bpe0_bo;
            sramB_wdata_9  = bpe1_bo;
            sramB_wdata_10 = bpe0_bo;
            sramB_wdata_11 = bpe1_bo;
            sramB_wdata_12 = bpe0_bo;
            sramB_wdata_13 = bpe1_bo;
            sramB_wdata_14 = bpe0_bo;
            sramB_wdata_15 = bpe1_bo;

            bpe0_i_vld = (stage == S4 && cnt_in <= 8 && cnt_in >= 1);
            bpe1_i_vld = (stage == S4 && cnt_in <= 8 && cnt_in >= 1);
            bpe0_o_rdy = 1'b1;
            bpe1_o_rdy = 1'b1;

            bpe0_ai = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramA_rdata_6 : sramA_rdata_4)  : (cnt_in_prv[0] ? sramA_rdata_2 : sramA_rdata_0);
            bpe0_bi = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramA_rdata_14 : sramA_rdata_12) : (cnt_in_prv[0] ? sramA_rdata_10: sramA_rdata_8);
            bpe1_ai = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramA_rdata_7 : sramA_rdata_5)  : (cnt_in_prv[0] ? sramA_rdata_3 : sramA_rdata_1);
            bpe1_bi = cnt_in_prv[1] ? (cnt_in_prv[0] ? sramA_rdata_15 : sramA_rdata_13) : (cnt_in_prv[0] ? sramA_rdata_11 : sramA_rdata_9);
            bpe0_gm = (cnt_in[1]) ? (cnt_in[0]) ? twiddle_data_11_in : twiddle_data_9_in : (cnt_in[0]) ? twiddle_data_7_in : twiddle_data_13_in;
            bpe1_gm = (cnt_in[1]) ? (cnt_in[0]) ? twiddle_data_12_in : twiddle_data_10_in : (cnt_in[0]) ? twiddle_data_8_in : twiddle_data_14_in;
        end
        S5  : begin
            nxt_stage = (cnt_out == 7) ? (round_cnt == 31) ? R2C : REV : S5;  // Stay in S5 until done signal is processed
            nxt_round_cnt = (cnt_out == 7) ? (round_cnt == 31) ? 0 : round_cnt + 1 : round_cnt;
            nxt_cnt_in = (cnt_out == 7) ? 0 : (cnt_in == 10) ? cnt_in : cnt_in + 1;
            nxt_cnt_out = (cnt_out == 7) ? 0  : (BPE_o_vld & BPE_o_rdy) ? cnt_out + 1 : cnt_out;

            sramB_wsb_0  = 1;
            sramB_wsb_1  = 1;
            sramB_wsb_2  = 1;
            sramB_wsb_3  = 1;
            sramB_wsb_4  = 1;
            sramB_wsb_5  = 1;
            sramB_wsb_6  = 1;
            sramB_wsb_7  = 1;
            sramB_wsb_8  = 1;
            sramB_wsb_9  = 1;
            sramB_wsb_10 = 1;
            sramB_wsb_11 = 1;
            sramB_wsb_12 = 1;
            sramB_wsb_13 = 1;
            sramB_wsb_14 = 1;
            sramB_wsb_15 = 1;


            sramA_wsb_0  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_1  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_2  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_3  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b00);
            sramA_wsb_4  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_5  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_6  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_7  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b01);
            sramA_wsb_8  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_9  = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_10 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_11 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b10);
            sramA_wsb_12 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramA_wsb_13 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramA_wsb_14 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);
            sramA_wsb_15 = ~(BPE_o_vld & BPE_o_rdy && cnt_out[1:0] == 2'b11);

            
            sramB_addr_0 =  (cnt_in == 0) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_1 =  (cnt_in == 0) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_2 =  (cnt_in == 1) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_3 =  (cnt_in == 1) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_4 =  (cnt_in == 2) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_5 =  (cnt_in == 2) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_6 =  (cnt_in == 3) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_7 =  (cnt_in == 3) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_8 =  (cnt_in == 4) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_9 =  (cnt_in == 4) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_10 = (cnt_in == 5) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_11 = (cnt_in == 5) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_12 = (cnt_in == 6) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_13 = (cnt_in == 6) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_14 = (cnt_in == 7) ? (round_cnt << 1): (round_cnt << 1) + 1;
            sramB_addr_15 = (cnt_in == 7) ? (round_cnt << 1): (round_cnt << 1) + 1;
            
            sramA_addr_0  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_1  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_2  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_3  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_4  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_5  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_6  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_7  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_8  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_9  = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_10 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_11 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_12 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_13 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_14 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            sramA_addr_15 = (cnt_out[2]) ?  (round_cnt << 1) + 1 : round_cnt << 1;
            
            twiddle_addr_0  = 1;
            twiddle_addr_1  = 1;
            twiddle_addr_2  = 1;
            twiddle_addr_3  = 1;
            twiddle_addr_4  = 1;
            twiddle_addr_5  = 1;
            twiddle_addr_6  = 1;
            twiddle_addr_7  = 1;
            twiddle_addr_8  = 1;
            twiddle_addr_9  = 1;
            twiddle_addr_10 = 1;
            twiddle_addr_11 = 1;
            twiddle_addr_12 = 1;
            twiddle_addr_13 = 1;
            twiddle_addr_14 = 1;
            twiddle_addr_15 = 1;
            
            sramA_wdata_0  = bpe0_ao;
            sramA_wdata_1  = bpe0_bo;
            sramA_wdata_2  = bpe1_ao;
            sramA_wdata_3  = bpe1_bo;
            sramA_wdata_4  = bpe0_ao;
            sramA_wdata_5  = bpe0_bo;
            sramA_wdata_6  = bpe1_ao;
            sramA_wdata_7  = bpe1_bo;
            sramA_wdata_8  = bpe0_ao;
            sramA_wdata_9  = bpe0_bo;
            sramA_wdata_10 = bpe1_ao;
            sramA_wdata_11 = bpe1_bo;
            sramA_wdata_12 = bpe0_ao;
            sramA_wdata_13 = bpe0_bo;
            sramA_wdata_14 = bpe1_ao;
            sramA_wdata_15 = bpe1_bo;

            bpe0_i_vld = (stage == S5 && cnt_in <= 9 && cnt_in >= 2);
            bpe1_i_vld = (stage == S5 && cnt_in <= 9 && cnt_in >= 2);
            bpe0_o_rdy = 1'b1;
            bpe1_o_rdy = 1'b1;

            bpe0_ai = buf0;
            bpe0_bi = bpe0_bi_reg;
            bpe1_ai = buf1;
            bpe1_bi = bpe1_bi_reg;
            bpe0_gm = bpe0_gm_reg;
            bpe1_gm = bpe1_gm_reg;
        end
        R2C: begin
            nxt_stage = (cnt_out == 1023) ? (col == 1) ? IDLE : MOVE : R2C;
            
            nxt_cnt_in = (cnt_out == 1023) ? 0: cnt_in + 1;
            nxt_cnt_out = (cnt_out == 1023) ? 0 : (cnt_in);

            sramA_wsb_0  = 1;
            sramA_wsb_1  = 1;
            sramA_wsb_2  = 1;
            sramA_wsb_3  = 1;
            sramA_wsb_4  = 1;
            sramA_wsb_5  = 1;
            sramA_wsb_6  = 1;
            sramA_wsb_7  = 1;
            sramA_wsb_8  = 1;
            sramA_wsb_9  = 1;
            sramA_wsb_10 = 1;
            sramA_wsb_11 = 1;
            sramA_wsb_12 = 1;
            sramA_wsb_13 = 1;
            sramA_wsb_14 = 1;
            sramA_wsb_15 = 1;

            sramB_wsb_0  = ~(cnt_out[8:5] == 4'd0 );
            sramB_wsb_1  = ~(cnt_out[8:5] == 4'd1 );
            sramB_wsb_2  = ~(cnt_out[8:5] == 4'd2 );
            sramB_wsb_3  = ~(cnt_out[8:5] == 4'd3 );
            sramB_wsb_4  = ~(cnt_out[8:5] == 4'd4 );
            sramB_wsb_5  = ~(cnt_out[8:5] == 4'd5 );
            sramB_wsb_6  = ~(cnt_out[8:5] == 4'd6 );
            sramB_wsb_7  = ~(cnt_out[8:5] == 4'd7 );
            sramB_wsb_8  = ~(cnt_out[8:5] == 4'd8 );
            sramB_wsb_9  = ~(cnt_out[8:5] == 4'd9 );
            sramB_wsb_10 = ~(cnt_out[8:5] == 4'd10);
            sramB_wsb_11 = ~(cnt_out[8:5] == 4'd11);
            sramB_wsb_12 = ~(cnt_out[8:5] == 4'd12);
            sramB_wsb_13 = ~(cnt_out[8:5] == 4'd13);
            sramB_wsb_14 = ~(cnt_out[8:5] == 4'd14);
            sramB_wsb_15 = ~(cnt_out[8:5] == 4'd15);


            sramA_addr_0  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_1  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_2  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_3  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_4  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_5  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_6  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_7  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_8  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_9  = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_10 = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_11 = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_12 = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_13 = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_14 = ((cnt_in >> 5) << 1) | cnt_in[3] ;
            sramA_addr_15 = ((cnt_in >> 5) << 1) | cnt_in[3] ;

            sramB_addr_0 =  ((cnt_in_prv-0) << 1) + (cnt_out[9]);
            sramB_addr_1 =  ((cnt_in_prv-32) << 1) + (cnt_out[9]);
            sramB_addr_2 =  ((cnt_in_prv-64) << 1) + (cnt_out[9]);
            sramB_addr_3 =  ((cnt_in_prv-96) << 1) + (cnt_out[9]);
            sramB_addr_4 =  ((cnt_in_prv-128) << 1) + (cnt_out[9]);
            sramB_addr_5 =  ((cnt_in_prv-160) << 1) + (cnt_out[9]);
            sramB_addr_6 =  ((cnt_in_prv-192) << 1) + (cnt_out[9]);
            sramB_addr_7 =  ((cnt_in_prv-224) << 1) + (cnt_out[9]);
            sramB_addr_8 =  ((cnt_in_prv-256) << 1) + (cnt_out[9]);
            sramB_addr_9 =  ((cnt_in_prv-288) << 1) + (cnt_out[9]);
            sramB_addr_10 = ((cnt_in_prv-320) << 1) + (cnt_out[9]);
            sramB_addr_11 = ((cnt_in_prv-352) << 1) + (cnt_out[9]);
            sramB_addr_12 = ((cnt_in_prv-384) << 1) + (cnt_out[9]);
            sramB_addr_13 = ((cnt_in_prv-416) << 1) + (cnt_out[9]);
            sramB_addr_14 = ((cnt_in_prv-448) << 1) + (cnt_out[9]);
            sramB_addr_15 = ((cnt_in_prv-480) << 1) + (cnt_out[9]);
            
            sramB_wdata_0  =  sramB_data;
            sramB_wdata_1  =  sramB_data;
            sramB_wdata_2  =  sramB_data;
            sramB_wdata_3  =  sramB_data;
            sramB_wdata_4  =  sramB_data;
            sramB_wdata_5  =  sramB_data;
            sramB_wdata_6  =  sramB_data;
            sramB_wdata_7  =  sramB_data;
            sramB_wdata_8  =  sramB_data;
            sramB_wdata_9  =  sramB_data;
            sramB_wdata_10 =  sramB_data;
            sramB_wdata_11 =  sramB_data;
            sramB_wdata_12 =  sramB_data;
            sramB_wdata_13 =  sramB_data;
            sramB_wdata_14 =  sramB_data;
            sramB_wdata_15 =  sramB_data;
        end
        MOVE: begin
            nxt_stage = (cnt_out == 63) ? REV : MOVE;
            
            nxt_cnt_in = (cnt_out == 63) ? 0: cnt_in + 1;
            nxt_cnt_out = (cnt_out == 63) ? 0 : (cnt_in);

            sramB_wsb_0  = 1;
            sramB_wsb_1  = 1;
            sramB_wsb_2  = 1;
            sramB_wsb_3  = 1;
            sramB_wsb_4  = 1;
            sramB_wsb_5  = 1;
            sramB_wsb_6  = 1;
            sramB_wsb_7  = 1;
            sramB_wsb_8  = 1;
            sramB_wsb_9  = 1;
            sramB_wsb_10 = 1;
            sramB_wsb_11 = 1;
            sramB_wsb_12 = 1;
            sramB_wsb_13 = 1;
            sramB_wsb_14 = 1;
            sramB_wsb_15 = 1;

            sramA_wsb_0  = 0;
            sramA_wsb_1  = 0;
            sramA_wsb_2  = 0;
            sramA_wsb_3  = 0;
            sramA_wsb_4  = 0;
            sramA_wsb_5  = 0;
            sramA_wsb_6  = 0;
            sramA_wsb_7  = 0;
            sramA_wsb_8  = 0;
            sramA_wsb_9  = 0;
            sramA_wsb_10 = 0;
            sramA_wsb_11 = 0;
            sramA_wsb_12 = 0;
            sramA_wsb_13 = 0;
            sramA_wsb_14 = 0;
            sramA_wsb_15 = 0;


            sramA_addr_0  = cnt_out; 
            sramA_addr_1  = cnt_out; 
            sramA_addr_2  = cnt_out; 
            sramA_addr_3  = cnt_out; 
            sramA_addr_4  = cnt_out; 
            sramA_addr_5  = cnt_out; 
            sramA_addr_6  = cnt_out; 
            sramA_addr_7  = cnt_out; 
            sramA_addr_8  = cnt_out; 
            sramA_addr_9  = cnt_out; 
            sramA_addr_10 = cnt_out; 
            sramA_addr_11 = cnt_out; 
            sramA_addr_12 = cnt_out; 
            sramA_addr_13 = cnt_out; 
            sramA_addr_14 = cnt_out; 
            sramA_addr_15 = cnt_out; 

            sramB_addr_0 =  cnt_in;
            sramB_addr_1 =  cnt_in;
            sramB_addr_2 =  cnt_in;
            sramB_addr_3 =  cnt_in;
            sramB_addr_4 =  cnt_in;
            sramB_addr_5 =  cnt_in;
            sramB_addr_6 =  cnt_in;
            sramB_addr_7 =  cnt_in;
            sramB_addr_8 =  cnt_in;
            sramB_addr_9 =  cnt_in;
            sramB_addr_10 = cnt_in;
            sramB_addr_11 = cnt_in;
            sramB_addr_12 = cnt_in;
            sramB_addr_13 = cnt_in;
            sramB_addr_14 = cnt_in;
            sramB_addr_15 = cnt_in;
            
            sramA_wdata_0  = sramB_rdata_0 ; 
            sramA_wdata_1  = sramB_rdata_1 ; 
            sramA_wdata_2  = sramB_rdata_2 ; 
            sramA_wdata_3  = sramB_rdata_3 ; 
            sramA_wdata_4  = sramB_rdata_4 ; 
            sramA_wdata_5  = sramB_rdata_5 ; 
            sramA_wdata_6  = sramB_rdata_6 ; 
            sramA_wdata_7  = sramB_rdata_7 ; 
            sramA_wdata_8  = sramB_rdata_8 ; 
            sramA_wdata_9  = sramB_rdata_9 ; 
            sramA_wdata_10 = sramB_rdata_10; 
            sramA_wdata_11 = sramB_rdata_11; 
            sramA_wdata_12 = sramB_rdata_12; 
            sramA_wdata_13 = sramB_rdata_13; 
            sramA_wdata_14 = sramB_rdata_14; 
            sramA_wdata_15 = sramB_rdata_15; 
            col_nxt = 1;
        end
    endcase
end


// stage5 
always@* begin
    case(cnt_in_prv)
        1: begin bpe0_bi_reg = sramB_rdata_0; bpe1_bi_reg = sramB_rdata_1;end
        2: begin bpe0_bi_reg = sramB_rdata_2; bpe1_bi_reg = sramB_rdata_3;end
        3: begin bpe0_bi_reg = sramB_rdata_4; bpe1_bi_reg = sramB_rdata_5;end
        4: begin bpe0_bi_reg = sramB_rdata_6; bpe1_bi_reg = sramB_rdata_7;end
        5: begin bpe0_bi_reg = sramB_rdata_8; bpe1_bi_reg = sramB_rdata_9;end
        6: begin bpe0_bi_reg = sramB_rdata_10; bpe1_bi_reg = sramB_rdata_11;end
        7: begin bpe0_bi_reg = sramB_rdata_12; bpe1_bi_reg = sramB_rdata_13;end
        8: begin bpe0_bi_reg = sramB_rdata_14; bpe1_bi_reg = sramB_rdata_15;end
        default:begin bpe0_bi_reg = 0; bpe1_bi_reg = 0;end
    endcase

    case(cnt_in)
        1: begin buf0_reg = sramB_rdata_0;  buf1_reg = sramB_rdata_1;end
        2: begin buf0_reg = sramB_rdata_2;  buf1_reg = sramB_rdata_3;end
        3: begin buf0_reg = sramB_rdata_4;  buf1_reg = sramB_rdata_5;end
        4: begin buf0_reg = sramB_rdata_6;  buf1_reg = sramB_rdata_7;end
        5: begin buf0_reg = sramB_rdata_8;  buf1_reg = sramB_rdata_9;end
        6: begin buf0_reg = sramB_rdata_10; buf1_reg = sramB_rdata_11;end
        7: begin buf0_reg = sramB_rdata_12; buf1_reg = sramB_rdata_13;end
        8: begin buf0_reg = sramB_rdata_14; buf1_reg = sramB_rdata_15;end
        default:begin buf0_reg = 0; buf1_reg = 0;end
    endcase

    case(cnt_in_prv)
        1: begin bpe0_gm_reg = twiddle_data_0_in;  bpe1_gm_reg = twiddle_data_1_in; end
        2: begin bpe0_gm_reg = twiddle_data_2_in;  bpe1_gm_reg = twiddle_data_3_in; end
        3: begin bpe0_gm_reg = twiddle_data_4_in;  bpe1_gm_reg = twiddle_data_5_in; end
        4: begin bpe0_gm_reg = twiddle_data_6_in;  bpe1_gm_reg = twiddle_data_7_in; end
        5: begin bpe0_gm_reg = twiddle_data_8_in;  bpe1_gm_reg = twiddle_data_9_in; end
        6: begin bpe0_gm_reg = twiddle_data_10_in;  bpe1_gm_reg = twiddle_data_11_in; end
        7: begin bpe0_gm_reg = twiddle_data_12_in;  bpe1_gm_reg = twiddle_data_13_in; end
        8: begin bpe0_gm_reg = twiddle_data_14_in;  bpe1_gm_reg = twiddle_data_15_in; end
        default:begin bpe0_gm_reg = 0; bpe1_gm_reg = 0;end
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buf1 <= 0;
        buf0 <= 0;
    end else begin
        buf1 <= buf1_reg;
        buf0 <= buf0_reg;
    end
end

// stage tsp
always @* begin
    case (cnt_out[4:0])
        5'd0:  sramB_data = sramA_rdata_0;
        5'd1:  sramB_data = sramA_rdata_2;
        5'd2:  sramB_data = sramA_rdata_4;
        5'd3:  sramB_data = sramA_rdata_6;
        5'd4:  sramB_data = sramA_rdata_8;
        5'd5:  sramB_data = sramA_rdata_10;
        5'd6:  sramB_data = sramA_rdata_12;
        5'd7:  sramB_data = sramA_rdata_14;
        5'd8:  sramB_data = sramA_rdata_0;
        5'd9:  sramB_data = sramA_rdata_2;
        5'd10: sramB_data = sramA_rdata_4;
        5'd11: sramB_data = sramA_rdata_6;
        5'd12: sramB_data = sramA_rdata_8;
        5'd13: sramB_data = sramA_rdata_10;
        5'd14: sramB_data = sramA_rdata_12;
        5'd15: sramB_data = sramA_rdata_14;
        5'd16: sramB_data = sramA_rdata_1;
        5'd17:  sramB_data = sramA_rdata_3;
        5'd18:  sramB_data = sramA_rdata_5;
        5'd19:  sramB_data = sramA_rdata_7;
        5'd20:  sramB_data = sramA_rdata_9;
        5'd21:  sramB_data = sramA_rdata_11;
        5'd22:  sramB_data = sramA_rdata_13;
        5'd23:  sramB_data = sramA_rdata_15;
        5'd24:  sramB_data = sramA_rdata_1;
        5'd25:  sramB_data = sramA_rdata_3;
        5'd26: sramB_data = sramA_rdata_5;
        5'd27: sramB_data = sramA_rdata_7;
        5'd28: sramB_data = sramA_rdata_9;
        5'd29: sramB_data = sramA_rdata_11;
        5'd30: sramB_data = sramA_rdata_13;
        5'd31: sramB_data = sramA_rdata_15;
        default: sramB_data = 0;
    endcase
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        stage <= 0;
        cnt_in <= 0;
        cnt_out <= 0;
        round_cnt <= 0;
        cnt_in_prv <= 0;
        col <= 0;
    end else if (done) begin
        stage <= 0;
        cnt_in <= 0;
        cnt_out <= 0;
        round_cnt <= 0;
        cnt_in_prv <= 0;
        col <= 0;
    end else begin
        stage <= nxt_stage;
        cnt_in <= nxt_cnt_in;
        cnt_out <= nxt_cnt_out;
        round_cnt <= nxt_round_cnt;
        cnt_in_prv <= cnt_in;
        col <= col_nxt;
    end
end

// ===================================================================
// BPE instances (Butterfly Processing Elements)
// ===================================================================
// BPE 0
bpe #(
    .pDATA_WIDTH(BW_PER_ADDR)
) u_bpe0 (
    .clk(clk),
    .rst_n(rst_n),
    .mode({1'b0, mode}),  // Convert 1-bit mode to 2-bit: 0->00(FFT), 1->01(iFFT)
    .i_vld(bpe0_i_vld), 
    .i_rdy(bpe0_i_rdy), 
    .o_vld(bpe0_o_vld), 
    .o_rdy(bpe0_o_rdy), 
    .ai(bpe0_ai),   
    .bi(bpe0_bi),   
    .gm(bpe0_gm),   
    .ao(bpe0_ao),       
    .bo(bpe0_bo),       
    // Mul interface
    .mul_in_A(bpe0_mul_in_A),
    .mul_in_B(bpe0_mul_in_B),
    .mul_mode(bpe0_mul_mode),
    .mul_in_valid(bpe0_mul_in_valid),
    .mul_result_c(bpe0_mul_result_c),
    .mul_result_int(bpe0_mul_result_int),
    .mul_out_valid(bpe0_mul_out_valid),
    // FP_ADD interfaces
    .fp_add_01_in_A(bpe0_fp_add_01_in_A),
    .fp_add_01_in_B(bpe0_fp_add_01_in_B),
    .fp_add_01_in_valid(bpe0_fp_add_01_in_valid),
    .fp_add_01_result(bpe0_fp_add_01_result),
    .fp_add_01_out_valid(bpe0_fp_add_01_out_valid),
    .fp_add_02_in_A(bpe0_fp_add_02_in_A),
    .fp_add_02_in_B(bpe0_fp_add_02_in_B),
    .fp_add_02_in_valid(bpe0_fp_add_02_in_valid),
    .fp_add_02_result(bpe0_fp_add_02_result),
    .fp_add_02_out_valid(bpe0_fp_add_02_out_valid),
    .fp_add_11_in_A(bpe0_fp_add_11_in_A),
    .fp_add_11_in_B(bpe0_fp_add_11_in_B),
    .fp_add_11_in_valid(bpe0_fp_add_11_in_valid),
    .fp_add_11_result(bpe0_fp_add_11_result),
    .fp_add_11_out_valid(bpe0_fp_add_11_out_valid),
    .fp_add_12_in_A(bpe0_fp_add_12_in_A),
    .fp_add_12_in_B(bpe0_fp_add_12_in_B),
    .fp_add_12_in_valid(bpe0_fp_add_12_in_valid),
    .fp_add_12_result(bpe0_fp_add_12_result),
    .fp_add_12_out_valid(bpe0_fp_add_12_out_valid)
);

// BPE 1
bpe #(
    .pDATA_WIDTH(BW_PER_ADDR)
) u_bpe1 (
    .clk(clk),
    .rst_n(rst_n),
    .mode({1'b0, mode}),  // Convert 1-bit mode to 2-bit: 0->00(FFT), 1->01(iFFT)
    .i_vld(bpe1_i_vld),  
    .i_rdy(bpe1_i_rdy),  
    .o_vld(bpe1_o_vld),  
    .o_rdy(bpe1_o_rdy),  
    .ai(bpe1_ai),    
    .bi(bpe1_bi),    
    .gm(bpe1_gm),    
    .ao(bpe1_ao),    
    .bo(bpe1_bo),    
    // Mul interface
    .mul_in_A(bpe1_mul_in_A),
    .mul_in_B(bpe1_mul_in_B),
    .mul_mode(bpe1_mul_mode),
    .mul_in_valid(bpe1_mul_in_valid),
    .mul_result_c(bpe1_mul_result_c),
    .mul_result_int(bpe1_mul_result_int),
    .mul_out_valid(bpe1_mul_out_valid),
    // FP_ADD interfaces
    .fp_add_01_in_A(bpe1_fp_add_01_in_A),
    .fp_add_01_in_B(bpe1_fp_add_01_in_B),
    .fp_add_01_in_valid(bpe1_fp_add_01_in_valid),
    .fp_add_01_result(bpe1_fp_add_01_result),
    .fp_add_01_out_valid(bpe1_fp_add_01_out_valid),
    .fp_add_02_in_A(bpe1_fp_add_02_in_A),
    .fp_add_02_in_B(bpe1_fp_add_02_in_B),
    .fp_add_02_in_valid(bpe1_fp_add_02_in_valid),
    .fp_add_02_result(bpe1_fp_add_02_result),
    .fp_add_02_out_valid(bpe1_fp_add_02_out_valid),
    .fp_add_11_in_A(bpe1_fp_add_11_in_A),
    .fp_add_11_in_B(bpe1_fp_add_11_in_B),
    .fp_add_11_in_valid(bpe1_fp_add_11_in_valid),
    .fp_add_11_result(bpe1_fp_add_11_result),
    .fp_add_11_out_valid(bpe1_fp_add_11_out_valid),
    .fp_add_12_in_A(bpe1_fp_add_12_in_A),
    .fp_add_12_in_B(bpe1_fp_add_12_in_B),
    .fp_add_12_in_valid(bpe1_fp_add_12_in_valid),
    .fp_add_12_result(bpe1_fp_add_12_result),
    .fp_add_12_out_valid(bpe1_fp_add_12_out_valid)
);

endmodule