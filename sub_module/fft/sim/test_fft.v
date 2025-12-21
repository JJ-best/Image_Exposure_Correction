`timescale 1ns/1ps

module test_fft();

    // Parameters
    parameter BW_PER_ADDR = 128;  // 64-bit real + 64-bit imag
    parameter ADDR_WIDTH = 6;     // 256 addresses per bank
    parameter TWIDDLE_ADDR_WIDTH = 6;  // 31 twiddle factors

    // Clock and reset
    reg clk;
    reg rst_n;

    // SRAM A signals (for ping-pong) - 16 banks
    wire sramA_csb;
    wire sramA_wsb_0, sramA_wsb_1, sramA_wsb_2, sramA_wsb_3, sramA_wsb_4, sramA_wsb_5, sramA_wsb_6, sramA_wsb_7;
    wire sramA_wsb_8, sramA_wsb_9, sramA_wsb_10, sramA_wsb_11, sramA_wsb_12, sramA_wsb_13, sramA_wsb_14, sramA_wsb_15;
    wire [BW_PER_ADDR-1:0] sramA_wdata_0, sramA_wdata_1, sramA_wdata_2, sramA_wdata_3, sramA_wdata_4, sramA_wdata_5, sramA_wdata_6, sramA_wdata_7;
    wire [BW_PER_ADDR-1:0] sramA_wdata_8, sramA_wdata_9, sramA_wdata_10, sramA_wdata_11, sramA_wdata_12, sramA_wdata_13, sramA_wdata_14, sramA_wdata_15;
    wire [ADDR_WIDTH-1:0] sramA_addr_0, sramA_addr_1, sramA_addr_2, sramA_addr_3, sramA_addr_4, sramA_addr_5, sramA_addr_6, sramA_addr_7;
    wire [ADDR_WIDTH-1:0] sramA_addr_8, sramA_addr_9, sramA_addr_10, sramA_addr_11, sramA_addr_12, sramA_addr_13, sramA_addr_14, sramA_addr_15;
    wire [BW_PER_ADDR-1:0] sramA_rdata_0, sramA_rdata_1, sramA_rdata_2, sramA_rdata_3, sramA_rdata_4, sramA_rdata_5, sramA_rdata_6, sramA_rdata_7;
    wire [BW_PER_ADDR-1:0] sramA_rdata_8, sramA_rdata_9, sramA_rdata_10, sramA_rdata_11, sramA_rdata_12, sramA_rdata_13, sramA_rdata_14, sramA_rdata_15;

    // SRAM B signals (for ping-pong) - 16 banks, shared addr for read/write
    wire sramB_csb;
    wire sramB_wsb_0, sramB_wsb_1, sramB_wsb_2, sramB_wsb_3, sramB_wsb_4, sramB_wsb_5, sramB_wsb_6, sramB_wsb_7;
    wire sramB_wsb_8, sramB_wsb_9, sramB_wsb_10, sramB_wsb_11, sramB_wsb_12, sramB_wsb_13, sramB_wsb_14, sramB_wsb_15;
    wire [BW_PER_ADDR-1:0] sramB_wdata_0, sramB_wdata_1, sramB_wdata_2, sramB_wdata_3, sramB_wdata_4, sramB_wdata_5, sramB_wdata_6, sramB_wdata_7;
    wire [BW_PER_ADDR-1:0] sramB_wdata_8, sramB_wdata_9, sramB_wdata_10, sramB_wdata_11, sramB_wdata_12, sramB_wdata_13, sramB_wdata_14, sramB_wdata_15;
    wire [ADDR_WIDTH-1:0] sramB_addr_0, sramB_addr_1, sramB_addr_2, sramB_addr_3, sramB_addr_4, sramB_addr_5, sramB_addr_6, sramB_addr_7;
    wire [ADDR_WIDTH-1:0] sramB_addr_8, sramB_addr_9, sramB_addr_10, sramB_addr_11, sramB_addr_12, sramB_addr_13, sramB_addr_14, sramB_addr_15;
    wire [BW_PER_ADDR-1:0] sramB_rdata_0, sramB_rdata_1, sramB_rdata_2, sramB_rdata_3, sramB_rdata_4, sramB_rdata_5, sramB_rdata_6, sramB_rdata_7;
    wire [BW_PER_ADDR-1:0] sramB_rdata_8, sramB_rdata_9, sramB_rdata_10, sramB_rdata_11, sramB_rdata_12, sramB_rdata_13, sramB_rdata_14, sramB_rdata_15;

    // FFT module (DUT) output signals - 16 banks
    wire sramA_csb_dut;
    wire sramA_wsb_0_dut, sramA_wsb_1_dut, sramA_wsb_2_dut, sramA_wsb_3_dut, sramA_wsb_4_dut, sramA_wsb_5_dut, sramA_wsb_6_dut, sramA_wsb_7_dut;
    wire sramA_wsb_8_dut, sramA_wsb_9_dut, sramA_wsb_10_dut, sramA_wsb_11_dut, sramA_wsb_12_dut, sramA_wsb_13_dut, sramA_wsb_14_dut, sramA_wsb_15_dut;
    wire [BW_PER_ADDR-1:0] sramA_wdata_0_dut, sramA_wdata_1_dut, sramA_wdata_2_dut, sramA_wdata_3_dut, sramA_wdata_4_dut, sramA_wdata_5_dut, sramA_wdata_6_dut, sramA_wdata_7_dut;
    wire [BW_PER_ADDR-1:0] sramA_wdata_8_dut, sramA_wdata_9_dut, sramA_wdata_10_dut, sramA_wdata_11_dut, sramA_wdata_12_dut, sramA_wdata_13_dut, sramA_wdata_14_dut, sramA_wdata_15_dut;
    wire [ADDR_WIDTH-1:0] sramA_addr_0_dut, sramA_addr_1_dut, sramA_addr_2_dut, sramA_addr_3_dut, sramA_addr_4_dut, sramA_addr_5_dut, sramA_addr_6_dut, sramA_addr_7_dut;
    wire [ADDR_WIDTH-1:0] sramA_addr_8_dut, sramA_addr_9_dut, sramA_addr_10_dut, sramA_addr_11_dut, sramA_addr_12_dut, sramA_addr_13_dut, sramA_addr_14_dut, sramA_addr_15_dut;

    wire sramB_csb_dut;
    wire sramB_wsb_0_dut, sramB_wsb_1_dut, sramB_wsb_2_dut, sramB_wsb_3_dut, sramB_wsb_4_dut, sramB_wsb_5_dut, sramB_wsb_6_dut, sramB_wsb_7_dut;
    wire sramB_wsb_8_dut, sramB_wsb_9_dut, sramB_wsb_10_dut, sramB_wsb_11_dut, sramB_wsb_12_dut, sramB_wsb_13_dut, sramB_wsb_14_dut, sramB_wsb_15_dut;
    wire [BW_PER_ADDR-1:0] sramB_wdata_0_dut, sramB_wdata_1_dut, sramB_wdata_2_dut, sramB_wdata_3_dut, sramB_wdata_4_dut, sramB_wdata_5_dut, sramB_wdata_6_dut, sramB_wdata_7_dut;
    wire [BW_PER_ADDR-1:0] sramB_wdata_8_dut, sramB_wdata_9_dut, sramB_wdata_10_dut, sramB_wdata_11_dut, sramB_wdata_12_dut, sramB_wdata_13_dut, sramB_wdata_14_dut, sramB_wdata_15_dut;
    wire [ADDR_WIDTH-1:0] sramB_addr_0_dut, sramB_addr_1_dut, sramB_addr_2_dut, sramB_addr_3_dut, sramB_addr_4_dut, sramB_addr_5_dut, sramB_addr_6_dut, sramB_addr_7_dut;
    wire [ADDR_WIDTH-1:0] sramB_addr_8_dut, sramB_addr_9_dut, sramB_addr_10_dut, sramB_addr_11_dut, sramB_addr_12_dut, sramB_addr_13_dut, sramB_addr_14_dut, sramB_addr_15_dut;

    // Twiddle ROM signals (16 banks)
    wire [0:0] twiddle_addr_0, twiddle_addr_1, twiddle_addr_2, twiddle_addr_3,
               twiddle_addr_4, twiddle_addr_5, twiddle_addr_6, twiddle_addr_7,
               twiddle_addr_8, twiddle_addr_9, twiddle_addr_10, twiddle_addr_11,
               twiddle_addr_12, twiddle_addr_13, twiddle_addr_14, twiddle_addr_15;
    wire [BW_PER_ADDR-1:0] twiddle_data_0, twiddle_data_1, twiddle_data_2, twiddle_data_3,
                           twiddle_data_4, twiddle_data_5, twiddle_data_6, twiddle_data_7,
                           twiddle_data_8, twiddle_data_9, twiddle_data_10, twiddle_data_11,
                           twiddle_data_12, twiddle_data_13, twiddle_data_14, twiddle_data_15;

    // BPE signals (for butterfly processing element)
    // Note: bpe instances are in fft module, but mul and fp_add are in testbench
    // BPE 0 Mul signals (128-bit: 64-bit real + 64-bit imag)
    wire [127:0] bpe0_mul_in_A;
    wire [127:0] bpe0_mul_in_B;
    wire [1:0]   bpe0_mul_mode;
    wire         bpe0_mul_in_valid;
    wire [127:0] bpe0_mul_result_c;
    wire [127:0] bpe0_mul_result_int;
    wire         bpe0_mul_out_valid;

    // BPE 0 FP_ADD signals (4 instances)
    wire [63:0]  bpe0_fp_add_01_in_A, bpe0_fp_add_01_in_B;
    wire         bpe0_fp_add_01_in_valid;
    wire [63:0]  bpe0_fp_add_01_result;
    wire         bpe0_fp_add_01_out_valid;

    wire [63:0]  bpe0_fp_add_02_in_A, bpe0_fp_add_02_in_B;
    wire         bpe0_fp_add_02_in_valid;
    wire [63:0]  bpe0_fp_add_02_result;
    wire         bpe0_fp_add_02_out_valid;

    wire [63:0]  bpe0_fp_add_11_in_A, bpe0_fp_add_11_in_B;
    wire         bpe0_fp_add_11_in_valid;
    wire [63:0]  bpe0_fp_add_11_result;
    wire         bpe0_fp_add_11_out_valid;

    wire [63:0]  bpe0_fp_add_12_in_A, bpe0_fp_add_12_in_B;
    wire         bpe0_fp_add_12_in_valid;
    wire [63:0]  bpe0_fp_add_12_result;
    wire         bpe0_fp_add_12_out_valid;

    // BPE 1 Mul signals (128-bit: 64-bit real + 64-bit imag)
    wire [127:0] bpe1_mul_in_A;
    wire [127:0] bpe1_mul_in_B;
    wire [1:0]   bpe1_mul_mode;
    wire         bpe1_mul_in_valid;
    wire [127:0] bpe1_mul_result_c;
    wire [127:0] bpe1_mul_result_int;
    wire         bpe1_mul_out_valid;

    // BPE 1 FP_ADD signals (4 instances)
    wire [63:0]  bpe1_fp_add_01_in_A, bpe1_fp_add_01_in_B;
    wire         bpe1_fp_add_01_in_valid;
    wire [63:0]  bpe1_fp_add_01_result;
    wire         bpe1_fp_add_01_out_valid;

    wire [63:0]  bpe1_fp_add_02_in_A, bpe1_fp_add_02_in_B;
    wire         bpe1_fp_add_02_in_valid;
    wire [63:0]  bpe1_fp_add_02_result;
    wire         bpe1_fp_add_02_out_valid;

    wire [63:0]  bpe1_fp_add_11_in_A, bpe1_fp_add_11_in_B;
    wire         bpe1_fp_add_11_in_valid;
    wire [63:0]  bpe1_fp_add_11_result;
    wire         bpe1_fp_add_11_out_valid;

    wire [63:0]  bpe1_fp_add_12_in_A, bpe1_fp_add_12_in_B;
    wire         bpe1_fp_add_12_in_valid;
    wire [63:0]  bpe1_fp_add_12_result;
    wire         bpe1_fp_add_12_out_valid;


    // bpe input FF
    // ===== BPE0 mul pipeline FF =====
    reg [127:0] bpe0_mul_in_A_q;
    reg [127:0] bpe0_mul_in_B_q;
    reg [1:0]   bpe0_mul_mode_q;
    reg         bpe0_mul_in_valid_q;
    // ===== BPE0 fp_add pipeline FF =====
    reg [63:0] bpe0_fp_add_01_in_A_q;
    reg [63:0] bpe0_fp_add_01_in_B_q;
    reg        bpe0_fp_add_01_in_valid_q;

    reg [63:0] bpe0_fp_add_02_in_A_q;
    reg [63:0] bpe0_fp_add_02_in_B_q;
    reg        bpe0_fp_add_02_in_valid_q;

    reg [63:0] bpe0_fp_add_11_in_A_q;
    reg [63:0] bpe0_fp_add_11_in_B_q;
    reg        bpe0_fp_add_11_in_valid_q;

    reg [63:0] bpe0_fp_add_12_in_A_q;
    reg [63:0] bpe0_fp_add_12_in_B_q;
    reg        bpe0_fp_add_12_in_valid_q;
    // ===== BPE1 mul pipeline FF =====
    reg [127:0] bpe1_mul_in_A_q;
    reg [127:0] bpe1_mul_in_B_q;
    reg [1:0]   bpe1_mul_mode_q;
    reg         bpe1_mul_in_valid_q;
    // ===== BPE1 fp_add pipeline FF =====
    reg [63:0] bpe1_fp_add_01_in_A_q;
    reg [63:0] bpe1_fp_add_01_in_B_q;
    reg        bpe1_fp_add_01_in_valid_q;

    reg [63:0] bpe1_fp_add_02_in_A_q;
    reg [63:0] bpe1_fp_add_02_in_B_q;
    reg        bpe1_fp_add_02_in_valid_q;

    reg [63:0] bpe1_fp_add_11_in_A_q;
    reg [63:0] bpe1_fp_add_11_in_B_q;
    reg        bpe1_fp_add_11_in_valid_q;

    reg [63:0] bpe1_fp_add_12_in_A_q;
    reg [63:0] bpe1_fp_add_12_in_B_q;
    reg        bpe1_fp_add_12_in_valid_q;


    // Twiddle ROM address signals from FFT module (16 banks)
    wire [0:0] twiddle_addr_0_dut, twiddle_addr_1_dut, twiddle_addr_2_dut, twiddle_addr_3_dut,
               twiddle_addr_4_dut, twiddle_addr_5_dut, twiddle_addr_6_dut, twiddle_addr_7_dut,
               twiddle_addr_8_dut, twiddle_addr_9_dut, twiddle_addr_10_dut, twiddle_addr_11_dut,
               twiddle_addr_12_dut, twiddle_addr_13_dut, twiddle_addr_14_dut, twiddle_addr_15_dut;

    // FFT control signals
    reg start;
    wire done;
    reg mode;  // 0: FFT, 1: IFFT
    reg fft_started;  // Latch to remember start has occurred

    // Test configuration - can be overridden by +define+ROW_STAGE=X
    `ifdef ROW_STAGE
        parameter ROW_STAGE = `ROW_STAGE;
    `else
        parameter ROW_STAGE = -1;  // Default: no row FFT test (use -1 to skip)
    `endif

    // Test configuration - can be overridden by +define+COL_STAGE=X
    `ifdef COL_STAGE
        parameter COL_STAGE = `COL_STAGE;
    `else
        parameter COL_STAGE = -1;  // Default: no col FFT test (use -1 to skip)
    `endif

    // Mode configuration - can be overridden by +define+MODE=X
    `ifdef MODE
        parameter MODE_PARAM = `MODE;
    `else
        parameter MODE_PARAM = 0;  // Default: FFT mode (0: FFT, 1: IFFT)
    `endif

    // Waveform format configuration - can be overridden by +define+WAVEFORM_FORMAT=X
    `ifdef WAVEFORM_FORMAT
        parameter WAVEFORM_FORMAT = `WAVEFORM_FORMAT;  // 0: VCD, 1: FST
    `else
        parameter WAVEFORM_FORMAT = 0;  // Default: VCD format
    `endif

    // Control signals (for future DUT connection) - 16 banks, shared addr
    reg sramA_csb_reg;
    reg sramA_wsb_0_reg, sramA_wsb_1_reg, sramA_wsb_2_reg, sramA_wsb_3_reg, sramA_wsb_4_reg, sramA_wsb_5_reg, sramA_wsb_6_reg, sramA_wsb_7_reg;
    reg sramA_wsb_8_reg, sramA_wsb_9_reg, sramA_wsb_10_reg, sramA_wsb_11_reg, sramA_wsb_12_reg, sramA_wsb_13_reg, sramA_wsb_14_reg, sramA_wsb_15_reg;
    reg [BW_PER_ADDR-1:0] sramA_wdata_0_reg, sramA_wdata_1_reg, sramA_wdata_2_reg, sramA_wdata_3_reg, sramA_wdata_4_reg, sramA_wdata_5_reg, sramA_wdata_6_reg, sramA_wdata_7_reg;
    reg [BW_PER_ADDR-1:0] sramA_wdata_8_reg, sramA_wdata_9_reg, sramA_wdata_10_reg, sramA_wdata_11_reg, sramA_wdata_12_reg, sramA_wdata_13_reg, sramA_wdata_14_reg, sramA_wdata_15_reg;
    reg [ADDR_WIDTH-1:0] sramA_addr_0_reg, sramA_addr_1_reg, sramA_addr_2_reg, sramA_addr_3_reg, sramA_addr_4_reg, sramA_addr_5_reg, sramA_addr_6_reg, sramA_addr_7_reg;
    reg [ADDR_WIDTH-1:0] sramA_addr_8_reg, sramA_addr_9_reg, sramA_addr_10_reg, sramA_addr_11_reg, sramA_addr_12_reg, sramA_addr_13_reg, sramA_addr_14_reg, sramA_addr_15_reg;

    reg sramB_csb_reg;
    reg sramB_wsb_0_reg, sramB_wsb_1_reg, sramB_wsb_2_reg, sramB_wsb_3_reg, sramB_wsb_4_reg, sramB_wsb_5_reg, sramB_wsb_6_reg, sramB_wsb_7_reg;
    reg sramB_wsb_8_reg, sramB_wsb_9_reg, sramB_wsb_10_reg, sramB_wsb_11_reg, sramB_wsb_12_reg, sramB_wsb_13_reg, sramB_wsb_14_reg, sramB_wsb_15_reg;
    reg [BW_PER_ADDR-1:0] sramB_wdata_0_reg, sramB_wdata_1_reg, sramB_wdata_2_reg, sramB_wdata_3_reg, sramB_wdata_4_reg, sramB_wdata_5_reg, sramB_wdata_6_reg, sramB_wdata_7_reg;
    reg [BW_PER_ADDR-1:0] sramB_wdata_8_reg, sramB_wdata_9_reg, sramB_wdata_10_reg, sramB_wdata_11_reg, sramB_wdata_12_reg, sramB_wdata_13_reg, sramB_wdata_14_reg, sramB_wdata_15_reg;
    reg [ADDR_WIDTH-1:0] sramB_addr_0_reg, sramB_addr_1_reg, sramB_addr_2_reg, sramB_addr_3_reg, sramB_addr_4_reg, sramB_addr_5_reg, sramB_addr_6_reg, sramB_addr_7_reg;
    reg [ADDR_WIDTH-1:0] sramB_addr_8_reg, sramB_addr_9_reg, sramB_addr_10_reg, sramB_addr_11_reg, sramB_addr_12_reg, sramB_addr_13_reg, sramB_addr_14_reg, sramB_addr_15_reg;

    // Twiddle ROM address registers (16 banks) - for initialization
    reg [0:0] twiddle_addr_0_reg, twiddle_addr_1_reg, twiddle_addr_2_reg, twiddle_addr_3_reg,
              twiddle_addr_4_reg, twiddle_addr_5_reg, twiddle_addr_6_reg, twiddle_addr_7_reg,
              twiddle_addr_8_reg, twiddle_addr_9_reg, twiddle_addr_10_reg, twiddle_addr_11_reg,
              twiddle_addr_12_reg, twiddle_addr_13_reg, twiddle_addr_14_reg, twiddle_addr_15_reg;

    // Latch start signal - once start occurs, use FFT module signals
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fft_started <= 1'b0;
        end else begin
            if (start) begin
                fft_started <= 1'b1;
            end
        end
    end

    // Assign control signals - 16 banks
    // Before start: use testbench regs; After start: use FFT module outputs
    assign sramA_csb = fft_started ? sramA_csb_dut : sramA_csb_reg;
    assign sramA_wsb_0 = fft_started ? sramA_wsb_0_dut : sramA_wsb_0_reg; assign sramA_wsb_1 = fft_started ? sramA_wsb_1_dut : sramA_wsb_1_reg; assign sramA_wsb_2 = fft_started ? sramA_wsb_2_dut : sramA_wsb_2_reg; assign sramA_wsb_3 = fft_started ? sramA_wsb_3_dut : sramA_wsb_3_reg;
    assign sramA_wsb_4 = fft_started ? sramA_wsb_4_dut : sramA_wsb_4_reg; assign sramA_wsb_5 = fft_started ? sramA_wsb_5_dut : sramA_wsb_5_reg; assign sramA_wsb_6 = fft_started ? sramA_wsb_6_dut : sramA_wsb_6_reg; assign sramA_wsb_7 = fft_started ? sramA_wsb_7_dut : sramA_wsb_7_reg;
    assign sramA_wsb_8 = fft_started ? sramA_wsb_8_dut : sramA_wsb_8_reg; assign sramA_wsb_9 = fft_started ? sramA_wsb_9_dut : sramA_wsb_9_reg; assign sramA_wsb_10 = fft_started ? sramA_wsb_10_dut : sramA_wsb_10_reg; assign sramA_wsb_11 = fft_started ? sramA_wsb_11_dut : sramA_wsb_11_reg;
    assign sramA_wsb_12 = fft_started ? sramA_wsb_12_dut : sramA_wsb_12_reg; assign sramA_wsb_13 = fft_started ? sramA_wsb_13_dut : sramA_wsb_13_reg; assign sramA_wsb_14 = fft_started ? sramA_wsb_14_dut : sramA_wsb_14_reg; assign sramA_wsb_15 = fft_started ? sramA_wsb_15_dut : sramA_wsb_15_reg;
    assign sramA_wdata_0 = fft_started ? sramA_wdata_0_dut : sramA_wdata_0_reg; assign sramA_wdata_1 = fft_started ? sramA_wdata_1_dut : sramA_wdata_1_reg; assign sramA_wdata_2 = fft_started ? sramA_wdata_2_dut : sramA_wdata_2_reg; assign sramA_wdata_3 = fft_started ? sramA_wdata_3_dut : sramA_wdata_3_reg;
    assign sramA_wdata_4 = fft_started ? sramA_wdata_4_dut : sramA_wdata_4_reg; assign sramA_wdata_5 = fft_started ? sramA_wdata_5_dut : sramA_wdata_5_reg; assign sramA_wdata_6 = fft_started ? sramA_wdata_6_dut : sramA_wdata_6_reg; assign sramA_wdata_7 = fft_started ? sramA_wdata_7_dut : sramA_wdata_7_reg;
    assign sramA_wdata_8 = fft_started ? sramA_wdata_8_dut : sramA_wdata_8_reg; assign sramA_wdata_9 = fft_started ? sramA_wdata_9_dut : sramA_wdata_9_reg; assign sramA_wdata_10 = fft_started ? sramA_wdata_10_dut : sramA_wdata_10_reg; assign sramA_wdata_11 = fft_started ? sramA_wdata_11_dut : sramA_wdata_11_reg;
    assign sramA_wdata_12 = fft_started ? sramA_wdata_12_dut : sramA_wdata_12_reg; assign sramA_wdata_13 = fft_started ? sramA_wdata_13_dut : sramA_wdata_13_reg; assign sramA_wdata_14 = fft_started ? sramA_wdata_14_dut : sramA_wdata_14_reg; assign sramA_wdata_15 = fft_started ? sramA_wdata_15_dut : sramA_wdata_15_reg;
    assign sramA_addr_0 = fft_started ? sramA_addr_0_dut : sramA_addr_0_reg; assign sramA_addr_1 = fft_started ? sramA_addr_1_dut : sramA_addr_1_reg; assign sramA_addr_2 = fft_started ? sramA_addr_2_dut : sramA_addr_2_reg; assign sramA_addr_3 = fft_started ? sramA_addr_3_dut : sramA_addr_3_reg;
    assign sramA_addr_4 = fft_started ? sramA_addr_4_dut : sramA_addr_4_reg; assign sramA_addr_5 = fft_started ? sramA_addr_5_dut : sramA_addr_5_reg; assign sramA_addr_6 = fft_started ? sramA_addr_6_dut : sramA_addr_6_reg; assign sramA_addr_7 = fft_started ? sramA_addr_7_dut : sramA_addr_7_reg;
    assign sramA_addr_8 = fft_started ? sramA_addr_8_dut : sramA_addr_8_reg; assign sramA_addr_9 = fft_started ? sramA_addr_9_dut : sramA_addr_9_reg; assign sramA_addr_10 = fft_started ? sramA_addr_10_dut : sramA_addr_10_reg; assign sramA_addr_11 = fft_started ? sramA_addr_11_dut : sramA_addr_11_reg;
    assign sramA_addr_12 = fft_started ? sramA_addr_12_dut : sramA_addr_12_reg; assign sramA_addr_13 = fft_started ? sramA_addr_13_dut : sramA_addr_13_reg; assign sramA_addr_14 = fft_started ? sramA_addr_14_dut : sramA_addr_14_reg; assign sramA_addr_15 = fft_started ? sramA_addr_15_dut : sramA_addr_15_reg;

    assign sramB_csb = fft_started ? sramB_csb_dut : sramB_csb_reg;
    assign sramB_wsb_0 = fft_started ? sramB_wsb_0_dut : sramB_wsb_0_reg; assign sramB_wsb_1 = fft_started ? sramB_wsb_1_dut : sramB_wsb_1_reg; assign sramB_wsb_2 = fft_started ? sramB_wsb_2_dut : sramB_wsb_2_reg; assign sramB_wsb_3 = fft_started ? sramB_wsb_3_dut : sramB_wsb_3_reg;
    assign sramB_wsb_4 = fft_started ? sramB_wsb_4_dut : sramB_wsb_4_reg; assign sramB_wsb_5 = fft_started ? sramB_wsb_5_dut : sramB_wsb_5_reg; assign sramB_wsb_6 = fft_started ? sramB_wsb_6_dut : sramB_wsb_6_reg; assign sramB_wsb_7 = fft_started ? sramB_wsb_7_dut : sramB_wsb_7_reg;
    assign sramB_wsb_8 = fft_started ? sramB_wsb_8_dut : sramB_wsb_8_reg; assign sramB_wsb_9 = fft_started ? sramB_wsb_9_dut : sramB_wsb_9_reg; assign sramB_wsb_10 = fft_started ? sramB_wsb_10_dut : sramB_wsb_10_reg; assign sramB_wsb_11 = fft_started ? sramB_wsb_11_dut : sramB_wsb_11_reg;
    assign sramB_wsb_12 = fft_started ? sramB_wsb_12_dut : sramB_wsb_12_reg; assign sramB_wsb_13 = fft_started ? sramB_wsb_13_dut : sramB_wsb_13_reg; assign sramB_wsb_14 = fft_started ? sramB_wsb_14_dut : sramB_wsb_14_reg; assign sramB_wsb_15 = fft_started ? sramB_wsb_15_dut : sramB_wsb_15_reg;
    assign sramB_wdata_0 = fft_started ? sramB_wdata_0_dut : sramB_wdata_0_reg; assign sramB_wdata_1 = fft_started ? sramB_wdata_1_dut : sramB_wdata_1_reg; assign sramB_wdata_2 = fft_started ? sramB_wdata_2_dut : sramB_wdata_2_reg; assign sramB_wdata_3 = fft_started ? sramB_wdata_3_dut : sramB_wdata_3_reg;
    assign sramB_wdata_4 = fft_started ? sramB_wdata_4_dut : sramB_wdata_4_reg; assign sramB_wdata_5 = fft_started ? sramB_wdata_5_dut : sramB_wdata_5_reg; assign sramB_wdata_6 = fft_started ? sramB_wdata_6_dut : sramB_wdata_6_reg; assign sramB_wdata_7 = fft_started ? sramB_wdata_7_dut : sramB_wdata_7_reg;
    assign sramB_wdata_8 = fft_started ? sramB_wdata_8_dut : sramB_wdata_8_reg; assign sramB_wdata_9 = fft_started ? sramB_wdata_9_dut : sramB_wdata_9_reg; assign sramB_wdata_10 = fft_started ? sramB_wdata_10_dut : sramB_wdata_10_reg; assign sramB_wdata_11 = fft_started ? sramB_wdata_11_dut : sramB_wdata_11_reg;
    assign sramB_wdata_12 = fft_started ? sramB_wdata_12_dut : sramB_wdata_12_reg; assign sramB_wdata_13 = fft_started ? sramB_wdata_13_dut : sramB_wdata_13_reg; assign sramB_wdata_14 = fft_started ? sramB_wdata_14_dut : sramB_wdata_14_reg; assign sramB_wdata_15 = fft_started ? sramB_wdata_15_dut : sramB_wdata_15_reg;
    assign sramB_addr_0 = fft_started ? sramB_addr_0_dut : sramB_addr_0_reg; assign sramB_addr_1 = fft_started ? sramB_addr_1_dut : sramB_addr_1_reg; assign sramB_addr_2 = fft_started ? sramB_addr_2_dut : sramB_addr_2_reg; assign sramB_addr_3 = fft_started ? sramB_addr_3_dut : sramB_addr_3_reg;
    assign sramB_addr_4 = fft_started ? sramB_addr_4_dut : sramB_addr_4_reg; assign sramB_addr_5 = fft_started ? sramB_addr_5_dut : sramB_addr_5_reg; assign sramB_addr_6 = fft_started ? sramB_addr_6_dut : sramB_addr_6_reg; assign sramB_addr_7 = fft_started ? sramB_addr_7_dut : sramB_addr_7_reg;
    assign sramB_addr_8 = fft_started ? sramB_addr_8_dut : sramB_addr_8_reg; assign sramB_addr_9 = fft_started ? sramB_addr_9_dut : sramB_addr_9_reg; assign sramB_addr_10 = fft_started ? sramB_addr_10_dut : sramB_addr_10_reg; assign sramB_addr_11 = fft_started ? sramB_addr_11_dut : sramB_addr_11_reg;
    assign sramB_addr_12 = fft_started ? sramB_addr_12_dut : sramB_addr_12_reg; assign sramB_addr_13 = fft_started ? sramB_addr_13_dut : sramB_addr_13_reg; assign sramB_addr_14 = fft_started ? sramB_addr_14_dut : sramB_addr_14_reg; assign sramB_addr_15 = fft_started ? sramB_addr_15_dut : sramB_addr_15_reg;

    // Assign twiddle addresses (16 banks)
    assign twiddle_addr_0  = fft_started ? twiddle_addr_0_dut  : twiddle_addr_0_reg;
    assign twiddle_addr_1  = fft_started ? twiddle_addr_1_dut  : twiddle_addr_1_reg;
    assign twiddle_addr_2  = fft_started ? twiddle_addr_2_dut  : twiddle_addr_2_reg;
    assign twiddle_addr_3  = fft_started ? twiddle_addr_3_dut  : twiddle_addr_3_reg;
    assign twiddle_addr_4  = fft_started ? twiddle_addr_4_dut  : twiddle_addr_4_reg;
    assign twiddle_addr_5  = fft_started ? twiddle_addr_5_dut  : twiddle_addr_5_reg;
    assign twiddle_addr_6  = fft_started ? twiddle_addr_6_dut  : twiddle_addr_6_reg;
    assign twiddle_addr_7  = fft_started ? twiddle_addr_7_dut  : twiddle_addr_7_reg;
    assign twiddle_addr_8  = fft_started ? twiddle_addr_8_dut  : twiddle_addr_8_reg;
    assign twiddle_addr_9  = fft_started ? twiddle_addr_9_dut  : twiddle_addr_9_reg;
    assign twiddle_addr_10 = fft_started ? twiddle_addr_10_dut : twiddle_addr_10_reg;
    assign twiddle_addr_11 = fft_started ? twiddle_addr_11_dut : twiddle_addr_11_reg;
    assign twiddle_addr_12 = fft_started ? twiddle_addr_12_dut : twiddle_addr_12_reg;
    assign twiddle_addr_13 = fft_started ? twiddle_addr_13_dut : twiddle_addr_13_reg;
    assign twiddle_addr_14 = fft_started ? twiddle_addr_14_dut : twiddle_addr_14_reg;
    assign twiddle_addr_15 = fft_started ? twiddle_addr_15_dut : twiddle_addr_15_reg;

    // Initialize control signals - 16 banks
    initial begin
        sramA_csb_reg = 1'b1;  // disabled
        sramA_wsb_0_reg = 1'b1; sramA_wsb_1_reg = 1'b1; sramA_wsb_2_reg = 1'b1; sramA_wsb_3_reg = 1'b1;
        sramA_wsb_4_reg = 1'b1; sramA_wsb_5_reg = 1'b1; sramA_wsb_6_reg = 1'b1; sramA_wsb_7_reg = 1'b1;
        sramA_wsb_8_reg = 1'b1; sramA_wsb_9_reg = 1'b1; sramA_wsb_10_reg = 1'b1; sramA_wsb_11_reg = 1'b1;
        sramA_wsb_12_reg = 1'b1; sramA_wsb_13_reg = 1'b1; sramA_wsb_14_reg = 1'b1; sramA_wsb_15_reg = 1'b1;
        sramA_wdata_0_reg = 0; sramA_wdata_1_reg = 0; sramA_wdata_2_reg = 0; sramA_wdata_3_reg = 0;
        sramA_wdata_4_reg = 0; sramA_wdata_5_reg = 0; sramA_wdata_6_reg = 0; sramA_wdata_7_reg = 0;
        sramA_wdata_8_reg = 0; sramA_wdata_9_reg = 0; sramA_wdata_10_reg = 0; sramA_wdata_11_reg = 0;
        sramA_wdata_12_reg = 0; sramA_wdata_13_reg = 0; sramA_wdata_14_reg = 0; sramA_wdata_15_reg = 0;
        sramA_addr_0_reg = 0; sramA_addr_1_reg = 0; sramA_addr_2_reg = 0; sramA_addr_3_reg = 0;
        sramA_addr_4_reg = 0; sramA_addr_5_reg = 0; sramA_addr_6_reg = 0; sramA_addr_7_reg = 0;
        sramA_addr_8_reg = 0; sramA_addr_9_reg = 0; sramA_addr_10_reg = 0; sramA_addr_11_reg = 0;
        sramA_addr_12_reg = 0; sramA_addr_13_reg = 0; sramA_addr_14_reg = 0; sramA_addr_15_reg = 0;

        sramB_csb_reg = 1'b1;
        sramB_wsb_0_reg = 1'b1; sramB_wsb_1_reg = 1'b1; sramB_wsb_2_reg = 1'b1; sramB_wsb_3_reg = 1'b1;
        sramB_wsb_4_reg = 1'b1; sramB_wsb_5_reg = 1'b1; sramB_wsb_6_reg = 1'b1; sramB_wsb_7_reg = 1'b1;
        sramB_wsb_8_reg = 1'b1; sramB_wsb_9_reg = 1'b1; sramB_wsb_10_reg = 1'b1; sramB_wsb_11_reg = 1'b1;
        sramB_wsb_12_reg = 1'b1; sramB_wsb_13_reg = 1'b1; sramB_wsb_14_reg = 1'b1; sramB_wsb_15_reg = 1'b1;
        sramB_wdata_0_reg = 0; sramB_wdata_1_reg = 0; sramB_wdata_2_reg = 0; sramB_wdata_3_reg = 0;
        sramB_wdata_4_reg = 0; sramB_wdata_5_reg = 0; sramB_wdata_6_reg = 0; sramB_wdata_7_reg = 0;
        sramB_wdata_8_reg = 0; sramB_wdata_9_reg = 0; sramB_wdata_10_reg = 0; sramB_wdata_11_reg = 0;
        sramB_wdata_12_reg = 0; sramB_wdata_13_reg = 0; sramB_wdata_14_reg = 0; sramB_wdata_15_reg = 0;
        sramB_addr_0_reg = 0; sramB_addr_1_reg = 0; sramB_addr_2_reg = 0; sramB_addr_3_reg = 0;
        sramB_addr_4_reg = 0; sramB_addr_5_reg = 0; sramB_addr_6_reg = 0; sramB_addr_7_reg = 0;
        sramB_addr_8_reg = 0; sramB_addr_9_reg = 0; sramB_addr_10_reg = 0; sramB_addr_11_reg = 0;
        sramB_addr_12_reg = 0; sramB_addr_13_reg = 0; sramB_addr_14_reg = 0; sramB_addr_15_reg = 0;

        twiddle_addr_0_reg = 0; twiddle_addr_1_reg = 0; twiddle_addr_2_reg = 0; twiddle_addr_3_reg = 0;
        twiddle_addr_4_reg = 0; twiddle_addr_5_reg = 0; twiddle_addr_6_reg = 0; twiddle_addr_7_reg = 0;
        twiddle_addr_8_reg = 0; twiddle_addr_9_reg = 0; twiddle_addr_10_reg = 0; twiddle_addr_11_reg = 0;
        twiddle_addr_12_reg = 0; twiddle_addr_13_reg = 0; twiddle_addr_14_reg = 0; twiddle_addr_15_reg = 0;
        start = 0;
        mode = MODE_PARAM;  // Initialize mode: 0 for FFT, 1 for IFFT
        fft_started = 0;
    end

    // Dump waveform file (VCD or FST format)
    initial begin
        if (WAVEFORM_FORMAT == 1) begin
            $dumpfile("fft_sim.fst");
            $dumpvars(0, test_fft);
        end else begin
            $dumpfile("fft_sim.vcd");
            $dumpvars(0, test_fft);
        end
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #1 clk = ~clk;  // 100MHz
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
    end

// ===== need further integrate to top ==== //
    // Instantiate SRAM A (in testbench) - 16 banks
    sram_256x8b #(
        .BW_PER_ADDR(BW_PER_ADDR),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_sramA (
        .clk(clk),
        .csb(1'b0),  // Use testbench csb signal (controlled by FFT module or testbench)
        .wsb_0(sramA_wsb_0), .wsb_1(sramA_wsb_1), .wsb_2(sramA_wsb_2), .wsb_3(sramA_wsb_3),
        .wsb_4(sramA_wsb_4), .wsb_5(sramA_wsb_5), .wsb_6(sramA_wsb_6), .wsb_7(sramA_wsb_7),
        .wsb_8(sramA_wsb_8), .wsb_9(sramA_wsb_9), .wsb_10(sramA_wsb_10), .wsb_11(sramA_wsb_11),
        .wsb_12(sramA_wsb_12), .wsb_13(sramA_wsb_13), .wsb_14(sramA_wsb_14), .wsb_15(sramA_wsb_15),
        .wdata_0(sramA_wdata_0), .wdata_1(sramA_wdata_1), .wdata_2(sramA_wdata_2), .wdata_3(sramA_wdata_3),
        .wdata_4(sramA_wdata_4), .wdata_5(sramA_wdata_5), .wdata_6(sramA_wdata_6), .wdata_7(sramA_wdata_7),
        .wdata_8(sramA_wdata_8), .wdata_9(sramA_wdata_9), .wdata_10(sramA_wdata_10), .wdata_11(sramA_wdata_11),
        .wdata_12(sramA_wdata_12), .wdata_13(sramA_wdata_13), .wdata_14(sramA_wdata_14), .wdata_15(sramA_wdata_15),
        .addr_0(sramA_addr_0), .addr_1(sramA_addr_1), .addr_2(sramA_addr_2), .addr_3(sramA_addr_3),
        .addr_4(sramA_addr_4), .addr_5(sramA_addr_5), .addr_6(sramA_addr_6), .addr_7(sramA_addr_7),
        .addr_8(sramA_addr_8), .addr_9(sramA_addr_9), .addr_10(sramA_addr_10), .addr_11(sramA_addr_11),
        .addr_12(sramA_addr_12), .addr_13(sramA_addr_13), .addr_14(sramA_addr_14), .addr_15(sramA_addr_15),
        .rdata_0(sramA_rdata_0), .rdata_1(sramA_rdata_1), .rdata_2(sramA_rdata_2), .rdata_3(sramA_rdata_3),
        .rdata_4(sramA_rdata_4), .rdata_5(sramA_rdata_5), .rdata_6(sramA_rdata_6), .rdata_7(sramA_rdata_7),
        .rdata_8(sramA_rdata_8), .rdata_9(sramA_rdata_9), .rdata_10(sramA_rdata_10), .rdata_11(sramA_rdata_11),
        .rdata_12(sramA_rdata_12), .rdata_13(sramA_rdata_13), .rdata_14(sramA_rdata_14), .rdata_15(sramA_rdata_15)
    );

    // Instantiate SRAM B (in testbench) - 16 banks
    sram_256x8b #(
        .BW_PER_ADDR(BW_PER_ADDR),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_sramB (
        .clk(clk),
        .csb(1'b0),  // Use testbench csb signal (controlled by FFT module or testbench)
        .wsb_0(sramB_wsb_0), .wsb_1(sramB_wsb_1), .wsb_2(sramB_wsb_2), .wsb_3(sramB_wsb_3),
        .wsb_4(sramB_wsb_4), .wsb_5(sramB_wsb_5), .wsb_6(sramB_wsb_6), .wsb_7(sramB_wsb_7),
        .wsb_8(sramB_wsb_8), .wsb_9(sramB_wsb_9), .wsb_10(sramB_wsb_10), .wsb_11(sramB_wsb_11),
        .wsb_12(sramB_wsb_12), .wsb_13(sramB_wsb_13), .wsb_14(sramB_wsb_14), .wsb_15(sramB_wsb_15),
        .wdata_0(sramB_wdata_0), .wdata_1(sramB_wdata_1), .wdata_2(sramB_wdata_2), .wdata_3(sramB_wdata_3),
        .wdata_4(sramB_wdata_4), .wdata_5(sramB_wdata_5), .wdata_6(sramB_wdata_6), .wdata_7(sramB_wdata_7),
        .wdata_8(sramB_wdata_8), .wdata_9(sramB_wdata_9), .wdata_10(sramB_wdata_10), .wdata_11(sramB_wdata_11),
        .wdata_12(sramB_wdata_12), .wdata_13(sramB_wdata_13), .wdata_14(sramB_wdata_14), .wdata_15(sramB_wdata_15),
        .addr_0(sramB_addr_0), .addr_1(sramB_addr_1), .addr_2(sramB_addr_2), .addr_3(sramB_addr_3),
        .addr_4(sramB_addr_4), .addr_5(sramB_addr_5), .addr_6(sramB_addr_6), .addr_7(sramB_addr_7),
        .addr_8(sramB_addr_8), .addr_9(sramB_addr_9), .addr_10(sramB_addr_10), .addr_11(sramB_addr_11),
        .addr_12(sramB_addr_12), .addr_13(sramB_addr_13), .addr_14(sramB_addr_14), .addr_15(sramB_addr_15),
        .rdata_0(sramB_rdata_0), .rdata_1(sramB_rdata_1), .rdata_2(sramB_rdata_2), .rdata_3(sramB_rdata_3),
        .rdata_4(sramB_rdata_4), .rdata_5(sramB_rdata_5), .rdata_6(sramB_rdata_6), .rdata_7(sramB_rdata_7),
        .rdata_8(sramB_rdata_8), .rdata_9(sramB_rdata_9), .rdata_10(sramB_rdata_10), .rdata_11(sramB_rdata_11),
        .rdata_12(sramB_rdata_12), .rdata_13(sramB_rdata_13), .rdata_14(sramB_rdata_14), .rdata_15(sramB_rdata_15)
    );

    // Instantiate Twiddle ROM (16 banks)
    twiddle_rom #(
        .DATA_WIDTH(BW_PER_ADDR),
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
    

    // Instantiate FFT module (DUT) - 16 banks
    fft #(
        .BW_PER_ADDR(BW_PER_ADDR),
        .ADDR_WIDTH(ADDR_WIDTH),
        .TWIDDLE_ADDR_WIDTH(TWIDDLE_ADDR_WIDTH)
    ) u_fft (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .sramA_csb(sramA_csb_dut),
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
        .sramA_rdata_0(sramA_rdata_0), .sramA_rdata_1(sramA_rdata_1), .sramA_rdata_2(sramA_rdata_2), .sramA_rdata_3(sramA_rdata_3),
        .sramA_rdata_4(sramA_rdata_4), .sramA_rdata_5(sramA_rdata_5), .sramA_rdata_6(sramA_rdata_6), .sramA_rdata_7(sramA_rdata_7),
        .sramA_rdata_8(sramA_rdata_8), .sramA_rdata_9(sramA_rdata_9), .sramA_rdata_10(sramA_rdata_10), .sramA_rdata_11(sramA_rdata_11),
        .sramA_rdata_12(sramA_rdata_12), .sramA_rdata_13(sramA_rdata_13), .sramA_rdata_14(sramA_rdata_14), .sramA_rdata_15(sramA_rdata_15),
        .sramB_csb(sramB_csb_dut),
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
        .sramB_rdata_0(sramB_rdata_0), .sramB_rdata_1(sramB_rdata_1), .sramB_rdata_2(sramB_rdata_2), .sramB_rdata_3(sramB_rdata_3),
        .sramB_rdata_4(sramB_rdata_4), .sramB_rdata_5(sramB_rdata_5), .sramB_rdata_6(sramB_rdata_6), .sramB_rdata_7(sramB_rdata_7),
        .sramB_rdata_8(sramB_rdata_8), .sramB_rdata_9(sramB_rdata_9), .sramB_rdata_10(sramB_rdata_10), .sramB_rdata_11(sramB_rdata_11),
        .sramB_rdata_12(sramB_rdata_12), .sramB_rdata_13(sramB_rdata_13), .sramB_rdata_14(sramB_rdata_14), .sramB_rdata_15(sramB_rdata_15),
        .twiddle_addr_0(twiddle_addr_0_dut), .twiddle_addr_1(twiddle_addr_1_dut), .twiddle_addr_2(twiddle_addr_2_dut), .twiddle_addr_3(twiddle_addr_3_dut),
        .twiddle_addr_4(twiddle_addr_4_dut), .twiddle_addr_5(twiddle_addr_5_dut), .twiddle_addr_6(twiddle_addr_6_dut), .twiddle_addr_7(twiddle_addr_7_dut),
        .twiddle_addr_8(twiddle_addr_8_dut), .twiddle_addr_9(twiddle_addr_9_dut), .twiddle_addr_10(twiddle_addr_10_dut), .twiddle_addr_11(twiddle_addr_11_dut),
        .twiddle_addr_12(twiddle_addr_12_dut), .twiddle_addr_13(twiddle_addr_13_dut), .twiddle_addr_14(twiddle_addr_14_dut), .twiddle_addr_15(twiddle_addr_15_dut),
        .twiddle_data_0(twiddle_data_0), .twiddle_data_1(twiddle_data_1), .twiddle_data_2(twiddle_data_2), .twiddle_data_3(twiddle_data_3),
        .twiddle_data_4(twiddle_data_4), .twiddle_data_5(twiddle_data_5), .twiddle_data_6(twiddle_data_6), .twiddle_data_7(twiddle_data_7),
        .twiddle_data_8(twiddle_data_8), .twiddle_data_9(twiddle_data_9), .twiddle_data_10(twiddle_data_10), .twiddle_data_11(twiddle_data_11),
        .twiddle_data_12(twiddle_data_12), .twiddle_data_13(twiddle_data_13), .twiddle_data_14(twiddle_data_14), .twiddle_data_15(twiddle_data_15),
        .start(start),
        .done(done),
        // BPE 0 mul interface
        .bpe0_mul_in_A(bpe0_mul_in_A),
        .bpe0_mul_in_B(bpe0_mul_in_B),
        .bpe0_mul_mode(bpe0_mul_mode),
        .bpe0_mul_in_valid(bpe0_mul_in_valid),
        .bpe0_mul_result_c(bpe0_mul_result_c),
        .bpe0_mul_result_int(bpe0_mul_result_int),
        .bpe0_mul_out_valid(bpe0_mul_out_valid),
        // BPE 0 fp_add interfaces
        .bpe0_fp_add_01_in_A(bpe0_fp_add_01_in_A),
        .bpe0_fp_add_01_in_B(bpe0_fp_add_01_in_B),
        .bpe0_fp_add_01_in_valid(bpe0_fp_add_01_in_valid),
        .bpe0_fp_add_01_result(bpe0_fp_add_01_result),
        .bpe0_fp_add_01_out_valid(bpe0_fp_add_01_out_valid),
        .bpe0_fp_add_02_in_A(bpe0_fp_add_02_in_A),
        .bpe0_fp_add_02_in_B(bpe0_fp_add_02_in_B),
        .bpe0_fp_add_02_in_valid(bpe0_fp_add_02_in_valid),
        .bpe0_fp_add_02_result(bpe0_fp_add_02_result),
        .bpe0_fp_add_02_out_valid(bpe0_fp_add_02_out_valid),
        .bpe0_fp_add_11_in_A(bpe0_fp_add_11_in_A),
        .bpe0_fp_add_11_in_B(bpe0_fp_add_11_in_B),
        .bpe0_fp_add_11_in_valid(bpe0_fp_add_11_in_valid),
        .bpe0_fp_add_11_result(bpe0_fp_add_11_result),
        .bpe0_fp_add_11_out_valid(bpe0_fp_add_11_out_valid),
        .bpe0_fp_add_12_in_A(bpe0_fp_add_12_in_A),
        .bpe0_fp_add_12_in_B(bpe0_fp_add_12_in_B),
        .bpe0_fp_add_12_in_valid(bpe0_fp_add_12_in_valid),
        .bpe0_fp_add_12_result(bpe0_fp_add_12_result),
        .bpe0_fp_add_12_out_valid(bpe0_fp_add_12_out_valid),
        // BPE 1 mul interface
        .bpe1_mul_in_A(bpe1_mul_in_A),
        .bpe1_mul_in_B(bpe1_mul_in_B),
        .bpe1_mul_mode(bpe1_mul_mode),
        .bpe1_mul_in_valid(bpe1_mul_in_valid),
        .bpe1_mul_result_c(bpe1_mul_result_c),
        .bpe1_mul_result_int(bpe1_mul_result_int),
        .bpe1_mul_out_valid(bpe1_mul_out_valid),
        // BPE 1 fp_add interfaces
        .bpe1_fp_add_01_in_A(bpe1_fp_add_01_in_A),
        .bpe1_fp_add_01_in_B(bpe1_fp_add_01_in_B),
        .bpe1_fp_add_01_in_valid(bpe1_fp_add_01_in_valid),
        .bpe1_fp_add_01_result(bpe1_fp_add_01_result),
        .bpe1_fp_add_01_out_valid(bpe1_fp_add_01_out_valid),
        .bpe1_fp_add_02_in_A(bpe1_fp_add_02_in_A),
        .bpe1_fp_add_02_in_B(bpe1_fp_add_02_in_B),
        .bpe1_fp_add_02_in_valid(bpe1_fp_add_02_in_valid),
        .bpe1_fp_add_02_result(bpe1_fp_add_02_result),
        .bpe1_fp_add_02_out_valid(bpe1_fp_add_02_out_valid),
        .bpe1_fp_add_11_in_A(bpe1_fp_add_11_in_A),
        .bpe1_fp_add_11_in_B(bpe1_fp_add_11_in_B),
        .bpe1_fp_add_11_in_valid(bpe1_fp_add_11_in_valid),
        .bpe1_fp_add_11_result(bpe1_fp_add_11_result),
        .bpe1_fp_add_11_out_valid(bpe1_fp_add_11_out_valid),
        .bpe1_fp_add_12_in_A(bpe1_fp_add_12_in_A),
        .bpe1_fp_add_12_in_B(bpe1_fp_add_12_in_B),
        .bpe1_fp_add_12_in_valid(bpe1_fp_add_12_in_valid),
        .bpe1_fp_add_12_result(bpe1_fp_add_12_result),
        .bpe1_fp_add_12_out_valid(bpe1_fp_add_12_out_valid)
    );

    // ===== FFT -> BPE pipeline FF =====
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // ---------- BPE0 mul ----------
        bpe0_mul_in_A_q       <= 128'd0;
        bpe0_mul_in_B_q       <= 128'd0;
        bpe0_mul_mode_q       <= 2'd0;
        bpe0_mul_in_valid_q   <= 1'b0;

        // ---------- BPE0 fp_add ----------
        bpe0_fp_add_01_in_A_q     <= 64'd0;
        bpe0_fp_add_01_in_B_q     <= 64'd0;
        bpe0_fp_add_01_in_valid_q <= 1'b0;

        bpe0_fp_add_02_in_A_q     <= 64'd0;
        bpe0_fp_add_02_in_B_q     <= 64'd0;
        bpe0_fp_add_02_in_valid_q <= 1'b0;

        bpe0_fp_add_11_in_A_q     <= 64'd0;
        bpe0_fp_add_11_in_B_q     <= 64'd0;
        bpe0_fp_add_11_in_valid_q <= 1'b0;

        bpe0_fp_add_12_in_A_q     <= 64'd0;
        bpe0_fp_add_12_in_B_q     <= 64'd0;
        bpe0_fp_add_12_in_valid_q <= 1'b0;

        // ---------- BPE1 mul ----------
        bpe1_mul_in_A_q       <= 128'd0;
        bpe1_mul_in_B_q       <= 128'd0;
        bpe1_mul_mode_q       <= 2'd0;
        bpe1_mul_in_valid_q   <= 1'b0;

        // ---------- BPE1 fp_add ----------
        bpe1_fp_add_01_in_A_q     <= 64'd0;
        bpe1_fp_add_01_in_B_q     <= 64'd0;
        bpe1_fp_add_01_in_valid_q <= 1'b0;

        bpe1_fp_add_02_in_A_q     <= 64'd0;
        bpe1_fp_add_02_in_B_q     <= 64'd0;
        bpe1_fp_add_02_in_valid_q <= 1'b0;

        bpe1_fp_add_11_in_A_q     <= 64'd0;
        bpe1_fp_add_11_in_B_q     <= 64'd0;
        bpe1_fp_add_11_in_valid_q <= 1'b0;

        bpe1_fp_add_12_in_A_q     <= 64'd0;
        bpe1_fp_add_12_in_B_q     <= 64'd0;
        bpe1_fp_add_12_in_valid_q <= 1'b0;

    end else begin
        // ---------- BPE0 mul ----------
        bpe0_mul_in_A_q       <= bpe0_mul_in_A;
        bpe0_mul_in_B_q       <= bpe0_mul_in_B;
        bpe0_mul_mode_q       <= bpe0_mul_mode;
        bpe0_mul_in_valid_q   <= bpe0_mul_in_valid;

        // ---------- BPE0 fp_add ----------
        bpe0_fp_add_01_in_A_q     <= bpe0_fp_add_01_in_A;
        bpe0_fp_add_01_in_B_q     <= bpe0_fp_add_01_in_B;
        bpe0_fp_add_01_in_valid_q <= bpe0_fp_add_01_in_valid;

        bpe0_fp_add_02_in_A_q     <= bpe0_fp_add_02_in_A;
        bpe0_fp_add_02_in_B_q     <= bpe0_fp_add_02_in_B;
        bpe0_fp_add_02_in_valid_q <= bpe0_fp_add_02_in_valid;

        bpe0_fp_add_11_in_A_q     <= bpe0_fp_add_11_in_A;
        bpe0_fp_add_11_in_B_q     <= bpe0_fp_add_11_in_B;
        bpe0_fp_add_11_in_valid_q <= bpe0_fp_add_11_in_valid;

        bpe0_fp_add_12_in_A_q     <= bpe0_fp_add_12_in_A;
        bpe0_fp_add_12_in_B_q     <= bpe0_fp_add_12_in_B;
        bpe0_fp_add_12_in_valid_q <= bpe0_fp_add_12_in_valid;

        // ---------- BPE1 mul ----------
        bpe1_mul_in_A_q       <= bpe1_mul_in_A;
        bpe1_mul_in_B_q       <= bpe1_mul_in_B;
        bpe1_mul_mode_q       <= bpe1_mul_mode;
        bpe1_mul_in_valid_q   <= bpe1_mul_in_valid;

        // ---------- BPE1 fp_add ----------
        bpe1_fp_add_01_in_A_q     <= bpe1_fp_add_01_in_A;
        bpe1_fp_add_01_in_B_q     <= bpe1_fp_add_01_in_B;
        bpe1_fp_add_01_in_valid_q <= bpe1_fp_add_01_in_valid;

        bpe1_fp_add_02_in_A_q     <= bpe1_fp_add_02_in_A;
        bpe1_fp_add_02_in_B_q     <= bpe1_fp_add_02_in_B;
        bpe1_fp_add_02_in_valid_q <= bpe1_fp_add_02_in_valid;

        bpe1_fp_add_11_in_A_q     <= bpe1_fp_add_11_in_A;
        bpe1_fp_add_11_in_B_q     <= bpe1_fp_add_11_in_B;
        bpe1_fp_add_11_in_valid_q <= bpe1_fp_add_11_in_valid;

        bpe1_fp_add_12_in_A_q     <= bpe1_fp_add_12_in_A;
        bpe1_fp_add_12_in_B_q     <= bpe1_fp_add_12_in_B;
        bpe1_fp_add_12_in_valid_q <= bpe1_fp_add_12_in_valid;
    end
end


    // Mul instances (one per bpe, total 2)
    mul u_mul_bpe0 (
        .in_A      (bpe0_mul_in_A_q),
        .in_B      (bpe0_mul_in_B_q),
        .mode      (bpe0_mul_mode_q),
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (bpe0_mul_in_valid_q),
        .result_c  (bpe0_mul_result_c),
        .result_int(bpe0_mul_result_int),
        .out_valid (bpe0_mul_out_valid)
    );


    mul u_mul_bpe1 (
        .in_A      (bpe1_mul_in_A_q),
        .in_B      (bpe1_mul_in_B_q),
        .mode      (bpe1_mul_mode_q),
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (bpe1_mul_in_valid_q),
        .result_c  (bpe1_mul_result_c),
        .result_int(bpe1_mul_result_int),
        .out_valid (bpe1_mul_out_valid)
    );

    // FP_ADD instances (4 per bpe, total 8)
    // BPE 0 fp_add instances
    fp_add u_fp_add_bpe0_01 (
        .in_A     (bpe0_fp_add_01_in_A_q),
        .in_B     (bpe0_fp_add_01_in_B_q),
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (bpe0_fp_add_01_in_valid_q),
        .result   (bpe0_fp_add_01_result),
        .out_valid(bpe0_fp_add_01_out_valid)
    );

    fp_add u_fp_add_bpe0_02 (
        .in_A     (bpe0_fp_add_02_in_A_q),
        .in_B     (bpe0_fp_add_02_in_B_q),
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (bpe0_fp_add_02_in_valid_q),
        .result   (bpe0_fp_add_02_result),
        .out_valid(bpe0_fp_add_02_out_valid)
    );

    fp_add u_fp_add_bpe0_11 (
        .in_A     (bpe0_fp_add_11_in_A_q),
        .in_B     (bpe0_fp_add_11_in_B_q),
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (bpe0_fp_add_11_in_valid_q),
        .result   (bpe0_fp_add_11_result),
        .out_valid(bpe0_fp_add_11_out_valid)
    );

    fp_add u_fp_add_bpe0_12 (
        .in_A     (bpe0_fp_add_12_in_A_q),
        .in_B     (bpe0_fp_add_12_in_B_q),
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (bpe0_fp_add_12_in_valid_q),
        .result   (bpe0_fp_add_12_result),
        .out_valid(bpe0_fp_add_12_out_valid)
    );

    fp_add u_fp_add_bpe1_01 (
        .in_A     (bpe1_fp_add_01_in_A_q),
        .in_B     (bpe1_fp_add_01_in_B_q),
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (bpe1_fp_add_01_in_valid_q),
        .result   (bpe1_fp_add_01_result),
        .out_valid(bpe1_fp_add_01_out_valid)
    );

    fp_add u_fp_add_bpe1_02 (
        .in_A     (bpe1_fp_add_02_in_A_q),
        .in_B     (bpe1_fp_add_02_in_B_q),
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (bpe1_fp_add_02_in_valid_q),
        .result   (bpe1_fp_add_02_result),
        .out_valid(bpe1_fp_add_02_out_valid)
    );

    fp_add u_fp_add_bpe1_11 (
        .in_A     (bpe1_fp_add_11_in_A_q),
        .in_B     (bpe1_fp_add_11_in_B_q),
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (bpe1_fp_add_11_in_valid_q),
        .result   (bpe1_fp_add_11_result),
        .out_valid(bpe1_fp_add_11_out_valid)
    );

    fp_add u_fp_add_bpe1_12 (
        .in_A     (bpe1_fp_add_12_in_A_q),
        .in_B     (bpe1_fp_add_12_in_B_q),
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (bpe1_fp_add_12_in_valid_q),
        .result   (bpe1_fp_add_12_result),
        .out_valid(bpe1_fp_add_12_out_valid)
    );



// ===== need further integrate to top ==== //




    // Task: Verify SRAM data against golden hex file
    task verify_sram_against_hex;
        input [256*8-1:0] golden_hex_filename;
        input sram_select;  // 0 for SRAM A, 1 for SRAM B
        
        integer file_in;
        integer row, col, addr, bank;
        integer line_count;
        reg [63:0] golden_real_hex, golden_imag_hex;
        reg [63:0] sram_real_hex, sram_imag_hex;
        reg [127:0] golden_data;
        reg [127:0] sram_data;
        integer error_count;
        integer i;
        reg stop_loop;
        reg real_match, imag_match;
        real golden_real_val, golden_imag_val;
        real sram_real_val, sram_imag_val;
        real diff_real, diff_imag;
        real diff_real_abs, diff_imag_abs;
        real epsilon;
        
    begin
        $display("Verifying SRAM %s against golden file: %s", sram_select ? "B" : "A", golden_hex_filename);
        
        file_in = $fopen(golden_hex_filename, "r");
        if (file_in == 0) begin
            $display("ERROR: Cannot open golden file %s", golden_hex_filename);
            stop_loop = 1;
        end
        
        error_count = 0;
        line_count = 0;
        stop_loop = 0;
        epsilon = 1.0e-10;  // Small tolerance for floating point comparison
        
        // Read golden file and compare
        if (!stop_loop) begin
        while (!$feof(file_in) && !stop_loop) begin
            if ($fscanf(file_in, "%h %h", golden_real_hex, golden_imag_hex) == 2) begin
                golden_data = {golden_real_hex, golden_imag_hex};
                
                // Calculate row and col
                row = line_count / 32;
                col = line_count % 32;
                // New mapping: 16 pixels per address, 16 banks
                // addr = row * 2 + (col / 16), bank = col % 16
                addr = row * 2 + (col / 16);
                bank = col % 16;
                
                // Read from SRAM (direct memory access for verification)
                if (sram_select == 0) begin  // SRAM A
                    case(bank)
                        0: sram_data = u_sramA.bank0[addr];
                        1: sram_data = u_sramA.bank1[addr];
                        2: sram_data = u_sramA.bank2[addr];
                        3: sram_data = u_sramA.bank3[addr];
                        4: sram_data = u_sramA.bank4[addr];
                        5: sram_data = u_sramA.bank5[addr];
                        6: sram_data = u_sramA.bank6[addr];
                        7: sram_data = u_sramA.bank7[addr];
                        8: sram_data = u_sramA.bank8[addr];
                        9: sram_data = u_sramA.bank9[addr];
                        10: sram_data = u_sramA.bank10[addr];
                        11: sram_data = u_sramA.bank11[addr];
                        12: sram_data = u_sramA.bank12[addr];
                        13: sram_data = u_sramA.bank13[addr];
                        14: sram_data = u_sramA.bank14[addr];
                        15: sram_data = u_sramA.bank15[addr];
                    endcase
                end else begin  // SRAM B
                    case(bank)
                        0: sram_data = u_sramB.bank0[addr];
                        1: sram_data = u_sramB.bank1[addr];
                        2: sram_data = u_sramB.bank2[addr];
                        3: sram_data = u_sramB.bank3[addr];
                        4: sram_data = u_sramB.bank4[addr];
                        5: sram_data = u_sramB.bank5[addr];
                        6: sram_data = u_sramB.bank6[addr];
                        7: sram_data = u_sramB.bank7[addr];
                        8: sram_data = u_sramB.bank8[addr];
                        9: sram_data = u_sramB.bank9[addr];
                        10: sram_data = u_sramB.bank10[addr];
                        11: sram_data = u_sramB.bank11[addr];
                        12: sram_data = u_sramB.bank12[addr];
                        13: sram_data = u_sramB.bank13[addr];
                        14: sram_data = u_sramB.bank14[addr];
                        15: sram_data = u_sramB.bank15[addr];
                    endcase
                end
                
                // Extract real and imaginary parts (64-bit each)
                sram_real_hex = sram_data[127:64];  // High 64 bits: real part
                sram_imag_hex = sram_data[63:0];    // Low 64 bits: imaginary part
                
                // Convert hex to real values (IEEE 754 double precision)
                golden_real_val = $bitstoreal(golden_real_hex);
                golden_imag_val = $bitstoreal(golden_imag_hex);
                sram_real_val = $bitstoreal(sram_real_hex);
                sram_imag_val = $bitstoreal(sram_imag_hex);
                
                // Calculate differences
                diff_real = sram_real_val - golden_real_val;
                diff_imag = sram_imag_val - golden_imag_val;
                diff_real_abs = (diff_real >= 0) ? diff_real : -diff_real;
                diff_imag_abs = (diff_imag >= 0) ? diff_imag : -diff_imag;
                
                // Compare real and imaginary parts using floating point comparison
                real_match = (diff_real_abs < epsilon);
                imag_match = (diff_imag_abs < epsilon);
                
                // Compare and print all results
                if (!real_match || !imag_match) begin
                    $display("ERROR at row=%0d, col=%0d (addr=%0d, bank=%0d):", row, col, addr, bank);
                    $display("  Real: Expected 0x%h (%.6f), Got 0x%h (%.6f), Diff=%.10e %s", 
                             golden_real_hex, golden_real_val, sram_real_hex, sram_real_val, diff_real_abs,
                             real_match ? "\033[32m[MATCH]\033[0m" : "\033[31m[MISMATCH]\033[0m");
                    $display("  Imag: Expected 0x%h (%.6f), Got 0x%h (%.6f), Diff=%.10e %s", 
                             golden_imag_hex, golden_imag_val, sram_imag_hex, sram_imag_val, diff_imag_abs,
                             imag_match ? "\033[32m[MATCH]\033[0m" : "\033[31m[MISMATCH]\033[0m");
                    error_count = error_count + 1;
                    if (error_count >= 10) begin
                        $display("Too many errors, stopping verification");
                        stop_loop = 1;
                    end
                end else begin
                    $display("\033[32mPASS\033[0m at row=%0d, col=%0d (addr=%0d, bank=%0d):", row, col, addr, bank);
                    $display("  Real: Expected 0x%h (%.6f), Got 0x%h (%.6f) \033[32m[MATCH]\033[0m", 
                             golden_real_hex, golden_real_val, sram_real_hex, sram_real_val);
                    $display("  Imag: Expected 0x%h (%.6f), Got 0x%h (%.6f) \033[32m[MATCH]\033[0m", 
                             golden_imag_hex, golden_imag_val, sram_imag_hex, sram_imag_val);
                end
                
                line_count = line_count + 1;
            end
        end
        end  // if (!stop_loop)
        
        if (file_in != 0) begin
            $fclose(file_in);
        end
        
        if (error_count == 0) begin
            $display("\033[32mPASS\033[0m: SRAM %s verification successful! (%0d values checked)", 
                     sram_select ? "B" : "A", line_count);
        end else begin
            $display("FAIL: SRAM %s verification failed with %0d errors", 
                     sram_select ? "B" : "A", error_count);
        end
    end
    endtask

    // Task: Verify Twiddle ROM
    task verify_twiddle_rom;
        input [256*8-1:0] golden_hex_filename;
        
        integer file_in;
        integer addr;
        reg [63:0] golden_real_hex, golden_imag_hex;
        reg [127:0] golden_data;
        reg [127:0] rom_data;
        integer error_count;
        reg stop_loop;
        
    begin
        $display("Verifying Twiddle ROM against golden file: %s", golden_hex_filename);
        
        file_in = $fopen(golden_hex_filename, "r");
        if (file_in == 0) begin
            $display("ERROR: Cannot open golden file %s", golden_hex_filename);
            stop_loop = 1;
        end
        
        error_count = 0;
        addr = 0;
        stop_loop = 0;
        
        // Read golden file and compare
        if (!stop_loop) begin
        while (!$feof(file_in) && !stop_loop) begin
            if ($fscanf(file_in, "%h %h", golden_real_hex, golden_imag_hex) == 2) begin
                golden_data = {golden_real_hex, golden_imag_hex};
                
                // Read from ROM - use direct access since address wire has timing issues
                // twiddle_addr_reg = addr;
                // @(posedge clk);
                // #1;
                // rom_data = twiddle_data;
                // Use direct ROM access instead of through wire
                rom_data = u_twiddle_rom.rom[addr];
                
                // Compare
                if (rom_data !== golden_data) begin
                    $display("ERROR at addr=%0d: Expected %h, Got %h", addr, golden_data, rom_data);
                    error_count = error_count + 1;
                    if (error_count >= 10) begin
                        $display("Too many errors, stopping verification");
                        stop_loop = 1;
                    end
                end
                
                addr = addr + 1;
            end
        end
        end  // if (!stop_loop)
        
        if (file_in != 0) begin
            $fclose(file_in);
        end
        
        if (error_count == 0) begin
            $display("\033[32mPASS\033[0m: Twiddle ROM verification successful! (%0d values checked)", addr);
        end else begin
            $display("FAIL: Twiddle ROM verification failed with %0d errors", error_count);
        end
    end
    endtask

    // Task: Test Row FFT for a specific stage
    task test_row_fft_stage;
        input [31:0] stage;  // Stage number: 0-5
        input [256*8-1:0] golden_filename;
        input sram_select;  // 0 for SRAM A, 1 for SRAM B
        
        integer wait_timeout;
        integer timeout_limit;
        
    begin
        timeout_limit = 64'd10000;  // 100ms timeout (use sized constant)
        
        $display("\n=== Row FFT Stage %0d Test ===", stage);
        $display("Golden file: %s", golden_filename);
        $display("SRAM: %s", sram_select ? "B" : "A");
        
        // Start FFT
        $display("Starting FFT...");
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for done signal
        wait_timeout = 0;
        while (!done && wait_timeout < timeout_limit) begin
            @(posedge clk);
            wait_timeout = wait_timeout + 1;
        end
        
        if (wait_timeout >= timeout_limit) begin
            $display("ERROR: Timeout waiting for done signal!");
            if (MODE_PARAM == 0) begin
                $display("Test failed - Row FFT did not complete");
                $display("=== Row FFT Stage %0d Test Failed ===\n", stage);
            end else begin
                $display("Test failed - Row IFFT did not complete");
                $display("=== Row IFFT Stage %0d Test Failed ===\n", stage);
            end
            disable test_row_fft_stage;
        end
        
        if (MODE_PARAM == 0) begin
            $display("Row FFT done signal received after %0d clock cycles", wait_timeout);
        end else begin
            $display("Row IFFT done signal received after %0d clock cycles", wait_timeout);
        end
        @(posedge clk);  // Wait one more cycle for data to stabilize
        
        // Verify results
        $display("Verifying results against golden file...");
        verify_sram_against_hex(golden_filename, sram_select);
        
        if (MODE_PARAM == 0) begin
            $display("=== Row FFT Stage %0d Test Complete ===\n", stage);
        end else begin
            $display("=== Row IFFT Stage %0d Test Complete ===\n", stage);
        end
    end
    endtask

    // Task: Test Column FFT for a specific stage
    task test_col_fft_stage;
        input [31:0] stage;  // Stage number: 0-5
        input [256*8-1:0] golden_filename;
        input sram_select;  // 0 for SRAM A, 1 for SRAM B
        
        integer wait_timeout;
        integer timeout_limit;
        
    begin
        timeout_limit = 64'd10000000;  // 100ms timeout (use sized constant, same as row FFT)
        
        $display("\n=== Column FFT Stage %0d Test ===", stage);
        $display("Golden file: %s", golden_filename);
        $display("SRAM: %s", sram_select ? "B" : "A");
        
        // Start FFT
        $display("Starting Column FFT...");
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for done signal
        wait_timeout = 0;
        while (!done && wait_timeout < timeout_limit) begin
            @(posedge clk);
            wait_timeout = wait_timeout + 1;
        end
        
        if (wait_timeout >= timeout_limit) begin
            $display("ERROR: Timeout waiting for done signal!");
            if (MODE_PARAM == 0) begin
                $display("Test failed - Column FFT did not complete");
                $display("=== Column FFT Stage %0d Test Failed ===\n", stage);
            end else begin
                $display("Test failed - Column IFFT did not complete");
                $display("=== Column IFFT Stage %0d Test Failed ===\n", stage);
            end
            disable test_col_fft_stage;
        end
        
        if (MODE_PARAM == 0) begin
            $display("Column FFT done signal received after %0d clock cycles", wait_timeout);
        end else begin
            $display("Column IFFT done signal received after %0d clock cycles", wait_timeout);
        end
        @(posedge clk);  // Wait one more cycle for data to stabilize
        
        // Verify results
        $display("Verifying results against golden file...");
        verify_sram_against_hex(golden_filename, sram_select);
        
        if (MODE_PARAM == 0) begin
            $display("=== Column FFT Stage %0d Test Complete ===\n", stage);
        end else begin
            $display("=== Column IFFT Stage %0d Test Complete ===\n", stage);
        end
    end
    endtask
    
    // Task for final output verification (COL_STAGE=6)
    // This task first runs column FFT stage 5, then waits for R2C state to complete
    // It verifies final output in SRAM B
    task test_final_output;
        input [256*8-1:0] golden_filename;
        
        integer wait_timeout;
        integer timeout_limit;
        integer wait_timeout_final;
        integer timeout_limit_final;
        
    begin
        $display("\n=== Final Output Verification Test ===");
        $display("Golden file: %s", golden_filename);
        $display("SRAM: B (final output is in SRAM B after R2C)");
        
        // First, run column FFT stage 5 if not already completed
        $display("Running column FFT stage 5...");
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for done signal (column FFT stage 5 completes)
        timeout_limit = 64'd10000;  // 100ms timeout
        wait_timeout = 0;
        while (!done && wait_timeout < timeout_limit) begin
            @(posedge clk);
            wait_timeout = wait_timeout + 1;
        end
        
        if (wait_timeout >= timeout_limit) begin
            $display("ERROR: Timeout waiting for done signal!");
            $display("Test failed - Column FFT stage 5 did not complete");
            disable test_final_output;
        end
        
        $display("Column FFT stage 5 done signal received after %0d clock cycles", wait_timeout);
        @(posedge clk);  // Wait one more cycle for data to stabilize
        
        // Wait for R2C state to complete (transferring data from SRAM A to SRAM B)
        $display("Waiting for R2C state to complete (transferring data from SRAM A to SRAM B)...");
        $display("R2C state needs ~1024 cycles (cnt_out from 0 to 1023)");
        
        wait_timeout_final = 0;
        timeout_limit_final = 1200;  // Wait for R2C to complete (~1024 cycles + margin)
        while (wait_timeout_final < timeout_limit_final) begin
            @(posedge clk);
            wait_timeout_final = wait_timeout_final + 1;
        end
        
        // Additional wait to ensure data is stable in SRAM B
        #200;
        
        $display("R2C state should be complete after %0d cycles", wait_timeout_final);
        
        // Verify final output
        $display("Verifying final 2D FFT result in SRAM B against golden file...");
        verify_sram_against_hex(golden_filename, 1);  // 1 = SRAM B
        
        $display("=== Final Output Verification Test Complete ===\n");
    end
    endtask

    // Main test sequence
    initial begin
        $display("========================================");
        $display("FFT Test Environment Initialization");
        $display("========================================");
        
        // Wait for reset
        wait(rst_n);
        #200;
        
        // Test 1: Load input data into SRAM A
        $display("\n=== Test 1: Loading input.hex into SRAM A ===");
        if(MODE_PARAM == 0)
            u_sramA.load_hex("fft_pat/input.hex");
        else
            u_sramA.load_hex("fft_pat/input_ifft.hex");
        #100;
        
        // Test 2: Verify input data in SRAM A
        $display("\n=== Test 2: Verifying input data in SRAM A ===");
        if(MODE_PARAM == 0)
            verify_sram_against_hex("fft_pat/input.hex", 0);
        else
            verify_sram_against_hex("fft_pat/input_ifft.hex", 0);
        #100;
        
        // Test 3: Verify Twiddle ROM initialization
        $display("\n=== Test 3: Verifying Twiddle ROM initialization ===");
        // Wait for ROM initialization to complete
        wait(u_twiddle_rom.rom_initialized);
        #100;  // Additional delay to ensure ROM is ready
        verify_twiddle_rom("fft_pat/twiddle_factors.hex");
        #100;
        
        $display("\n========================================");
        $display("Initialization Tests Complete");
        $display("========================================");
        
        // Start FFT/IFFT after initialization is complete
        if (MODE_PARAM == 0) begin
            $display("\nStarting FFT after initialization...");
        end else begin
            $display("\nStarting IFFT after initialization...");
        end
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        $display("Start signal asserted and deasserted");
        #100;
        
        // Row FFT/IFFT Test (if ROW_STAGE is set to 0-5)
        // Ping-pong mechanism: A->B->A->B->A->B
        // Stage 0: A->B (read from A, write to B, verify B)
        // Stage 1: B->A (read from B, write to A, verify A)
        // Stage 2: A->B (read from A, write to B, verify B)
        // Stage 3: B->A (read from B, write to A, verify A)
        // Stage 4: A->B (read from A, write to B, verify B)
        // Stage 5: B->A (read from B, write to A, verify A)
        if (ROW_STAGE >= 0 && ROW_STAGE <= 5) begin
            $display("\n========================================");
            if (MODE_PARAM == 0) begin
                $display("Row FFT Stage %0d Test", ROW_STAGE);
            end else begin
                $display("Row IFFT Stage %0d Test", ROW_STAGE);
            end
            $display("========================================");
            
            case (ROW_STAGE)
                // Stage 0: A->B, verify B
                0: begin
                    if (MODE_PARAM == 0)
                        test_row_fft_stage(0, "fft_pat/row_fft_stage0_bitreversed.hex", 1);
                    else
                        test_row_fft_stage(0, "fft_pat/row_ifft_stage0_bitreversed.hex", 1);
                end
                // Stage 1: B->A, verify A
                1: begin
                    if (MODE_PARAM == 0)
                        test_row_fft_stage(1, "fft_pat/row_fft_stage1_m2.hex", 0);
                    else
                        test_row_fft_stage(1, "fft_pat/row_ifft_stage1_m2.hex", 0);
                end
                // Stage 2: A->B, verify B
                2: begin
                    if (MODE_PARAM == 0)
                        test_row_fft_stage(2, "fft_pat/row_fft_stage2_m4.hex", 1);
                    else
                        test_row_fft_stage(2, "fft_pat/row_ifft_stage2_m4.hex", 1);
                end
                // Stage 3: B->A, verify A
                3: begin
                    if (MODE_PARAM == 0)
                        test_row_fft_stage(3, "fft_pat/row_fft_stage3_m8.hex", 0);
                    else
                        test_row_fft_stage(3, "fft_pat/row_ifft_stage3_m8.hex", 0);
                end
                // Stage 4: A->B, verify B
                4: begin
                    if (MODE_PARAM == 0)
                        test_row_fft_stage(4, "fft_pat/row_fft_stage4_m16.hex", 1);
                    else
                        test_row_fft_stage(4, "fft_pat/row_ifft_stage4_m16.hex", 1);
                end
                // Stage 5: B->A, verify A
                5: begin
                    if (MODE_PARAM == 0)
                        test_row_fft_stage(5, "fft_pat/row_fft_stage5_m32.hex", 0);
                    else
                        test_row_fft_stage(5, "fft_pat/row_ifft_stage5_m32.hex", 0);
                end
                default: $display("ERROR: Invalid ROW_STAGE value: %0d", ROW_STAGE);
            endcase
            
            $display("\n========================================");
            if (MODE_PARAM == 0) begin
                $display("Row FFT Test Complete");
            end else begin
                $display("Row IFFT Test Complete");
            end
            $display("========================================");
        end else begin
            if (MODE_PARAM == 0) begin
                $display("\nRow FFT test skipped (ROW_STAGE=%0d, valid range: 0-5)", ROW_STAGE);
            end else begin
                $display("\nRow IFFT test skipped (ROW_STAGE=%0d, valid range: 0-5)", ROW_STAGE);
            end
        end
        
        // Column FFT Test (if COL_STAGE is set to 0-5)
        // Note: Column FFT requires row FFT to be completed first
        // Ping-pong mechanism: A->B->A->B->A->B (continues from row FFT)
        // Stage 0: A->B (read from A, write to B, verify B)
        // Stage 1: B->A (read from B, write to A, verify A)
        // Stage 2: A->B (read from A, write to B, verify B)
        // Stage 3: B->A (read from B, write to A, verify A)
        // Stage 4: A->B (read from A, write to B, verify B)
        // Stage 5: B->A (read from B, write to A, verify A)
        if (COL_STAGE >= 0 && COL_STAGE <= 6) begin
            $display("\n========================================");
            if (MODE_PARAM == 0) begin
                $display("Column FFT Stage %0d Test", COL_STAGE);
            end else begin
                $display("Column IFFT Stage %0d Test", COL_STAGE);
            end
            $display("========================================");
            
            // Column FFT/IFFT directly continues from row FFT/IFFT, no need to reload data
            // The row FFT/IFFT result is already in the appropriate SRAM based on ROW_STAGE
            if (MODE_PARAM == 0) begin
                $display("\n=== Column FFT continues from row FFT result (no reload needed) ===");
            end else begin
                $display("\n=== Column IFFT continues from row IFFT result (no reload needed) ===");
            end
            if (ROW_STAGE >= 0 && ROW_STAGE <= 5) begin
                // Row FFT/IFFT was tested, data is already in the correct SRAM
                // Stage 0: A->B, result in B
                // Stage 1: B->A, result in A
                // Stage 2: A->B, result in B
                // Stage 3: B->A, result in A
                // Stage 4: A->B, result in B
                // Stage 5: B->A, result in A
                if (ROW_STAGE % 2 == 0) begin
                    if (MODE_PARAM == 0) begin
                        $display("Column FFT will use data from SRAM B (row FFT result is in SRAM B)");
                    end else begin
                        $display("Column IFFT will use data from SRAM B (row IFFT result is in SRAM B)");
                    end
                end else begin
                    if (MODE_PARAM == 0) begin
                        $display("Column FFT will use data from SRAM A (row FFT result is in SRAM A)");
                    end else begin
                        $display("Column IFFT will use data from SRAM A (row IFFT result is in SRAM A)");
                    end
                end
            end else begin
                if (MODE_PARAM == 0) begin
                    $display("Row FFT was not tested, assuming data is in SRAM A");
                end else begin
                    $display("Row IFFT was not tested, assuming data is in SRAM A");
                end
            end
            #100;
            
            case (COL_STAGE)
                // Stage 0: A->B, verify B
                0: begin
                    if (MODE_PARAM == 0)
                        test_col_fft_stage(0, "fft_pat/col_fft_stage0_bitreversed.hex", 1);
                    else
                        test_col_fft_stage(0, "fft_pat/col_ifft_stage0_bitreversed.hex", 1);
                end
                // Stage 1: B->A, verify A
                1: begin
                    if (MODE_PARAM == 0)
                        test_col_fft_stage(1, "fft_pat/col_fft_stage1_m2.hex", 0);
                    else
                        test_col_fft_stage(1, "fft_pat/col_ifft_stage1_m2.hex", 0);
                end
                // Stage 2: A->B, verify B
                2: begin
                    if (MODE_PARAM == 0)
                        test_col_fft_stage(2, "fft_pat/col_fft_stage2_m4.hex", 1);
                    else
                        test_col_fft_stage(2, "fft_pat/col_ifft_stage2_m4.hex", 1);
                end
                // Stage 3: B->A, verify A
                3: begin
                    if (MODE_PARAM == 0)
                        test_col_fft_stage(3, "fft_pat/col_fft_stage3_m8.hex", 0);
                    else
                        test_col_fft_stage(3, "fft_pat/col_ifft_stage3_m8.hex", 0);
                end
                // Stage 4: A->B, verify B
                4: begin
                    if (MODE_PARAM == 0)
                        test_col_fft_stage(4, "fft_pat/col_fft_stage4_m16.hex", 1);
                    else
                        test_col_fft_stage(4, "fft_pat/col_ifft_stage4_m16.hex", 1);
                end
                // Stage 5: B->A, verify A
                5: begin
                    if (MODE_PARAM == 0)
                        test_col_fft_stage(5, "fft_pat/col_fft_stage5_m32.hex", 0);
                    else
                        test_col_fft_stage(5, "fft_pat/col_ifft_stage5_m32.hex", 0);
                end
                // Stage 6: Final output verification (assumes stage 5 completed, waits for R2C, verifies SRAM B)
                6: begin
                    if (MODE_PARAM == 0)
                        test_col_fft_stage(6, "fft_pat/final_output.hex", 1);
                    else
                        test_col_fft_stage(6, "fft_pat/final_output_ifft.hex", 1);
                end
                default: $display("ERROR: Invalid COL_STAGE value: %0d", COL_STAGE);
            endcase
            
            $display("\n========================================");
            if (MODE_PARAM == 0) begin
                $display("Column FFT Test Complete");
            end else begin
                $display("Column IFFT Test Complete");
            end
            $display("========================================");
        end else begin
            if (MODE_PARAM == 0) begin
                $display("\nColumn FFT test skipped (COL_STAGE=%0d, valid range: 0-6)", COL_STAGE);
            end else begin
                $display("\nColumn IFFT test skipped (COL_STAGE=%0d, valid range: 0-6)", COL_STAGE);
            end
        end
        
        #1000;
        $finish;
    end

endmodule