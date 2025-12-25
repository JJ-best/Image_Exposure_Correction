`timescale 1ns/100ps

`define PAT_L 0
`define PAT_U 2999 
`define NUM_PAT (`PAT_U-`PAT_L+1)

`define CYCLE 10
`define END_CYCLES 100000 
`define FLAG_VERBOSE 1
`define FLAG_DUMPWV 1

module tb_fp64_reciprocal;


parameter pFP_WIDTH = 64;
parameter TOLERANCE = 2;

reg clk;
reg srst_n;
reg in_valid;
reg [pFP_WIDTH-1:0] in_A;
wire [pFP_WIDTH-1:0] out_B;
wire output_valid;

reg [127:0] test_vectors [0:`NUM_PAT-1];
reg [pFP_WIDTH-1:0] input_data [0:`NUM_PAT-1];
reg [pFP_WIDTH-1:0] golden_data [0:`NUM_PAT-1];

integer in_idx;
integer out_idx;
integer total_err;

fp64_reciprocal #(
    .pFP_WIDTH(pFP_WIDTH)
) uut (
    .clk(clk),
    .srst_n(srst_n),
    .in_valid(in_valid),
    .in_A(in_A),
    .out_B(out_B),
    .output_valid(output_valid)
);


initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end


initial begin
    #(`CYCLE * `END_CYCLES);
    $display("\n[Error] Simulation timeout! Output valid never asserted enough times.");
    $finish;
end


task load_golden;
    integer idx;
    begin
        $display("Loading golden.dat...");
        $readmemh("./fp64_recip_pat/golden.dat", test_vectors);
        
        for(idx = 0; idx < `NUM_PAT; idx = idx + 1) begin
            input_data[idx]  = test_vectors[idx][127:64];
            golden_data[idx] = test_vectors[idx][63:0];
        end
    end
endtask

initial begin

    load_golden;
    srst_n = 1;
    in_valid = 0;
    in_A = 0;
    in_idx = 0;


    @(negedge clk); srst_n = 0;
    @(negedge clk); srst_n = 1;
    @(negedge clk); 

    $display("\n[Start] Feeding Pipeline with %0d patterns...", `NUM_PAT);


    while (in_idx < `NUM_PAT) begin
        in_valid = 1'b1;
        in_A     = input_data[in_idx];
        
        in_idx = in_idx + 1;
        
        @(negedge clk); 
    end

    in_valid = 1'b0;
    in_A = 0;
    $display("[Driver] All data fed into pipeline. Waiting for outputs...");
end


initial begin
    out_idx = 0;
    total_err = 0;
    
    wait(srst_n == 1);

    while (out_idx < `NUM_PAT) begin
        @(posedge clk);
        
        if (output_valid) begin
            check_result(out_idx);
            out_idx = out_idx + 1;
        end
    end

    final_report;
    $finish;
end



task check_result;
    input integer idx;
    reg [pFP_WIDTH-1:0] exp_val;
    reg [pFP_WIDTH-1:0] dut_val;
    reg [pFP_WIDTH-1:0] diff;
    begin
        exp_val = golden_data[idx];
        dut_val = out_B;

        if (exp_val > dut_val) diff = exp_val - dut_val;
        else                   diff = dut_val - exp_val;

        if (diff > TOLERANCE && exp_val != dut_val) begin
            if (`FLAG_VERBOSE) begin
                $display("[FAIL] Pat %0d | In=%h | Exp=%h | Got=%h | Diff=%0d", 
                         idx, input_data[idx], exp_val, dut_val, diff);
            end
            total_err = total_err + 1;
        end
    end
endtask

task final_report;
    begin
        $display("\n========================================================");
        if (total_err == 0) begin
            $display("  CONGRATULATIONS! All %0d patterns passed!", `NUM_PAT);
            $display("  Pipeline latency verified implicitly.");
        end else begin
            $display("  FAIL! Found %0d errors.", total_err);
        end
        $display("========================================================\n");
    end
endtask

initial begin
    if(`FLAG_DUMPWV)begin
        $fsdbDumpfile("recip_pipeline.fsdb");
        $fsdbDumpvars(0, tb_fp64_reciprocal, "+mda");
    end
end

endmodule