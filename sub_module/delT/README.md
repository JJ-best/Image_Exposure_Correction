# delT
## Module IO
### Integrate in top
* sram_t (sram_64x16b_16bank)
* sram_x (sram_512x8b)
* fp_add * 4
* delT 
```
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
```
### rtl io
```
module delT#(
    parameter BW_PER_ADDR_T = 128,
    parameter BW_PER_ADDR_X = 64,
    parameter ADDR_WIDTH_T = 8,
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
endmodule
```
## Synthesis info
* Area: 7750.062173
* Timing : 3.5ns (MET)

## Function
* Implement sramT_2 -> sramX_2
* Two parts to calculate: $\nabla T_n (D_x)$ and $\nabla T_v (D_y)$.
* When receiving `enable`, calculate start, when storing back all sramX, set `done = 1`. Both signal are 1-cycle.
### 1.  $\nabla T_n (D_x)$ ###
- Interior columns (`0 ≤ j < 31`): $\[(D_x T)(i, j) = T(i, j+1) - T(i, j)\]$
- Last column (wrap-around) (`j = 31`): $\[(D_x T)(i, 31) = T(i, 0) - T(i, 31)\]$

### 2.  $\nabla T_v (D_y)$ ###
- Interior rows (`0 ≤ i < 31`): $\[(D_y T)(i, j) = T(i+1, j) - T(i, j)\]$
- Last row (wrap-around) (`i = 31`): $\[(D_y T)(31, j) = T(0, j+1) - T(31, j)\]$

### 3. Concate $\nabla T_n (D_x)$ and $\nabla T_v (D_y)$
* For left half of sramX, store $\nabla T_n (D_x)$; for the right half of sramX, store $\nabla T_v (D_y)$
<img width="1587" height="1000" alt="image" src="https://github.com/user-attachments/assets/cc193b7e-4de5-4100-8a46-e1269fa039cc" />

## sram mapping
* sramT_2 (16bank, 128bit per pixel)

|| bank 0 | bank 1|bank 2|...|| bank 0 | bank 1|bank 2|...|
|--|--|--|--|--|--|--|--|--|--|
|addr0|(0, 0) |(0, 1)| (0, 2) |...|addr1|(0, 16)|(0, 17)|(0, 18)|...|
|addr2|(1, 0) |(1, 1)| (1, 2) |...|addr3|(1, 16)|(1, 17)|(1, 18)|...|
|...|...|...|...|...|...|...|...|...|...|
|addr62|(63, 0) |(63, 1)| (63, 2) |...|addr63|(63,16)|(63,17)|(63,18)|...|

* sramX_2 (4 bank, 64 bit per pixel)

| Address | Bank 0 | Bank 1 | Bank 2 | Bank 3 | Address | Bank 0 | … | Bank 3 | … | Address | Bank 0  | … | Bank 3  |
| ------- | ------ | ------ | ------ | ------ | ------- | ------ | - | ------ | - | ------- | ------- | - | ------- |
| addr0   | (0,0)  | (0,1)  | (0,2)  | (0,3)  | addr1   | (0,4)  | … | (0,7)  | … | addr7   | (0,24)  | … | (0,31)  |
| addr8   | (1,0)  | (1,1)  | (1,2)  | (1,3)  | addr9   | (1,4)  | … | (1,7)  | … | addr15  | (1,24)  | … | (1,31)  |
| addr16  | (2,0)  | (2,1)  | (2,2)  | (2,3)  | addr17  | (2,4)  | … | (2,7)  | … | addr23  | (2,24)  | … | (2,31)  |
| addr32  | (3,0)  | (3,1)  | (3,2)  | (3,3)  | addr33  | (3,4)  | … | (3,7)  | … | addr39  | (3,24)  | … | (3,31)  |
| ...     | ...    | ...    | ...    | ...    | ...     | ...    | … | ...    | … | ...     | ...     | … | ...     |
| addr504 | (63,0) | (63,1) | (63,2) | (63,3) | addr505 | (63,4) | … | (63,7) | … | addr511 | (63,24) | … | (63,31) |

## Implementation
<span style="color:red;">NOTE: You have to change the golden order from bottom-up to normal order</span>
### Step1 : Create pattern
```
cd py/py_overlap_partition
python3 main.py
```
### Step2 : Run simulation
```
cd sim
sh run_sim.sh
```
