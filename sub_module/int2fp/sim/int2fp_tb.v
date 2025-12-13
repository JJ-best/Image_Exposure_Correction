module int2fp_tb();
localparam pINT_WIDTH = 8;
localparam pFP_WIDTH  = 64;
reg clk;
reg in_valid;
reg [(pINT_WIDTH-1):0]in_int;
wire [(pFP_WIDTH-1):0]out_fp;
wire out_valid;
real fp_val;

int2fp U0(
    .in_int(in_int),
    .in_valid(in_valid),
    .clk(clk),
    .out_fp(out_fp),
    .out_valid(out_valid)
);

// ===== clk generate ===== //
initial begin
    clk = 0;
    while(1) #(10/2) clk = ~clk;
end

// ===== input generate ===== //
integer i;
initial begin
    in_int = 0;
    in_valid = 0;
    repeat(2) @(posedge clk);
    for (i=0; i<256; i=i+1) begin
        in_valid <= 1;
        in_int <= in_int + 1;
        @(posedge clk);
    end
    in_valid = 0;
    in_int = 0;
    repeat(10) @(posedge clk);
    $finish;
end

reg [(pINT_WIDTH-1):0]in_int_q;
// ===== check output ===== //
always @(posedge clk) begin
    if (in_valid) begin 
        // store input integer for compare golden
        in_int_q <= in_int;
    end
end
integer err_cnt = 0;
always @(posedge clk) begin
    if (out_valid) begin
        fp_val = $bitstoreal(out_fp);
        if (fp_val !== in_int_q) begin
            $display("[FAIL] t=%0t | in=%0d | real=%f | out_fp=%h",
                     $time, in_int_q, fp_val, out_fp);
            err_cnt = err_cnt + 1;
        end
        else begin
            $display("[PASS] t=%0t | in=%0d | real=%f | out_fp=%h",
                     $time, in_int_q, fp_val, out_fp);
        end
    end
end
endmodule