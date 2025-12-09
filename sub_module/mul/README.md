# Multiplier

## Function IO
```verilog
module mul #(
    parameter pDATA_WIDTH = 128 
) (
    input [(pDATA_WIDTH-1) : 0]     in_A,      // real(float) + imag(float)
    input [(pDATA_WIDTH-1) : 0]     in_B,      // read(float) + imag(float)
    input [1:0]                     mode,      // complex mul(00), float mul(10)
    input                           clk ,
    input                           rst_n,
    input                           in_valid,  // input valid
    output[(pDATA_WIDTH-1)  :0]     result_c,  // output complex result or 2 float result
    output[(pDATA_WIDTH-1)  :0]     result_int,// ignore this path
    output                          out_valid  // output valid
);
```

## Function

`in_A` and `in_B` is 128-bit number, both can be view as **two** fp64 number concanacated.

In the complex multiplication, the higher 64-bit can be view as real part, the lower 64-bit can 
be view as imagenary part(a_re + j\*a_im and b_re + j\*b_im). The result is `result_c = (a_re + j*a_im) * (b_re + j*b_im) = {64-bit read, 64-bit imag}`.

In float multiplication, set `mode = 2'b10`, `in_A = {fp_num1, fp_num2}` and `in_B = {fp_num3, fp_num4}`, the result is `result_c = {fp_num1*fp_num3, fp_num2*fp_num4}`.

*Note:* If you need to switch mode, please make the interval of two mode 25 cycle, for pipeline flush.

To get latency, run the simulation, observe the input valid and output valid interval. 

## Testbench

First round, complex multiplication.

Secand round, two pair float multiplication.