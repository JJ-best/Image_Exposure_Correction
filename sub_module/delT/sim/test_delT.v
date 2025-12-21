`timescale 1ns/1ps

module test_delT();
    // Parameters
    parameter BW_PER_ADDR_T = 128;  // 64-bit real + 64-bit imag
    parameter BW_PER_ADDR_X = 64;   // 64-bit real
    parameter ADDR_WIDTH_T = 8;     // 256 addresses per bank
    parameter ADDR_WIDTH_X = 9;     // 512 addresses per bank

    // Clock and reset
    reg clk;
    reg rst_n;

    // SRAM T signals (16 banks) - from delT module
    wire sram_wen_t0, sram_wen_t1, sram_wen_t2, sram_wen_t3;
    wire sram_wen_t4, sram_wen_t5, sram_wen_t6, sram_wen_t7;
    wire sram_wen_t8, sram_wen_t9, sram_wen_t10, sram_wen_t11;
    wire sram_wen_t12, sram_wen_t13, sram_wen_t14, sram_wen_t15;
    wire [BW_PER_ADDR_T-1:0] sram_rdata_t0, sram_rdata_t1, sram_rdata_t2, sram_rdata_t3;
    wire [BW_PER_ADDR_T-1:0] sram_rdata_t4, sram_rdata_t5, sram_rdata_t6, sram_rdata_t7;
    wire [BW_PER_ADDR_T-1:0] sram_rdata_t8, sram_rdata_t9, sram_rdata_t10, sram_rdata_t11;
    wire [BW_PER_ADDR_T-1:0] sram_rdata_t12, sram_rdata_t13, sram_rdata_t14, sram_rdata_t15;
    wire [ADDR_WIDTH_T-1:0] sram_addr_t0, sram_addr_t1, sram_addr_t2, sram_addr_t3;
    wire [ADDR_WIDTH_T-1:0] sram_addr_t4, sram_addr_t5, sram_addr_t6, sram_addr_t7;
    wire [ADDR_WIDTH_T-1:0] sram_addr_t8, sram_addr_t9, sram_addr_t10, sram_addr_t11;
    wire [ADDR_WIDTH_T-1:0] sram_addr_t12, sram_addr_t13, sram_addr_t14, sram_addr_t15;
    wire [BW_PER_ADDR_T-1:0] sram_wdata_t0, sram_wdata_t1, sram_wdata_t2, sram_wdata_t3;
    wire [BW_PER_ADDR_T-1:0] sram_wdata_t4, sram_wdata_t5, sram_wdata_t6, sram_wdata_t7;
    wire [BW_PER_ADDR_T-1:0] sram_wdata_t8, sram_wdata_t9, sram_wdata_t10, sram_wdata_t11;
    wire [BW_PER_ADDR_T-1:0] sram_wdata_t12, sram_wdata_t13, sram_wdata_t14, sram_wdata_t15;

    // SRAM X signals (4 banks) - from delT module
    wire sram_wen_x0;
    wire sram_wen_x1;
    wire sram_wen_x2;
    wire sram_wen_x3;
    wire [BW_PER_ADDR_X-1:0] sram_rdata_x0;
    wire [BW_PER_ADDR_X-1:0] sram_rdata_x1;
    wire [BW_PER_ADDR_X-1:0] sram_rdata_x2;
    wire [BW_PER_ADDR_X-1:0] sram_rdata_x3;
    wire [ADDR_WIDTH_X-1:0] sram_addr_x0;
    wire [ADDR_WIDTH_X-1:0] sram_addr_x1;
    wire [ADDR_WIDTH_X-1:0] sram_addr_x2;
    wire [ADDR_WIDTH_X-1:0] sram_addr_x3;
    wire [BW_PER_ADDR_X-1:0] sram_wdata_x0;
    wire [BW_PER_ADDR_X-1:0] sram_wdata_x1;
    wire [BW_PER_ADDR_X-1:0] sram_wdata_x2;
    wire [BW_PER_ADDR_X-1:0] sram_wdata_x3;

    // SRAM T interface signals (for SRAM model)
    // Use reg for initialization, wire for normal operation
    reg sram_t_wsb_0_init, sram_t_wsb_1_init, sram_t_wsb_2_init, sram_t_wsb_3_init;
    reg sram_t_wsb_4_init, sram_t_wsb_5_init, sram_t_wsb_6_init, sram_t_wsb_7_init;
    reg sram_t_wsb_8_init, sram_t_wsb_9_init, sram_t_wsb_10_init, sram_t_wsb_11_init;
    reg sram_t_wsb_12_init, sram_t_wsb_13_init, sram_t_wsb_14_init, sram_t_wsb_15_init;
    reg [ADDR_WIDTH_T-1:0] sram_t_waddr_0_init, sram_t_waddr_1_init, sram_t_waddr_2_init, sram_t_waddr_3_init;
    reg [ADDR_WIDTH_T-1:0] sram_t_waddr_4_init, sram_t_waddr_5_init, sram_t_waddr_6_init, sram_t_waddr_7_init;
    reg [ADDR_WIDTH_T-1:0] sram_t_waddr_8_init, sram_t_waddr_9_init, sram_t_waddr_10_init, sram_t_waddr_11_init;
    reg [ADDR_WIDTH_T-1:0] sram_t_waddr_12_init, sram_t_waddr_13_init, sram_t_waddr_14_init, sram_t_waddr_15_init;
    reg [BW_PER_ADDR_T-1:0] sram_t_wdata_0_init, sram_t_wdata_1_init, sram_t_wdata_2_init, sram_t_wdata_3_init;
    reg [BW_PER_ADDR_T-1:0] sram_t_wdata_4_init, sram_t_wdata_5_init, sram_t_wdata_6_init, sram_t_wdata_7_init;
    reg [BW_PER_ADDR_T-1:0] sram_t_wdata_8_init, sram_t_wdata_9_init, sram_t_wdata_10_init, sram_t_wdata_11_init;
    reg [BW_PER_ADDR_T-1:0] sram_t_wdata_12_init, sram_t_wdata_13_init, sram_t_wdata_14_init, sram_t_wdata_15_init;
    reg init_mode;  // Flag to indicate initialization mode
    
    // Mux between init signals and normal delT signals
    wire sram_t_wsb_0, sram_t_wsb_1, sram_t_wsb_2, sram_t_wsb_3;
    wire sram_t_wsb_4, sram_t_wsb_5, sram_t_wsb_6, sram_t_wsb_7;
    wire sram_t_wsb_8, sram_t_wsb_9, sram_t_wsb_10, sram_t_wsb_11;
    wire sram_t_wsb_12, sram_t_wsb_13, sram_t_wsb_14, sram_t_wsb_15;
    wire [ADDR_WIDTH_T-1:0] sram_t_waddr_0, sram_t_waddr_1, sram_t_waddr_2, sram_t_waddr_3;
    wire [ADDR_WIDTH_T-1:0] sram_t_waddr_4, sram_t_waddr_5, sram_t_waddr_6, sram_t_waddr_7;
    wire [ADDR_WIDTH_T-1:0] sram_t_waddr_8, sram_t_waddr_9, sram_t_waddr_10, sram_t_waddr_11;
    wire [ADDR_WIDTH_T-1:0] sram_t_waddr_12, sram_t_waddr_13, sram_t_waddr_14, sram_t_waddr_15;
    wire [ADDR_WIDTH_T-1:0] sram_t_raddr_0, sram_t_raddr_1, sram_t_raddr_2, sram_t_raddr_3;
    wire [ADDR_WIDTH_T-1:0] sram_t_raddr_4, sram_t_raddr_5, sram_t_raddr_6, sram_t_raddr_7;
    wire [ADDR_WIDTH_T-1:0] sram_t_raddr_8, sram_t_raddr_9, sram_t_raddr_10, sram_t_raddr_11;
    wire [ADDR_WIDTH_T-1:0] sram_t_raddr_12, sram_t_raddr_13, sram_t_raddr_14, sram_t_raddr_15;
    wire [BW_PER_ADDR_T-1:0] sram_t_wdata_0, sram_t_wdata_1, sram_t_wdata_2, sram_t_wdata_3;
    wire [BW_PER_ADDR_T-1:0] sram_t_wdata_4, sram_t_wdata_5, sram_t_wdata_6, sram_t_wdata_7;
    wire [BW_PER_ADDR_T-1:0] sram_t_wdata_8, sram_t_wdata_9, sram_t_wdata_10, sram_t_wdata_11;
    wire [BW_PER_ADDR_T-1:0] sram_t_wdata_12, sram_t_wdata_13, sram_t_wdata_14, sram_t_wdata_15;

    // SRAM X interface signals (for SRAM model)
    wire sram_x_wsb_0, sram_x_wsb_1, sram_x_wsb_2, sram_x_wsb_3;
    wire [ADDR_WIDTH_X-1:0] sram_x_waddr_0, sram_x_waddr_1, sram_x_waddr_2, sram_x_waddr_3;
    wire [ADDR_WIDTH_X-1:0] sram_x_raddr_0, sram_x_raddr_1, sram_x_raddr_2, sram_x_raddr_3;
    wire [BW_PER_ADDR_X-1:0] sram_x_wdata_0, sram_x_wdata_1, sram_x_wdata_2, sram_x_wdata_3;

    // FP_ADD signals (4 instances)
    wire [63:0]  fp_add_01_in_A, fp_add_01_in_B;
    wire         fp_add_01_in_valid;
    wire [63:0]  fp_add_01_result;
    wire         fp_add_01_out_valid;

    wire [63:0]  fp_add_02_in_A, fp_add_02_in_B;
    wire         fp_add_02_in_valid;
    wire [63:0]  fp_add_02_result;
    wire         fp_add_02_out_valid;

    wire [63:0]  fp_add_11_in_A, fp_add_11_in_B;
    wire         fp_add_11_in_valid;
    wire [63:0]  fp_add_11_result;
    wire         fp_add_11_out_valid;

    wire [63:0]  fp_add_12_in_A, fp_add_12_in_B;
    wire         fp_add_12_in_valid;
    wire [63:0]  fp_add_12_result;
    wire         fp_add_12_out_valid;

    // Control signals
    reg enable;
    wire done;
   
    // Interface conversion: delT signals to SRAM model signals
    // SRAM T: sram_wen is active high, wsb is active low
    // Mux between init mode and normal mode
    assign sram_t_wsb_0 = init_mode ? sram_t_wsb_0_init : ~sram_wen_t0;
    assign sram_t_wsb_1 = init_mode ? sram_t_wsb_1_init : ~sram_wen_t1;
    assign sram_t_wsb_2 = init_mode ? sram_t_wsb_2_init : ~sram_wen_t2;
    assign sram_t_wsb_3 = init_mode ? sram_t_wsb_3_init : ~sram_wen_t3;
    assign sram_t_wsb_4 = init_mode ? sram_t_wsb_4_init : ~sram_wen_t4;
    assign sram_t_wsb_5 = init_mode ? sram_t_wsb_5_init : ~sram_wen_t5;
    assign sram_t_wsb_6 = init_mode ? sram_t_wsb_6_init : ~sram_wen_t6;
    assign sram_t_wsb_7 = init_mode ? sram_t_wsb_7_init : ~sram_wen_t7;
    assign sram_t_wsb_8 = init_mode ? sram_t_wsb_8_init : ~sram_wen_t8;
    assign sram_t_wsb_9 = init_mode ? sram_t_wsb_9_init : ~sram_wen_t9;
    assign sram_t_wsb_10 = init_mode ? sram_t_wsb_10_init : ~sram_wen_t10;
    assign sram_t_wsb_11 = init_mode ? sram_t_wsb_11_init : ~sram_wen_t11;
    assign sram_t_wsb_12 = init_mode ? sram_t_wsb_12_init : ~sram_wen_t12;
    assign sram_t_wsb_13 = init_mode ? sram_t_wsb_13_init : ~sram_wen_t13;
    assign sram_t_wsb_14 = init_mode ? sram_t_wsb_14_init : ~sram_wen_t14;
    assign sram_t_wsb_15 = init_mode ? sram_t_wsb_15_init : ~sram_wen_t15;

    // Address and data connections (assuming unified address for read/write)
    // Mux between init mode and normal mode
    assign sram_t_waddr_0 = init_mode ? sram_t_waddr_0_init : sram_addr_t0;
    assign sram_t_waddr_1 = init_mode ? sram_t_waddr_1_init : sram_addr_t1;
    assign sram_t_waddr_2 = init_mode ? sram_t_waddr_2_init : sram_addr_t2;
    assign sram_t_waddr_3 = init_mode ? sram_t_waddr_3_init : sram_addr_t3;
    assign sram_t_waddr_4 = init_mode ? sram_t_waddr_4_init : sram_addr_t4;
    assign sram_t_waddr_5 = init_mode ? sram_t_waddr_5_init : sram_addr_t5;
    assign sram_t_waddr_6 = init_mode ? sram_t_waddr_6_init : sram_addr_t6;
    assign sram_t_waddr_7 = init_mode ? sram_t_waddr_7_init : sram_addr_t7;
    assign sram_t_waddr_8 = init_mode ? sram_t_waddr_8_init : sram_addr_t8;
    assign sram_t_waddr_9 = init_mode ? sram_t_waddr_9_init : sram_addr_t9;
    assign sram_t_waddr_10 = init_mode ? sram_t_waddr_10_init : sram_addr_t10;
    assign sram_t_waddr_11 = init_mode ? sram_t_waddr_11_init : sram_addr_t11;
    assign sram_t_waddr_12 = init_mode ? sram_t_waddr_12_init : sram_addr_t12;
    assign sram_t_waddr_13 = init_mode ? sram_t_waddr_13_init : sram_addr_t13;
    assign sram_t_waddr_14 = init_mode ? sram_t_waddr_14_init : sram_addr_t14;
    assign sram_t_waddr_15 = init_mode ? sram_t_waddr_15_init : sram_addr_t15;

    assign sram_t_raddr_0 = sram_addr_t0;
    assign sram_t_raddr_1 = sram_addr_t1;
    assign sram_t_raddr_2 = sram_addr_t2;
    assign sram_t_raddr_3 = sram_addr_t3;
    assign sram_t_raddr_4 = sram_addr_t4;
    assign sram_t_raddr_5 = sram_addr_t5;
    assign sram_t_raddr_6 = sram_addr_t6;
    assign sram_t_raddr_7 = sram_addr_t7;
    assign sram_t_raddr_8 = sram_addr_t8;
    assign sram_t_raddr_9 = sram_addr_t9;
    assign sram_t_raddr_10 = sram_addr_t10;
    assign sram_t_raddr_11 = sram_addr_t11;
    assign sram_t_raddr_12 = sram_addr_t12;
    assign sram_t_raddr_13 = sram_addr_t13;
    assign sram_t_raddr_14 = sram_addr_t14;
    assign sram_t_raddr_15 = sram_addr_t15;

    assign sram_t_wdata_0 = init_mode ? sram_t_wdata_0_init : sram_wdata_t0;
    assign sram_t_wdata_1 = init_mode ? sram_t_wdata_1_init : sram_wdata_t1;
    assign sram_t_wdata_2 = init_mode ? sram_t_wdata_2_init : sram_wdata_t2;
    assign sram_t_wdata_3 = init_mode ? sram_t_wdata_3_init : sram_wdata_t3;
    assign sram_t_wdata_4 = init_mode ? sram_t_wdata_4_init : sram_wdata_t4;
    assign sram_t_wdata_5 = init_mode ? sram_t_wdata_5_init : sram_wdata_t5;
    assign sram_t_wdata_6 = init_mode ? sram_t_wdata_6_init : sram_wdata_t6;
    assign sram_t_wdata_7 = init_mode ? sram_t_wdata_7_init : sram_wdata_t7;
    assign sram_t_wdata_8 = init_mode ? sram_t_wdata_8_init : sram_wdata_t8;
    assign sram_t_wdata_9 = init_mode ? sram_t_wdata_9_init : sram_wdata_t9;
    assign sram_t_wdata_10 = init_mode ? sram_t_wdata_10_init : sram_wdata_t10;
    assign sram_t_wdata_11 = init_mode ? sram_t_wdata_11_init : sram_wdata_t11;
    assign sram_t_wdata_12 = init_mode ? sram_t_wdata_12_init : sram_wdata_t12;
    assign sram_t_wdata_13 = init_mode ? sram_t_wdata_13_init : sram_wdata_t13;
    assign sram_t_wdata_14 = init_mode ? sram_t_wdata_14_init : sram_wdata_t14;
    assign sram_t_wdata_15 = init_mode ? sram_t_wdata_15_init : sram_wdata_t15;

    // SRAM X interface conversion
    assign sram_x_wsb_0 = ~sram_wen_x0;
    assign sram_x_wsb_1 = ~sram_wen_x1;
    assign sram_x_wsb_2 = ~sram_wen_x2;
    assign sram_x_wsb_3 = ~sram_wen_x3;

    assign sram_x_waddr_0 = sram_addr_x0;
    assign sram_x_waddr_1 = sram_addr_x1;
    assign sram_x_waddr_2 = sram_addr_x2;
    assign sram_x_waddr_3 = sram_addr_x3;

    assign sram_x_raddr_0 = sram_addr_x0;
    assign sram_x_raddr_1 = sram_addr_x1;
    assign sram_x_raddr_2 = sram_addr_x2;
    assign sram_x_raddr_3 = sram_addr_x3;

    assign sram_x_wdata_0 = sram_wdata_x0;
    assign sram_x_wdata_1 = sram_wdata_x1;
    assign sram_x_wdata_2 = sram_wdata_x2;
    assign sram_x_wdata_3 = sram_wdata_x3;

    // Dump waveform file
    initial begin
        $dumpfile("delT_sim.vcd");
        $dumpvars(0, test_delT);
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #1 clk = ~clk;  // 100MHz
    end

    // Reset generation
    initial begin
        rst_n = 0;
        enable = 0;
        init_mode = 0;  // Start in normal mode
        #100;
        rst_n = 1;
    end

    // Instantiate SRAM T - 16 banks
    sram_64x16b_16bank #(
        .BW_PER_ADDR(BW_PER_ADDR_T),
        .ADDR_WIDTH(ADDR_WIDTH_T)
    ) u_sram_t (
        .clk(clk),
        .csb(1'b0),
        .wsb_0(sram_t_wsb_0), .wsb_1(sram_t_wsb_1), .wsb_2(sram_t_wsb_2), .wsb_3(sram_t_wsb_3),
        .wsb_4(sram_t_wsb_4), .wsb_5(sram_t_wsb_5), .wsb_6(sram_t_wsb_6), .wsb_7(sram_t_wsb_7),
        .wsb_8(sram_t_wsb_8), .wsb_9(sram_t_wsb_9), .wsb_10(sram_t_wsb_10), .wsb_11(sram_t_wsb_11),
        .wsb_12(sram_t_wsb_12), .wsb_13(sram_t_wsb_13), .wsb_14(sram_t_wsb_14), .wsb_15(sram_t_wsb_15),
        .wdata_0(sram_t_wdata_0), .wdata_1(sram_t_wdata_1), .wdata_2(sram_t_wdata_2), .wdata_3(sram_t_wdata_3),
        .wdata_4(sram_t_wdata_4), .wdata_5(sram_t_wdata_5), .wdata_6(sram_t_wdata_6), .wdata_7(sram_t_wdata_7),
        .wdata_8(sram_t_wdata_8), .wdata_9(sram_t_wdata_9), .wdata_10(sram_t_wdata_10), .wdata_11(sram_t_wdata_11),
        .wdata_12(sram_t_wdata_12), .wdata_13(sram_t_wdata_13), .wdata_14(sram_t_wdata_14), .wdata_15(sram_t_wdata_15),
        .waddr_0(sram_t_waddr_0), .waddr_1(sram_t_waddr_1), .waddr_2(sram_t_waddr_2), .waddr_3(sram_t_waddr_3),
        .waddr_4(sram_t_waddr_4), .waddr_5(sram_t_waddr_5), .waddr_6(sram_t_waddr_6), .waddr_7(sram_t_waddr_7),
        .waddr_8(sram_t_waddr_8), .waddr_9(sram_t_waddr_9), .waddr_10(sram_t_waddr_10), .waddr_11(sram_t_waddr_11),
        .waddr_12(sram_t_waddr_12), .waddr_13(sram_t_waddr_13), .waddr_14(sram_t_waddr_14), .waddr_15(sram_t_waddr_15),
        .raddr_0(sram_t_raddr_0), .raddr_1(sram_t_raddr_1), .raddr_2(sram_t_raddr_2), .raddr_3(sram_t_raddr_3),
        .raddr_4(sram_t_raddr_4), .raddr_5(sram_t_raddr_5), .raddr_6(sram_t_raddr_6), .raddr_7(sram_t_raddr_7),
        .raddr_8(sram_t_raddr_8), .raddr_9(sram_t_raddr_9), .raddr_10(sram_t_raddr_10), .raddr_11(sram_t_raddr_11),
        .raddr_12(sram_t_raddr_12), .raddr_13(sram_t_raddr_13), .raddr_14(sram_t_raddr_14), .raddr_15(sram_t_raddr_15),
        .rdata_0(sram_rdata_t0), .rdata_1(sram_rdata_t1), .rdata_2(sram_rdata_t2), .rdata_3(sram_rdata_t3),
        .rdata_4(sram_rdata_t4), .rdata_5(sram_rdata_t5), .rdata_6(sram_rdata_t6), .rdata_7(sram_rdata_t7),
        .rdata_8(sram_rdata_t8), .rdata_9(sram_rdata_t9), .rdata_10(sram_rdata_t10), .rdata_11(sram_rdata_t11),
        .rdata_12(sram_rdata_t12), .rdata_13(sram_rdata_t13), .rdata_14(sram_rdata_t14), .rdata_15(sram_rdata_t15)
    );

    // Instantiate SRAM X - 4 banks
    sram_512x8b #(
        .BW_PER_ADDR(BW_PER_ADDR_X),
        .ADDR_WIDTH(ADDR_WIDTH_X)
    ) u_sram_x (
        .clk(clk),
        .csb(1'b0),
        .wsb_0(sram_x_wsb_0), .wsb_1(sram_x_wsb_1), .wsb_2(sram_x_wsb_2), .wsb_3(sram_x_wsb_3),
        .wdata_0(sram_x_wdata_0), .wdata_1(sram_x_wdata_1), .wdata_2(sram_x_wdata_2), .wdata_3(sram_x_wdata_3),
        .waddr_0(sram_x_waddr_0), .waddr_1(sram_x_waddr_1), .waddr_2(sram_x_waddr_2), .waddr_3(sram_x_waddr_3),
        .raddr_0(sram_x_raddr_0), .raddr_1(sram_x_raddr_1), .raddr_2(sram_x_raddr_2), .raddr_3(sram_x_raddr_3),
        .rdata_0(sram_rdata_x0), .rdata_1(sram_rdata_x1), .rdata_2(sram_rdata_x2), .rdata_3(sram_rdata_x3)
    );

    // FP_ADD instances (4 instances)
    fp_add u_fp_add_01 (
        .in_A(fp_add_01_in_A),
        .in_B(fp_add_01_in_B),
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(fp_add_01_in_valid),
        .result(fp_add_01_result),
        .out_valid(fp_add_01_out_valid)
    );

    fp_add u_fp_add_02 (
        .in_A(fp_add_02_in_A),
        .in_B(fp_add_02_in_B),
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(fp_add_02_in_valid),
        .result(fp_add_02_result),
        .out_valid(fp_add_02_out_valid)
    );

    fp_add u_fp_add_11 (
        .in_A(fp_add_11_in_A),
        .in_B(fp_add_11_in_B),
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(fp_add_11_in_valid),
        .result(fp_add_11_result),
        .out_valid(fp_add_11_out_valid)
    );

    fp_add u_fp_add_12 (
        .in_A(fp_add_12_in_A),
        .in_B(fp_add_12_in_B),
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(fp_add_12_in_valid),
        .result(fp_add_12_result),
        .out_valid(fp_add_12_out_valid)
    );

    // Instantiate delT module
    delT #(
        .BW_PER_ADDR_T(BW_PER_ADDR_T),
        .BW_PER_ADDR_X(BW_PER_ADDR_X),
        .ADDR_WIDTH_T(ADDR_WIDTH_T),
        .ADDR_WIDTH_X(ADDR_WIDTH_X)
    ) u_delT (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .done(done),
        // SRAM T signals
        .sram_wen_t0(sram_wen_t0), .sram_wen_t1(sram_wen_t1), .sram_wen_t2(sram_wen_t2), .sram_wen_t3(sram_wen_t3),
        .sram_wen_t4(sram_wen_t4), .sram_wen_t5(sram_wen_t5), .sram_wen_t6(sram_wen_t6), .sram_wen_t7(sram_wen_t7),
        .sram_wen_t8(sram_wen_t8), .sram_wen_t9(sram_wen_t9), .sram_wen_t10(sram_wen_t10), .sram_wen_t11(sram_wen_t11),
        .sram_wen_t12(sram_wen_t12), .sram_wen_t13(sram_wen_t13), .sram_wen_t14(sram_wen_t14), .sram_wen_t15(sram_wen_t15),
        .sram_rdata_t0(sram_rdata_t0), .sram_rdata_t1(sram_rdata_t1), .sram_rdata_t2(sram_rdata_t2), .sram_rdata_t3(sram_rdata_t3),
        .sram_rdata_t4(sram_rdata_t4), .sram_rdata_t5(sram_rdata_t5), .sram_rdata_t6(sram_rdata_t6), .sram_rdata_t7(sram_rdata_t7),
        .sram_rdata_t8(sram_rdata_t8), .sram_rdata_t9(sram_rdata_t9), .sram_rdata_t10(sram_rdata_t10), .sram_rdata_t11(sram_rdata_t11),
        .sram_rdata_t12(sram_rdata_t12), .sram_rdata_t13(sram_rdata_t13), .sram_rdata_t14(sram_rdata_t14), .sram_rdata_t15(sram_rdata_t15),
        .sram_addr_t0(sram_addr_t0), .sram_addr_t1(sram_addr_t1), .sram_addr_t2(sram_addr_t2), .sram_addr_t3(sram_addr_t3),
        .sram_addr_t4(sram_addr_t4), .sram_addr_t5(sram_addr_t5), .sram_addr_t6(sram_addr_t6), .sram_addr_t7(sram_addr_t7),
        .sram_addr_t8(sram_addr_t8), .sram_addr_t9(sram_addr_t9), .sram_addr_t10(sram_addr_t10), .sram_addr_t11(sram_addr_t11),
        .sram_addr_t12(sram_addr_t12), .sram_addr_t13(sram_addr_t13), .sram_addr_t14(sram_addr_t14), .sram_addr_t15(sram_addr_t15),
        .sram_wdata_t0(sram_wdata_t0), .sram_wdata_t1(sram_wdata_t1), .sram_wdata_t2(sram_wdata_t2), .sram_wdata_t3(sram_wdata_t3),
        .sram_wdata_t4(sram_wdata_t4), .sram_wdata_t5(sram_wdata_t5), .sram_wdata_t6(sram_wdata_t6), .sram_wdata_t7(sram_wdata_t7),
        .sram_wdata_t8(sram_wdata_t8), .sram_wdata_t9(sram_wdata_t9), .sram_wdata_t10(sram_wdata_t10), .sram_wdata_t11(sram_wdata_t11),
        .sram_wdata_t12(sram_wdata_t12), .sram_wdata_t13(sram_wdata_t13), .sram_wdata_t14(sram_wdata_t14), .sram_wdata_t15(sram_wdata_t15),
        // SRAM X signals
        .sram_wen_x0(sram_wen_x0), .sram_wen_x1(sram_wen_x1), .sram_wen_x2(sram_wen_x2), .sram_wen_x3(sram_wen_x3),
        .sram_rdata_x0(sram_rdata_x0), .sram_rdata_x1(sram_rdata_x1), .sram_rdata_x2(sram_rdata_x2), .sram_rdata_x3(sram_rdata_x3),
        .sram_addr_x0(sram_addr_x0), .sram_addr_x1(sram_addr_x1), .sram_addr_x2(sram_addr_x2), .sram_addr_x3(sram_addr_x3),
        .sram_wdata_x0(sram_wdata_x0), .sram_wdata_x1(sram_wdata_x1), .sram_wdata_x2(sram_wdata_x2), .sram_wdata_x3(sram_wdata_x3),
        // FP_ADD signals
        .fp_add_01_in_A(fp_add_01_in_A), .fp_add_01_in_B(fp_add_01_in_B),
        .fp_add_01_in_valid(fp_add_01_in_valid),
        .fp_add_01_result(fp_add_01_result),
        .fp_add_01_out_valid(fp_add_01_out_valid),
        .fp_add_02_in_A(fp_add_02_in_A), .fp_add_02_in_B(fp_add_02_in_B),
        .fp_add_02_in_valid(fp_add_02_in_valid),
        .fp_add_02_result(fp_add_02_result),
        .fp_add_02_out_valid(fp_add_02_out_valid),
        .fp_add_11_in_A(fp_add_11_in_A), .fp_add_11_in_B(fp_add_11_in_B),
        .fp_add_11_in_valid(fp_add_11_in_valid),
        .fp_add_11_result(fp_add_11_result),
        .fp_add_11_out_valid(fp_add_11_out_valid),
        .fp_add_12_in_A(fp_add_12_in_A), .fp_add_12_in_B(fp_add_12_in_B),
        .fp_add_12_in_valid(fp_add_12_in_valid),
        .fp_add_12_result(fp_add_12_result),
        .fp_add_12_out_valid(fp_add_12_out_valid)
    );

    // Task: Load sramT_2.dat into SRAM T
    // Format: Each line is "hex1_hex2", need to remove '_' and form 128b
    // Each line corresponds to one bank, 16 banks per address
    task load_sramT;
        input [256*8-1:0] filename;
        
        integer file_in;
        integer line_count;
        integer addr, bank;
        reg [63:0] hex1, hex2;
        reg [127:0] data_128b;
        integer scan_result;
        reg [256*8-1:0] hex1_str, hex2_str;
        
    begin
        $display("Loading SRAM T from file: %s", filename);
        $display("Writing through SRAM interface (waddr, wdata, wsb) for waveform visibility");
        
        // Enable initialization mode
        init_mode = 1;
        
        // Initialize all write enables to inactive (active low)
        sram_t_wsb_0_init = 1;
        sram_t_wsb_1_init = 1;
        sram_t_wsb_2_init = 1;
        sram_t_wsb_3_init = 1;
        sram_t_wsb_4_init = 1;
        sram_t_wsb_5_init = 1;
        sram_t_wsb_6_init = 1;
        sram_t_wsb_7_init = 1;
        sram_t_wsb_8_init = 1;
        sram_t_wsb_9_init = 1;
        sram_t_wsb_10_init = 1;
        sram_t_wsb_11_init = 1;
        sram_t_wsb_12_init = 1;
        sram_t_wsb_13_init = 1;
        sram_t_wsb_14_init = 1;
        sram_t_wsb_15_init = 1;
        
        file_in = $fopen(filename, "r");
        if (file_in == 0) begin
            $display("ERROR: Cannot open file %s", filename);
            $finish;
        end
        
        line_count = 0;
        
        // Read file line by line
        // Format: "hex1_hex2" where hex1 and hex2 are 16 hex digits each
        while (!$feof(file_in)) begin
            // Read hex values directly - $fscanf can handle underscore as separator
            // Format: 16 hex digits, underscore, 16 hex digits
            scan_result = $fscanf(file_in, "%16h_%16h", hex1, hex2);
            
            if (scan_result == 2) begin
                // Form 128b data: {hex1, hex2}
                data_128b = {hex1, hex2};
                
                // Calculate address and bank
                // Each address has 16 banks, so line_count / 16 gives address
                addr = line_count / 16;
                bank = line_count % 16;
                
                // Set up write signals for this bank
                    case(bank)
                    0: begin
                        sram_t_waddr_0_init = addr;
                        sram_t_wdata_0_init = data_128b;
                        sram_t_wsb_0_init = 0;  // Active low, enable write
                    end
                    1: begin
                        sram_t_waddr_1_init = addr;
                        sram_t_wdata_1_init = data_128b;
                        sram_t_wsb_1_init = 0;
                    end
                    2: begin
                        sram_t_waddr_2_init = addr;
                        sram_t_wdata_2_init = data_128b;
                        sram_t_wsb_2_init = 0;
                    end
                    3: begin
                        sram_t_waddr_3_init = addr;
                        sram_t_wdata_3_init = data_128b;
                        sram_t_wsb_3_init = 0;
                    end
                    4: begin
                        sram_t_waddr_4_init = addr;
                        sram_t_wdata_4_init = data_128b;
                        sram_t_wsb_4_init = 0;
                    end
                    5: begin
                        sram_t_waddr_5_init = addr;
                        sram_t_wdata_5_init = data_128b;
                        sram_t_wsb_5_init = 0;
                    end
                    6: begin
                        sram_t_waddr_6_init = addr;
                        sram_t_wdata_6_init = data_128b;
                        sram_t_wsb_6_init = 0;
                    end
                    7: begin
                        sram_t_waddr_7_init = addr;
                        sram_t_wdata_7_init = data_128b;
                        sram_t_wsb_7_init = 0;
                    end
                    8: begin
                        sram_t_waddr_8_init = addr;
                        sram_t_wdata_8_init = data_128b;
                        sram_t_wsb_8_init = 0;
                    end
                    9: begin
                        sram_t_waddr_9_init = addr;
                        sram_t_wdata_9_init = data_128b;
                        sram_t_wsb_9_init = 0;
                    end
                    10: begin
                        sram_t_waddr_10_init = addr;
                        sram_t_wdata_10_init = data_128b;
                        sram_t_wsb_10_init = 0;
                    end
                    11: begin
                        sram_t_waddr_11_init = addr;
                        sram_t_wdata_11_init = data_128b;
                        sram_t_wsb_11_init = 0;
                    end
                    12: begin
                        sram_t_waddr_12_init = addr;
                        sram_t_wdata_12_init = data_128b;
                        sram_t_wsb_12_init = 0;
                    end
                    13: begin
                        sram_t_waddr_13_init = addr;
                        sram_t_wdata_13_init = data_128b;
                        sram_t_wsb_13_init = 0;
                    end
                    14: begin
                        sram_t_waddr_14_init = addr;
                        sram_t_wdata_14_init = data_128b;
                        sram_t_wsb_14_init = 0;
                    end
                    15: begin
                        sram_t_waddr_15_init = addr;
                        sram_t_wdata_15_init = data_128b;
                        sram_t_wsb_15_init = 0;
                    end
                    endcase
                
                // Wait for clock edge to write
                @(posedge clk);
                #1;  // Small delay after clock edge
                
                // Deassert write enable after one cycle
                case(bank)
                    0: sram_t_wsb_0_init = 1;
                    1: sram_t_wsb_1_init = 1;
                    2: sram_t_wsb_2_init = 1;
                    3: sram_t_wsb_3_init = 1;
                    4: sram_t_wsb_4_init = 1;
                    5: sram_t_wsb_5_init = 1;
                    6: sram_t_wsb_6_init = 1;
                    7: sram_t_wsb_7_init = 1;
                    8: sram_t_wsb_8_init = 1;
                    9: sram_t_wsb_9_init = 1;
                    10: sram_t_wsb_10_init = 1;
                    11: sram_t_wsb_11_init = 1;
                    12: sram_t_wsb_12_init = 1;
                    13: sram_t_wsb_13_init = 1;
                    14: sram_t_wsb_14_init = 1;
                    15: sram_t_wsb_15_init = 1;
                endcase
                
                line_count = line_count + 1;
                
                if (line_count % 100 == 0) begin
                    $display("Loaded %0d lines (addr=%0d, bank=%0d)", line_count, addr, bank);
                end
            end else if (scan_result == 1) begin
                // Only one value read, might be end of file or error
                if (!$feof(file_in)) begin
                    $display("WARNING: Line %0d format error, skipping", line_count);
                end
            end
        end
        
        // Wait one more cycle to ensure last write completes
        @(posedge clk);
        
        // Disable initialization mode
        init_mode = 0;
        
            $fclose(file_in);
        $display("SRAM T loading complete: %0d lines loaded", line_count);
    end
    endtask

    // Task: Print SRAM T contents
    task print_sramT;
        input integer max_addr;  // Maximum address to print (0 = print all)
        input integer max_bank;  // Maximum bank to print (0 = print all, -1 = print all)
        
        integer addr, bank;
        integer addr_limit, bank_limit;
        reg [127:0] data_128b;
        reg [63:0] data_real, data_imag;
        real real_val, imag_val;
        
    begin
        // Printing SRAM T Contents (header removed as requested)
        
        // Determine limits
        if (max_addr == 0) begin
            addr_limit = (1 << ADDR_WIDTH_T) - 1;  // Print all addresses
        end else begin
            addr_limit = max_addr;
        end
        
        if (max_bank == -1 || max_bank == 0) begin
            bank_limit = 15;  // Print all 16 banks
        end else begin
            bank_limit = max_bank;
        end
        
        $display("Printing addresses 0 to %0d, banks 0 to %0d", addr_limit, bank_limit);
        $display("Format: [Addr=X, Bank=Y] Real=0xHEX (float_value) Imag=0xHEX (float_value)");
        $display("----------------------------------------------------------------------");
        
        for (addr = 0; addr <= addr_limit; addr = addr + 1) begin
            for (bank = 0; bank <= bank_limit; bank = bank + 1) begin
                // Read from SRAM T
                case(bank)
                    0: data_128b = u_sram_t.bank0[addr];
                    1: data_128b = u_sram_t.bank1[addr];
                    2: data_128b = u_sram_t.bank2[addr];
                    3: data_128b = u_sram_t.bank3[addr];
                    4: data_128b = u_sram_t.bank4[addr];
                    5: data_128b = u_sram_t.bank5[addr];
                    6: data_128b = u_sram_t.bank6[addr];
                    7: data_128b = u_sram_t.bank7[addr];
                    8: data_128b = u_sram_t.bank8[addr];
                    9: data_128b = u_sram_t.bank9[addr];
                    10: data_128b = u_sram_t.bank10[addr];
                    11: data_128b = u_sram_t.bank11[addr];
                    12: data_128b = u_sram_t.bank12[addr];
                    13: data_128b = u_sram_t.bank13[addr];
                    14: data_128b = u_sram_t.bank14[addr];
                    15: data_128b = u_sram_t.bank15[addr];
                endcase
                
                // Extract real and imaginary parts (128b = {real[63:0], imag[63:0]})
                data_real = data_128b[127:64];
                data_imag = data_128b[63:0];
                
                // Convert to real values
                real_val = $bitstoreal(data_real);
                imag_val = $bitstoreal(data_imag);
                
                // Print
                $display("[Addr=%0d, Bank=%0d] Real=0x%016h (%.10e) Imag=0x%016h (%.10e)", 
                         addr, bank, data_real, real_val, data_imag, imag_val);
            end
        end
        
        $display("----------------------------------------------------------------------");
        $display("SRAM T printing complete");
    end
    endtask

    // Task: Verify SRAM X against golden file
    // Format: Each line is 64b hex value
    // 4 banks interleaving: lines 0,1,2,3 -> addr 0 banks 0,1,2,3
    //                        lines 4,5,6,7 -> addr 1 banks 0,1,2,3
    task verify_sramX;
        input [256*8-1:0] golden_filename;
        
        integer file_in;
        integer line_count;
        integer addr, bank;
        reg [63:0] golden_data;
        reg [63:0] sram_data;
        integer error_count;
        integer scan_result;
        real golden_val, sram_val;
        real diff, diff_abs;
        real epsilon;
        reg stop_loop;
        
    begin
        $display("Verifying SRAM X against golden file: %s", golden_filename);
        
        file_in = $fopen(golden_filename, "r");
        if (file_in == 0) begin
            $display("ERROR: Cannot open golden file %s", golden_filename);
            disable verify_sramX;
        end
        
        error_count = 0;
        line_count = 0;
        epsilon = 1.0e-10;
        stop_loop = 0;
        
        while (!$feof(file_in) && !stop_loop) begin
            // Read hex value from file
            scan_result = $fscanf(file_in, "%h", golden_data);
            
            if (scan_result == 1) begin
                // Calculate address and bank (interleaving: 4 lines per address)
                addr = line_count / 4;
                bank = line_count % 4;
                
                // Read from SRAM X
                case(bank)
                    0: sram_data = u_sram_x.bank0[addr];
                    1: sram_data = u_sram_x.bank1[addr];
                    2: sram_data = u_sram_x.bank2[addr];
                    3: sram_data = u_sram_x.bank3[addr];
                endcase
                
                // Convert to real values for comparison
                golden_val = $bitstoreal(golden_data);
                sram_val = $bitstoreal(sram_data);
                diff = sram_val - golden_val;
                diff_abs = (diff >= 0) ? diff : -diff;
                
                // Compare and print all values (both correct and incorrect)
                if (diff_abs >= epsilon) begin
                    $display("ERROR at line=%0d (addr=%0d, bank=%0d):", line_count, addr, bank);
                    $display("  Expected: 0x%h (%.10e)", golden_data, golden_val);
                    $display("  Got:      0x%h (%.10e)", sram_data, sram_val);
                    $display("  Diff:     %.10e", diff_abs);
                    error_count = error_count + 1;
                end else begin
                    $display("\033[32mPASS\033[0m at line=%0d (addr=%0d, bank=%0d): 0x%h (%.10e)", line_count, addr, bank, sram_data, sram_val);
                end
                
                line_count = line_count + 1;
            end
        end
        
            $fclose(file_in);
        
        if (error_count == 0) begin
            $display("\033[32mPASS\033[0m: SRAM X verification successful! (%0d values checked)", line_count);
        end else begin
            $display("FAIL: SRAM X verification failed with %0d errors out of %0d values", error_count, line_count);
        end
    end
    endtask

    // Main test sequence
    integer timeout_counter;
    integer timeout_limit;
    
    initial begin
        $display("========================================");
        $display("delT Test Environment");
        $display("========================================");
        
        // Set timeout limit (in clock cycles)
        timeout_limit = 1000000;  // 1 million cycles = reasonable timeout
        
        // Wait for reset
        wait(rst_n);
        #200;
        
        // Step 1: Load sramT_2.dat into SRAM T
        $display("\n=== Step 1: Loading sramT_2.dat into SRAM T ===");
        load_sramT("../../../py/py_overlap_partition/alm/patch_00_00_over/iter_000/sramT_2.dat");
        #100;
        
        // Print SRAM T contents after initialization
        $display("\n=== Printing SRAM T after initialization ===");
        print_sramT(10, 15);  // Print first 11 addresses (0-10), all 16 banks
        #100;
        
        // Step 2: Assert enable and wait for done
        $display("\n=== Step 2: Starting delT computation ===");
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        enable = 0;
        $display("Enable signal asserted");
        $display("Timeout limit set to %0d clock cycles", timeout_limit);
        
        // Debug: Monitor SRAM T read (removed as requested)
        
        // Wait for done signal with timeout
        timeout_counter = 0;
        while (!done && timeout_counter < timeout_limit) begin
            @(posedge clk);
            timeout_counter = timeout_counter + 1;
            
            // Print progress every 10000 cycles
            if (timeout_counter % 10000 == 0) begin
                $display("Waiting for done signal... (%0d / %0d cycles)", timeout_counter, timeout_limit);
            end
        end
        
        if (timeout_counter >= timeout_limit) begin
            $display("\nERROR: Timeout waiting for done signal!");
            $display("Simulation exceeded %0d clock cycles without receiving done signal", timeout_limit);
            $display("This may indicate a design issue or the timeout limit is too small");
            $finish;
                end else begin
            @(posedge clk);
            enable = 0;
            $display("Done signal received after %0d clock cycles, enable deasserted", timeout_counter);
            end
            #100;
            
        // Step 3: Verify SRAM X against golden file
        $display("\n=== Step 3: Verifying SRAM X against golden file ===");
        verify_sramX("../../../py/py_overlap_partition/alm/patch_00_00_over/iter_000/sramX_2.dat");
            
            $display("\n========================================");
        $display("Test Complete");
            $display("========================================");
        
        #1000;
        $finish;
    end

endmodule
