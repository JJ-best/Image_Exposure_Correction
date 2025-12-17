# FFT
## Module IO
```verilog=
module fft(
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
endmodule
```
## Function
* This module implements a 32-point (5-stage) 2D FFT/IFFT. The computation is performed in two steps: first a row-wise FFT, followed by a column-wise FFT. 
* Due to SRAM access limitations, a transpose is performed before the column-wise FFT, and the result is transposed back afterward to match the original column order.
* Both FFT and IFFT use a Decimation-In-Time (DIT) structure with the form (a + b·w). The data pairing is the same for both operations, and for IFFT, you only need to take the complex conjugate of the twiddle factors.
* For mode switching FFT <-> IFFT, there are waiting cycles for the pipeline to flush.

## sram mapping
* The ping-pong sram are both 16 bank, 64 addr, with 128 bit per address (data format: 64bit real_64bit imaginary)

|| bank 0 | bank 1|bank 2|...|| bank 0 | bank 1|bank 2|...|
|--|--|--|--|--|--|--|--|--|--|
|addr0|(0, 0) |(0, 1)| (0, 2) |...|addr1|(0, 16)|(0, 17)|(0, 18)|...|
|addr2|(1, 0) |(1, 1)| (1, 2) |...|addr3|(1, 16)|(1, 17)|(1, 18)|...|
|...|...|...|...|...|...|...|...|...|...|
|addr62|(63, 0) |(63, 1)| (63, 2) |...|addr63|(63, 16)|(63, 17)|(63, 18)|...|

## Complete process
* input and output are at **different** sram
* When the 32 row FFT operations are completed, a transpose (TSP) is performed and the data is moved from SRAM B to SRAM A. The column FFT is then executed. After all 32 column FFT operations are finished, another transpose is performed, and the final data is stored in SRAM B.

|                | Normal Input | Reverse | S1 out | S2 out | S3 out | S4 out | S5 out | TSP     |
|----------------|--------------|---------|--------|--------|--------|--------|--------| --------|
| Row FFT / IFFT | A            | B       | A      | B      | A      | B      | A      | B       |
| Col FFT / IFFT | A            | B       | A      | B      | A      | B      | A      | B       |

## Implement
### Step1 : Create pattern
```
cd py
python3 fft.py
```
### Step2 : Run simulation
```
cd sim
sh run_sim.sh
```
