module fp64_recip #(
    parameter pFP_WIDTH = 64
)(
    input clk,
    input srst_n,
    input [(pFP_WIDTH-1):0] in_dat  // write input data in tb
    input in_valid,                 // pull input valid in tb
    output [(pFP_WIDTH-1):0] out_dat,
    output output_valid
);
// please make sure that the period can be faster than 3ns

endmodule //fp64_recip