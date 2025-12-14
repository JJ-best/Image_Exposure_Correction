module IEC_top #(
    parameter BW_PER_ADDR_A = 24,
    parameter BW_PER_ADDR_B = 64,
    parameter BW_PER_ADDR_I = 64,
    parameter BW_PER_ADDR_Z = 64,
    parameter BW_PER_ADDR_U = 64,
    parameter BW_PER_ADDR_G = 64,
    parameter BW_PER_ADDR_X = 64,
    parameter ADDR_WIDTH_A  = 8,
    parameter ADDR_WIDTH_B  = 8,
    parameter ADDR_WIDTH_I  = 8,
    parameter ADDR_WIDTH_Z  = 9,
    parameter ADDR_WIDTH_U  = 9,
    parameter ADDR_WIDTH_G  = 9,
    parameter ADDR_WIDTH_X  = 9,
    parameter pFP_WIDTH     = 64,
    parameter pINT_WIDTH    = 8
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
    output reg [BW_PER_ADDR_I-1:0] sram_wdata_i3
,

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
    output reg [BW_PER_ADDR_X-1:0] sram_wdata_x3
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

// ===== top state ===== //


localparam IDLE      = 7'd0;
localparam RGB_MAX   = 7'd1;
localparam RGB_MAX_t = 7'd2;
localparam NORMAL    = 7'd3;
localparam NORMAL_t  = 7'd4;
localparam Z_DIV_U   = 7'd5;

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
            top_state_n = Z_DIV_U;
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
    end else if (top_state == Z_DIV_U) begin
        done_cnt <= done_cnt + 1;
    end
end
assign done = (done_cnt == 10'd2000)? 1:0;

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
reg [(ADDR_WIDTH_Z-1):0] sram_z_addr;
reg [(ADDR_WIDTH_Z-1):0] sram_z_addr_n;

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
// this operation may be reduce to col-wise or row-wose deviation.
// 1. delGx = Gx @ Dx -> left col - right col and store to right col
// 2. delGy = Dy @ altGy ->


// write into SRAM X(64x32x1x64)

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


endmodule
