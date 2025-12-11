module int2fp #(
    parameter pFP_WIDTH = 64,
    parameter pINT_WIDTH = 8
)(
    input clk,
    input srst_n,
    input [(pINT_WIDTH-1):0]in_dat,
    input in_valid,
    output [(pFP_WIDTH-1):0]out_dat,
    output out_valid
);
// input

endmodule //int2fp