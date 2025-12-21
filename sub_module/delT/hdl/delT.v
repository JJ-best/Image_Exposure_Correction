module delT#(
    parameter BW_PER_ADDR_T = 128,
    parameter BW_PER_ADDR_X = 64,
    parameter ADDR_WIDTH_T = 6,
    parameter ADDR_WIDTH_X = 9
)(
    input clk,
    input rst_n,
    input enable,
    output done,

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

    // SRAM X(64x32x1x64) - 4 banks
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

    // FP_ADD interfaces (4 adder)
    output  reg [63:0]  fp_add_01_in_A, fp_add_01_in_B,
    output  reg         fp_add_01_in_valid,
    input   wire [63:0]  fp_add_01_result,
    input   wire         fp_add_01_out_valid,

    output  reg [63:0]  fp_add_02_in_A, fp_add_02_in_B,
    output  reg         fp_add_02_in_valid,
    input   wire [63:0]  fp_add_02_result,
    input   wire         fp_add_02_out_valid,

    output  reg [63:0]  fp_add_11_in_A, fp_add_11_in_B,
    output  reg         fp_add_11_in_valid,
    input   wire [63:0]  fp_add_11_result,
    input   wire         fp_add_11_out_valid,

    output  reg [63:0]  fp_add_12_in_A, fp_add_12_in_B,
    output  reg         fp_add_12_in_valid,
    input   wire [63:0]  fp_add_12_result,
    input   wire         fp_add_12_out_valid
);

// === parameters === //
localparam IDLE = 2'b00;
localparam TN = 2'b01;
localparam TV = 2'b10;
localparam TV_LAST = 2'b11;

reg [63:0] cyclic_data_0, nxt_cyclic_data_0; // record the edge data 
reg [63:0] cyclic_data_1, nxt_cyclic_data_1; // record the edge data 
reg [63:0] cyclic_data_2, nxt_cyclic_data_2; // record the edge data 
reg [63:0] cyclic_data_3, nxt_cyclic_data_3; // record the edge data 
reg [63:0] buf0, buf1, buf2, buf3;


reg [3:0] cnt_in, cnt_out, nxt_cnt_in, nxt_cnt_out;
reg [5:0] row_cnt_in, nxt_row_cnt_in, row_cnt_out, nxt_row_cnt_out;
reg [1:0] state, nxt_state;

// Input to fp_add
reg [63:0] inA_01_TN, inB_01_TN, inA_01_TV, inB_01_TV, inA_01_TV_LAST, inB_01_TV_LAST;
reg [63:0] inA_02_TN, inB_02_TN, inA_02_TV, inB_02_TV, inA_02_TV_LAST, inB_02_TV_LAST;
reg [63:0] inA_11_TN, inB_11_TN, inA_11_TV, inB_11_TV, inA_11_TV_LAST, inB_11_TV_LAST;
reg [63:0] inA_12_TN, inB_12_TN, inA_12_TV, inB_12_TV, inA_12_TV_LAST, inB_12_TV_LAST;

assign done = cnt_out == 7 && state == TV_LAST;
always@* begin
    inA_01_TN = 0;
    inB_01_TN = 0;
    inA_02_TN = 0;
    inB_02_TN = 0;
    inA_11_TN = 0;
    inB_11_TN = 0;
    inA_12_TN = 0;
    inB_12_TN = 0;
    case(cnt_in)
        1, 3: begin
            inA_01_TN = sram_rdata_t1[127:64];
            inB_01_TN = {~sram_rdata_t0[127], sram_rdata_t0[126:64]};
            inA_02_TN = sram_rdata_t3[127:64];
            inB_02_TN = {~sram_rdata_t2[127], sram_rdata_t2[126:64]};
            inA_11_TN = sram_rdata_t5[127:64];
            inB_11_TN = {~sram_rdata_t4[127], sram_rdata_t4[126:64]};
            inA_12_TN = sram_rdata_t7[127:64];
            inB_12_TN = {~sram_rdata_t6[127], sram_rdata_t6[126:64]};
        end
        2, 4: begin
            inA_01_TN = sram_rdata_t9[127:64];
            inB_01_TN = {~sram_rdata_t8[127], sram_rdata_t8[126:64]};
            inA_02_TN = sram_rdata_t11[127:64];
            inB_02_TN = {~sram_rdata_t10[127], sram_rdata_t10[126:64]};
            inA_11_TN = sram_rdata_t13[127:64];
            inB_11_TN = {~sram_rdata_t12[127], sram_rdata_t12[126:64]};
            inA_12_TN = sram_rdata_t15[127:64];
            inB_12_TN = {~sram_rdata_t14[127], sram_rdata_t14[126:64]};
        end
        5, 7: begin
            inA_01_TN = sram_rdata_t2[127:64];
            inB_01_TN = {~sram_rdata_t1[127], sram_rdata_t1[126:64]};
            inA_02_TN = sram_rdata_t4[127:64];
            inB_02_TN = {~sram_rdata_t3[127], sram_rdata_t3[126:64]};
            inA_11_TN = sram_rdata_t6[127:64];
            inB_11_TN = {~sram_rdata_t5[127], sram_rdata_t5[126:64]};
            inA_12_TN = sram_rdata_t8[127:64];
            inB_12_TN = {~sram_rdata_t7[127], sram_rdata_t7[126:64]};
        end
        6: begin
            inA_01_TN = sram_rdata_t10[127:64];
            inB_01_TN = {~sram_rdata_t9[127], sram_rdata_t9[126:64]};
            inA_02_TN = sram_rdata_t12[127:64];
            inB_02_TN = {~sram_rdata_t11[127], sram_rdata_t11[126:64]};
            inA_11_TN = sram_rdata_t14[127:64];
            inB_11_TN = {~sram_rdata_t13[127], sram_rdata_t13[126:64]};
            inA_12_TN = cyclic_data_1;
            inB_12_TN = {~sram_rdata_t15[127], sram_rdata_t15[126:64]};
        end
        8: begin
            inA_01_TN = sram_rdata_t10[127:64];
            inB_01_TN = {~sram_rdata_t9[127], sram_rdata_t9[126:64]};
            inA_02_TN = sram_rdata_t12[127:64];
            inB_02_TN = {~sram_rdata_t11[127], sram_rdata_t11[126:64]};
            inA_11_TN = sram_rdata_t14[127:64];
            inB_11_TN = {~sram_rdata_t13[127], sram_rdata_t13[126:64]};
            inA_12_TN = cyclic_data_0;
            inB_12_TN = {~sram_rdata_t15[127], sram_rdata_t15[126:64]};
        end
    endcase
end

always@* begin
    inA_01_TV_LAST = 0;
    inB_01_TV_LAST = 0;
    inA_02_TV_LAST = 0;
    inB_02_TV_LAST = 0;
    inA_11_TV_LAST = 0;
    inB_11_TV_LAST = 0;
    inA_12_TV_LAST = 0;
    inB_12_TV_LAST = 0;
    case(cnt_in)
        1, 3: begin
            inA_01_TV_LAST = sram_rdata_t1[127:64];
            inB_01_TV_LAST = {~sram_rdata_t0[127], sram_rdata_t0[126:64]};
            inA_02_TV_LAST = sram_rdata_t3[127:64];
            inB_02_TV_LAST = {~sram_rdata_t2[127], sram_rdata_t2[126:64]};
            inA_11_TV_LAST = sram_rdata_t5[127:64];
            inB_11_TV_LAST = {~sram_rdata_t4[127], sram_rdata_t4[126:64]};
            inA_12_TV_LAST = sram_rdata_t7[127:64];
            inB_12_TV_LAST = {~sram_rdata_t6[127], sram_rdata_t6[126:64]};
        end
        2, 4: begin
            inA_01_TV_LAST = sram_rdata_t9[127:64];
            inB_01_TV_LAST = {~sram_rdata_t8[127], sram_rdata_t8[126:64]};
            inA_02_TV_LAST = sram_rdata_t11[127:64];
            inB_02_TV_LAST = {~sram_rdata_t10[127], sram_rdata_t10[126:64]};
            inA_11_TV_LAST = sram_rdata_t13[127:64];
            inB_11_TV_LAST = {~sram_rdata_t12[127], sram_rdata_t12[126:64]};
            inA_12_TV_LAST = sram_rdata_t15[127:64];
            inB_12_TV_LAST = {~sram_rdata_t14[127], sram_rdata_t14[126:64]};
        end
        5, 7: begin
            inA_01_TV_LAST = sram_rdata_t2[127:64];
            inB_01_TV_LAST = {~sram_rdata_t1[127], sram_rdata_t1[126:64]};
            inA_02_TV_LAST = sram_rdata_t4[127:64];
            inB_02_TV_LAST = {~sram_rdata_t3[127], sram_rdata_t3[126:64]};
            inA_11_TV_LAST = sram_rdata_t6[127:64];
            inB_11_TV_LAST = {~sram_rdata_t5[127], sram_rdata_t5[126:64]};
            inA_12_TV_LAST = sram_rdata_t8[127:64];
            inB_12_TV_LAST = {~sram_rdata_t7[127], sram_rdata_t7[126:64]};
        end
        6: begin
            inA_01_TV_LAST = sram_rdata_t10[127:64];
            inB_01_TV_LAST = {~sram_rdata_t9[127], sram_rdata_t9[126:64]};
            inA_02_TV_LAST = sram_rdata_t12[127:64];
            inB_02_TV_LAST = {~sram_rdata_t11[127], sram_rdata_t11[126:64]};
            inA_11_TV_LAST = sram_rdata_t14[127:64];
            inB_11_TV_LAST = {~sram_rdata_t13[127], sram_rdata_t13[126:64]};
            inA_12_TV_LAST = sram_rdata_t0[127:64];
            inB_12_TV_LAST = {~sram_rdata_t15[127], sram_rdata_t15[126:64]};
        end
        8: begin
            inA_01_TV_LAST = sram_rdata_t10[127:64];
            inB_01_TV_LAST = {~sram_rdata_t9[127], sram_rdata_t9[126:64]};
            inA_02_TV_LAST = sram_rdata_t12[127:64];
            inB_02_TV_LAST = {~sram_rdata_t11[127], sram_rdata_t11[126:64]};
            inA_11_TV_LAST = sram_rdata_t14[127:64];
            inB_11_TV_LAST = {~sram_rdata_t13[127], sram_rdata_t13[126:64]};
            inA_12_TV_LAST = sram_rdata_t0[127:64];
            inB_12_TV_LAST = {~sram_rdata_t15[127], sram_rdata_t15[126:64]};
        end
    endcase
end

always@* begin
    inA_01_TV = 0;
    inB_01_TV = 0;
    inA_02_TV = 0;
    inB_02_TV = 0;
    inA_11_TV = 0;
    inB_11_TV = 0;
    inA_12_TV = 0;
    inB_12_TV = 0;
    case(cnt_in)
        2, 4: begin
            inA_01_TV = cyclic_data_0;
            inB_01_TV = {~sram_rdata_t0[127], sram_rdata_t0[126:64]};
            inA_02_TV = cyclic_data_1;
            inB_02_TV = {~sram_rdata_t2[127], sram_rdata_t2[126:64]};
            inA_11_TV = cyclic_data_2;
            inB_11_TV = {~sram_rdata_t4[127], sram_rdata_t4[126:64]};
            inA_12_TV = cyclic_data_3;
            inB_12_TV = {~sram_rdata_t6[127], sram_rdata_t6[126:64]};
        end
        3, 5: begin
            inA_01_TV = cyclic_data_0;
            inB_01_TV = {~sram_rdata_t8[127], sram_rdata_t8[126:64]};
            inA_02_TV = cyclic_data_1;
            inB_02_TV = {~sram_rdata_t10[127], sram_rdata_t10[126:64]};
            inA_11_TV = cyclic_data_2;
            inB_11_TV = {~sram_rdata_t12[127], sram_rdata_t12[126:64]};
            inA_12_TV = cyclic_data_3;
            inB_12_TV = {~sram_rdata_t14[127], sram_rdata_t14[126:64]};
        end
        6, 8: begin
            inA_01_TV = cyclic_data_0;
            inB_01_TV = {~sram_rdata_t1[127], sram_rdata_t1[126:64]};
            inA_02_TV = cyclic_data_1;
            inB_02_TV = {~sram_rdata_t3[127], sram_rdata_t3[126:64]};
            inA_11_TV = cyclic_data_2;
            inB_11_TV = {~sram_rdata_t5[127], sram_rdata_t5[126:64]};
            inA_12_TV = cyclic_data_3;
            inB_12_TV = {~sram_rdata_t7[127], sram_rdata_t7[126:64]};
        end
        7, 9: begin
            inA_01_TV = cyclic_data_0;
            inB_01_TV = {~sram_rdata_t9[127], sram_rdata_t9[126:64]};
            inA_02_TV = cyclic_data_1;
            inB_02_TV = {~sram_rdata_t11[127], sram_rdata_t11[126:64]};
            inA_11_TV = cyclic_data_2;
            inB_11_TV = {~sram_rdata_t13[127], sram_rdata_t13[126:64]};
            inA_12_TV = cyclic_data_3;
            inB_12_TV = {~sram_rdata_t15[127], sram_rdata_t15[126:64]};
        end
    endcase
end

always@* begin
    buf0 = 0;
    buf1 = 0;
    buf2 = 0;
    buf3 = 0;
    case(cnt_in)
        1,3: begin
            buf0 = sram_rdata_t0[127:64];
            buf1 = sram_rdata_t2[127:64];
            buf2 = sram_rdata_t4[127:64];
            buf3 = sram_rdata_t6[127:64];
        end
        2,4: begin
            buf0 = sram_rdata_t8[127:64];
            buf1 = sram_rdata_t10[127:64];
            buf2 = sram_rdata_t12[127:64];
            buf3 = sram_rdata_t14[127:64];
        end
        5,7: begin
            buf0 = sram_rdata_t1[127:64];
            buf1 = sram_rdata_t3[127:64];
            buf2 = sram_rdata_t5[127:64];
            buf3 = sram_rdata_t7[127:64];
        end
        6,8: begin
            buf0 = sram_rdata_t9[127:64];
            buf1 = sram_rdata_t11[127:64];
            buf2 = sram_rdata_t13[127:64];
            buf3 = sram_rdata_t15[127:64];
        end
    endcase
end
// === sram acess === //
always@* begin
    // Use registered read data (1 cycle delayed to match SRAM latency)
    fp_add_01_in_A = 0;
    fp_add_01_in_B = 0;
    fp_add_01_in_valid = 0;
    
    fp_add_02_in_A = 0;
    fp_add_02_in_B = 0;
    fp_add_02_in_valid = 0;
    
    fp_add_11_in_A = 0;
    fp_add_11_in_B = 0;
    fp_add_11_in_valid = 0;
    
    fp_add_12_in_A = 0;
    fp_add_12_in_B = 0;
    fp_add_12_in_valid = 0;

    nxt_state = state;
    nxt_row_cnt_in = 0;
    nxt_row_cnt_out = 0;
    nxt_cnt_in = 0;
    nxt_cnt_out = 0;

    nxt_cyclic_data_0 = 0;
    nxt_cyclic_data_1 = 0;
    nxt_cyclic_data_2 = 0;
    nxt_cyclic_data_3 = 0;
    
    sram_wen_t0  = 1;    
    sram_wen_t1  = 1;
    sram_wen_t2  = 1;
    sram_wen_t3  = 1;    
    sram_wen_t4  = 1;
    sram_wen_t5  = 1;
    sram_wen_t6  = 1;    
    sram_wen_t7  = 1;
    sram_wen_t8  = 1;
    sram_wen_t9  = 1;    
    sram_wen_t10 = 1;
    sram_wen_t11 = 1;
    sram_wen_t12 = 1;    
    sram_wen_t13 = 1;
    sram_wen_t14 = 1;
    sram_wen_t15 = 1;    

    sram_addr_t0  = 0;
    sram_addr_t1  = 0;
    sram_addr_t2  = 0;
    sram_addr_t3  = 0;
    sram_addr_t4  = 0;
    sram_addr_t5  = 0;
    sram_addr_t6  = 0;
    sram_addr_t7  = 0;
    sram_addr_t8  = 0;
    sram_addr_t9  = 0;
    sram_addr_t10 = 0;
    sram_addr_t11 = 0;
    sram_addr_t12 = 0;
    sram_addr_t13 = 0;
    sram_addr_t14 = 0;
    sram_addr_t15 = 0;

    sram_wen_x0 =  1;
    sram_wen_x1 =  1;
    sram_wen_x2 =  1;
    sram_wen_x3 =  1;

    sram_addr_x0 = 0;
    sram_addr_x1 = 0;
    sram_addr_x2 = 0;
    sram_addr_x3 = 0;

    sram_wdata_x0 = 0;
    sram_wdata_x1 = 0;
    sram_wdata_x2 = 0;
    sram_wdata_x3 = 0;
    case(state)
        IDLE: begin
            nxt_state = (enable) ? TN : IDLE;
            nxt_row_cnt_in = 0;
            nxt_cnt_in = 0;
            nxt_cnt_out = 0;
            nxt_row_cnt_out = 0;
        end
        TN : begin // left - right
            nxt_state = (row_cnt_out == 31 && cnt_out == 7) ? TV : TN;
            nxt_row_cnt_in = (row_cnt_out == 31 && cnt_out == 7) ? 0: (row_cnt_in == 31 && cnt_in == 8) ? row_cnt_in : (cnt_in == 8) ? row_cnt_in + 1 : row_cnt_in;
            nxt_row_cnt_out = (row_cnt_out == 31 && cnt_out == 7) ? 0 : (cnt_out == 7) ? row_cnt_out + 1: row_cnt_out;
            nxt_cnt_in = (row_cnt_out == 31 && cnt_out == 7) ? 0:  (row_cnt_in == 31 && cnt_in == 8) ? 9 : (cnt_in == 8) ? 0 : cnt_in + 1;
            nxt_cnt_out = (cnt_out == 7) ? 0 : (fp_add_01_out_valid) ? cnt_out + 1 : cnt_out;

            // edge data prestore
            nxt_cyclic_data_0 = (cnt_in == 1) ? sram_rdata_t0[127:64] : cyclic_data_0;
            nxt_cyclic_data_1 = (cnt_in == 3) ? sram_rdata_t0[127:64] : cyclic_data_1;
            // Disable write enable (0 = read-only mode, 1 = write enable)
            sram_wen_t0  = 1;    
            sram_wen_t1  = 1;
            sram_wen_t2  = 1;
            sram_wen_t3  = 1;    
            sram_wen_t4  = 1;
            sram_wen_t5  = 1;
            sram_wen_t6  = 1;    
            sram_wen_t7  = 1;
            sram_wen_t8  = 1;
            sram_wen_t9  = 1;    
            sram_wen_t10 = 1;
            sram_wen_t11 = 1;
            sram_wen_t12 = 1;    
            sram_wen_t13 = 1;
            sram_wen_t14 = 1;
            sram_wen_t15 = 1;    
           
            sram_addr_t0  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t1  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t2  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t3  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t4  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t5  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t6  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t7  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t8  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t9  = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t10 = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t11 = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t12 = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t13 = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t14 = (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t15 = (row_cnt_in << 1) + (cnt_in[1]);

            sram_wen_x0 = ~fp_add_01_out_valid;
            sram_wen_x1 = ~fp_add_02_out_valid;
            sram_wen_x2 = ~fp_add_11_out_valid;
            sram_wen_x3 = ~fp_add_12_out_valid;

            sram_addr_x0 = (cnt_out>= 4 && cnt_out <= 7) ? (row_cnt_out << 3) + 256 + cnt_out[1:0] : (row_cnt_out << 3) +  cnt_out[1:0];
            sram_addr_x1 = (cnt_out>= 4 && cnt_out <= 7) ? (row_cnt_out << 3) + 256 + cnt_out[1:0] : (row_cnt_out << 3) +  cnt_out[1:0];
            sram_addr_x2 = (cnt_out>= 4 && cnt_out <= 7) ? (row_cnt_out << 3) + 256 + cnt_out[1:0] : (row_cnt_out << 3) +  cnt_out[1:0];
            sram_addr_x3 = (cnt_out>= 4 && cnt_out <= 7) ? (row_cnt_out << 3) + 256 + cnt_out[1:0] : (row_cnt_out << 3) +  cnt_out[1:0];

            sram_wdata_x0 = fp_add_01_result;
            sram_wdata_x1 = fp_add_02_result;
            sram_wdata_x2 = fp_add_11_result;
            sram_wdata_x3 = fp_add_12_result;

            // Use registered read data (1 cycle delayed to match SRAM latency)
            fp_add_01_in_A = inA_01_TN;
            fp_add_01_in_B = inB_01_TN;
            fp_add_01_in_valid = (cnt_in >= 1 && cnt_in <= 8);
            
            fp_add_02_in_A = inA_02_TN;
            fp_add_02_in_B = inB_02_TN;
            fp_add_02_in_valid = (cnt_in >= 1 && cnt_in <= 8);
            
            fp_add_11_in_A = inA_11_TN;
            fp_add_11_in_B = inB_11_TN;
            fp_add_11_in_valid = (cnt_in >= 1 && cnt_in <= 8);
            
            fp_add_12_in_A = inA_12_TN;
            fp_add_12_in_B = inB_12_TN;
            fp_add_12_in_valid = (cnt_in >= 1 && cnt_in <= 8);
        end
        TV : begin // bottom - up
            nxt_state = (row_cnt_out == 30 && cnt_out == 7) ? TV_LAST :TV;
            nxt_row_cnt_in = (row_cnt_out == 30 && cnt_out == 7) ? 0: (row_cnt_in == 30 && cnt_in == 9) ? row_cnt_in: (cnt_in == 9) ? row_cnt_in + 1 : row_cnt_in;
            nxt_row_cnt_out = (row_cnt_out == 30 && cnt_out == 7) ? 0: (cnt_out == 7) ? row_cnt_out + 1: row_cnt_out;
            nxt_cnt_in = (row_cnt_out == 30 && cnt_out == 7) ? 0: (row_cnt_in == 30 && cnt_in == 9) ? 10 : (cnt_in == 9) ? 0 : cnt_in + 1;
            nxt_cnt_out = (cnt_out == 7) ? 0 : (fp_add_01_out_valid) ? cnt_out + 1 : cnt_out;

            // edge data prestore
            nxt_cyclic_data_0 = buf0;
            nxt_cyclic_data_1 = buf1;
            nxt_cyclic_data_2 = buf2;
            nxt_cyclic_data_3 = buf3;

            // Disable write enable (0 = read-only mode, 1 = write enable)
            sram_wen_t0  = 1;    
            sram_wen_t1  = 1;
            sram_wen_t2  = 1;
            sram_wen_t3  = 1;    
            sram_wen_t4  = 1;
            sram_wen_t5  = 1;
            sram_wen_t6  = 1;    
            sram_wen_t7  = 1;
            sram_wen_t8  = 1;
            sram_wen_t9  = 1;    
            sram_wen_t10 = 1;
            sram_wen_t11 = 1;
            sram_wen_t12 = 1;    
            sram_wen_t13 = 1;
            sram_wen_t14 = 1;
            sram_wen_t15 = 1;    
           
            sram_addr_t0  = (cnt_in == 0 || cnt_in == 2) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t1  = (cnt_in == 4 || cnt_in == 6) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t2  = (cnt_in == 0 || cnt_in == 2) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t3  = (cnt_in == 4 || cnt_in == 6) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t4  = (cnt_in == 0 || cnt_in == 2) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t5  = (cnt_in == 4 || cnt_in == 6) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t6  = (cnt_in == 0 || cnt_in == 2) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t7  = (cnt_in == 4 || cnt_in == 6) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[1]);
            sram_addr_t8  = (cnt_in == 1 || cnt_in == 3) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[2]);
            sram_addr_t9  = (cnt_in == 5 || cnt_in == 7) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[3]);
            sram_addr_t10 = (cnt_in == 1 || cnt_in == 3) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[2]);
            sram_addr_t11 = (cnt_in == 5 || cnt_in == 7) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[3]);
            sram_addr_t12 = (cnt_in == 1 || cnt_in == 3) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[2]);
            sram_addr_t13 = (cnt_in == 5 || cnt_in == 7) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[3]);
            sram_addr_t14 = (cnt_in == 1 || cnt_in == 3) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[2]);
            sram_addr_t15 = (cnt_in == 5 || cnt_in == 7) ? (row_cnt_in << 1) + (cnt_in[1]) + 2 : (row_cnt_in << 1) + (cnt_in[3]);

            sram_wen_x0 = ~fp_add_01_out_valid;
            sram_wen_x1 = ~fp_add_02_out_valid;
            sram_wen_x2 = ~fp_add_11_out_valid;
            sram_wen_x3 = ~fp_add_12_out_valid;

            sram_addr_x0 = (cnt_out>= 4 && cnt_out <= 7) ? (row_cnt_out << 3) + 260 + cnt_out[1:0] : (row_cnt_out << 3) + 4 + cnt_out[1:0];
            sram_addr_x1 = (cnt_out>= 4 && cnt_out <= 7) ? (row_cnt_out << 3) + 260 + cnt_out[1:0] : (row_cnt_out << 3) + 4 + cnt_out[1:0];
            sram_addr_x2 = (cnt_out>= 4 && cnt_out <= 7) ? (row_cnt_out << 3) + 260 + cnt_out[1:0] : (row_cnt_out << 3) + 4 + cnt_out[1:0];
            sram_addr_x3 = (cnt_out>= 4 && cnt_out <= 7) ? (row_cnt_out << 3) + 260 + cnt_out[1:0] : (row_cnt_out << 3) + 4 + cnt_out[1:0];

            sram_wdata_x0 = fp_add_01_result;
            sram_wdata_x1 = fp_add_02_result;
            sram_wdata_x2 = fp_add_11_result;
            sram_wdata_x3 = fp_add_12_result;

            // Use registered read data (1 cycle delayed to match SRAM latency)
            fp_add_01_in_A = inA_01_TV;
            fp_add_01_in_B = inB_01_TV;
            fp_add_01_in_valid = (cnt_in >= 2 && cnt_in <= 9);
            
            fp_add_02_in_A = inA_02_TV;
            fp_add_02_in_B = inB_02_TV;
            fp_add_02_in_valid = (cnt_in >= 2 && cnt_in <= 9);
            
            fp_add_11_in_A = inA_11_TV;
            fp_add_11_in_B = inB_11_TV;
            fp_add_11_in_valid = (cnt_in >= 2 && cnt_in <= 9);
            
            fp_add_12_in_A = inA_12_TV;
            fp_add_12_in_B = inB_12_TV;
            fp_add_12_in_valid = (cnt_in >= 2 && cnt_in <= 9);
        end
        TV_LAST: begin
            nxt_state = (cnt_out == 7) ? IDLE : TV_LAST;
            nxt_row_cnt_in = 0;
            nxt_row_cnt_out = 0;
            nxt_cnt_in = (cnt_out == 7) ? 0: (cnt_in == 8) ? 9 : cnt_in + 1;
            nxt_cnt_out = (cnt_out == 7) ? 0 : (fp_add_01_out_valid) ? cnt_out + 1 : cnt_out;

            // edge data prestore
            // nxt_cyclic_data_0 = (cnt_in == 1) ? sram_rdata_t0[127:64] : cyclic_data_0;
            // nxt_cyclic_data_1 = (cnt_in == 3) ? sram_rdata_t0[127:64] : cyclic_data_1;

            // Disable write enable (0 = read-only mode, 1 = write enable)
            sram_wen_t0  = 1;    
            sram_wen_t1  = 1;
            sram_wen_t2  = 1;
            sram_wen_t3  = 1;    
            sram_wen_t4  = 1;
            sram_wen_t5  = 1;
            sram_wen_t6  = 1;    
            sram_wen_t7  = 1;
            sram_wen_t8  = 1;
            sram_wen_t9  = 1;    
            sram_wen_t10 = 1;
            sram_wen_t11 = 1;
            sram_wen_t12 = 1;    
            sram_wen_t13 = 1;
            sram_wen_t14 = 1;
            sram_wen_t15 = 1;    
           
            sram_addr_t0  = (cnt_in[2:1] == 2'b00) ? 6'd62 : (cnt_in[2:1] == 2'b01) ? 6'd63 : (cnt_in[2:1] == 2'b10) ? 6'd1  : 6'd0;
            sram_addr_t1  = (cnt_in[2:1] == 2'b00) ? 6'd0  : (cnt_in[2:1] == 2'b01) ? 6'd1  : (cnt_in[2:1] == 2'b10) ? 6'd62 : 6'd63;
            sram_addr_t2  = (cnt_in[2:1] == 2'b00) ? 6'd62 : (cnt_in[2:1] == 2'b01) ? 6'd63 : (cnt_in[2:1] == 2'b10) ? 6'd0  : 6'd1;
            sram_addr_t3  = (cnt_in[2:1] == 2'b00) ? 6'd0  : (cnt_in[2:1] == 2'b01) ? 6'd1  : (cnt_in[2:1] == 2'b10) ? 6'd62 : 6'd63;
            sram_addr_t4  = (cnt_in[2:1] == 2'b00) ? 6'd62 : (cnt_in[2:1] == 2'b01) ? 6'd63 : (cnt_in[2:1] == 2'b10) ? 6'd0  : 6'd1;
            sram_addr_t5  = (cnt_in[2:1] == 2'b00) ? 6'd0  : (cnt_in[2:1] == 2'b01) ? 6'd1  : (cnt_in[2:1] == 2'b10) ? 6'd62 : 6'd63;
            sram_addr_t6  = (cnt_in[2:1] == 2'b00) ? 6'd62 : (cnt_in[2:1] == 2'b01) ? 6'd63 : (cnt_in[2:1] == 2'b10) ? 6'd0  : 6'd1;
            sram_addr_t7  = (cnt_in[2:1] == 2'b00) ? 6'd0  : (cnt_in[2:1] == 2'b01) ? 6'd1  : (cnt_in[2:1] == 2'b10) ? 6'd62 : 6'd63;
            sram_addr_t8  = (cnt_in[2:1] == 2'b00) ? 6'd62 : (cnt_in[2:1] == 2'b01) ? 6'd63 : (cnt_in[2:1] == 2'b10) ? 6'd0  : 6'd1;
            sram_addr_t9  = (cnt_in[2:1] == 2'b00) ? 6'd0  : (cnt_in[2:1] == 2'b01) ? 6'd1  : (cnt_in[2:1] == 2'b10) ? 6'd62 : 6'd63;
            sram_addr_t10 = (cnt_in[2:1] == 2'b00) ? 6'd62 : (cnt_in[2:1] == 2'b01) ? 6'd63 : (cnt_in[2:1] == 2'b10) ? 6'd0  : 6'd1;
            sram_addr_t11 = (cnt_in[2:1] == 2'b00) ? 6'd0  : (cnt_in[2:1] == 2'b01) ? 6'd1  : (cnt_in[2:1] == 2'b10) ? 6'd62 : 6'd63;
            sram_addr_t12 = (cnt_in[2:1] == 2'b00) ? 6'd62 : (cnt_in[2:1] == 2'b01) ? 6'd63 : (cnt_in[2:1] == 2'b10) ? 6'd0  : 6'd1;
            sram_addr_t13 = (cnt_in[2:1] == 2'b00) ? 6'd0  : (cnt_in[2:1] == 2'b01) ? 6'd1  : (cnt_in[2:1] == 2'b10) ? 6'd62 : 6'd63;
            sram_addr_t14 = (cnt_in[2:1] == 2'b00) ? 6'd62 : (cnt_in[2:1] == 2'b01) ? 6'd63 : (cnt_in[2:1] == 2'b10) ? 6'd0  : 6'd1;
            sram_addr_t15 = (cnt_in[2:1] == 2'b00) ? 6'd0  : (cnt_in[2:1] == 2'b01) ? 6'd1  : (cnt_in[2:1] == 2'b10) ? 6'd62 : 6'd63;

            sram_wen_x0 = ~fp_add_01_out_valid;
            sram_wen_x1 = ~fp_add_02_out_valid;
            sram_wen_x2 = ~fp_add_11_out_valid;
            sram_wen_x3 = ~fp_add_12_out_valid;

            sram_addr_x0 = (cnt_out>= 4 && cnt_out <= 7) ? 248 + 260 + cnt_out[1:0] : 248 + 4 + cnt_out[1:0];
            sram_addr_x1 = (cnt_out>= 4 && cnt_out <= 7) ? 248 + 260 + cnt_out[1:0] : 248 + 4 + cnt_out[1:0];
            sram_addr_x2 = (cnt_out>= 4 && cnt_out <= 7) ? 248 + 260 + cnt_out[1:0] : 248 + 4 + cnt_out[1:0];
            sram_addr_x3 = (cnt_out>= 4 && cnt_out <= 7) ? 248 + 260 + cnt_out[1:0] : 248 + 4 + cnt_out[1:0];

            sram_wdata_x0 = fp_add_01_result;
            sram_wdata_x1 = fp_add_02_result;
            sram_wdata_x2 = fp_add_11_result;
            sram_wdata_x3 = fp_add_12_result;

            fp_add_01_in_A = inA_01_TV_LAST;
            fp_add_01_in_B = inB_01_TV_LAST;
            fp_add_01_in_valid = (cnt_in >= 1 && cnt_in <= 8);
            
            fp_add_02_in_A = inA_02_TV_LAST;
            fp_add_02_in_B = inB_02_TV_LAST;
            fp_add_02_in_valid = (cnt_in >= 1 && cnt_in <= 8);
            
            fp_add_11_in_A = inA_11_TV_LAST;
            fp_add_11_in_B = inB_11_TV_LAST;
            fp_add_11_in_valid = (cnt_in >= 1 && cnt_in <= 8);
            
            fp_add_12_in_A = inA_12_TV_LAST;
            fp_add_12_in_B = inB_12_TV_LAST;
            fp_add_12_in_valid = (cnt_in >= 1 && cnt_in <= 8);
        end
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        cnt_in <= 0;
        row_cnt_in <= 0;
        cnt_out <= 0;
        cyclic_data_0 <= 0;
        cyclic_data_1 <= 0;
        cyclic_data_2 <= 0;
        cyclic_data_3 <= 0;
        row_cnt_out <= 0;
    end else begin
        state <= nxt_state;
        cnt_in <= nxt_cnt_in;
        row_cnt_in <= nxt_row_cnt_in;
        cnt_out <= nxt_cnt_out;
        cyclic_data_0 <= nxt_cyclic_data_0;
        cyclic_data_1 <= nxt_cyclic_data_1;
        cyclic_data_2 <= nxt_cyclic_data_2;
        cyclic_data_3 <= nxt_cyclic_data_3;
        row_cnt_out <= nxt_row_cnt_out;
    end
end
endmodule