//======================================================================================================
//  Note:           Adapted for FP64 Reciprocal Unit Verification
//======================================================================================================

`timescale 1ns/100ps

`define PAT_L 0
`define PAT_U 1999  // Test 2000 patterns (Matches the number of lines in golden.dat)
`define NUM_PAT (`PAT_U-`PAT_L+1)

`define CYCLE 10
`define END_CYCLES 100000 // Prevent simulation from hanging indefinitely
`define FLAG_VERBOSE 1    // Set to 1 to show detailed errors, 0 to show only Pass/Fail summary
`define FLAG_DUMPWV 1     // Set to 1 to enable waveform dumping

module tb_fp64_reciprocal;

// Parameters
localparam pFP_WIDTH   = 64;
localparam pDATA_WIDTH = 128;
localparam TOLERANCE   = 2;    // Allowable error margin in ULP (Units in Last Place)
localparam MUL_LATENCY = 3;    // Latency of the simulated multiplier

// ===== module I/O ===== //
reg clk;
reg srst_n;
reg in_valid;
reg [pFP_WIDTH-1:0] in_A;
wire [pFP_WIDTH-1:0] in_B;
wire output_valid;

// External Multiplier Interface (Connected to DUT)
wire mul_req;
wire [pDATA_WIDTH-1:0] mul_a;
wire [pDATA_WIDTH-1:0] mul_b;
wire  [pDATA_WIDTH-1:0] mul_res;
wire  mul_ack;

// ===== Data Arrays ===== //
// Format: Input(64 bits) + Expected(64 bits) = 128 bits total
reg [127:0] test_vectors [0:`NUM_PAT-1];
reg [pFP_WIDTH-1:0] input_data [0:`NUM_PAT-1];
reg [pFP_WIDTH-1:0] golden_data [0:`NUM_PAT-1];

// Debug Monitoring Wires (For waveform visibility)
wire [pFP_WIDTH-1:0] debug_current_golden;
wire [pFP_WIDTH-1:0] debug_current_input;

// Instantiate DUT (Device Under Test)
fp64_reciprocal #(
    .pFP_WIDTH(pFP_WIDTH)
) uut (
    .clk(clk),
    .srst_n(srst_n),
    
    // Control / Data IO
    .in_valid(in_valid),
    .in_A(in_A),
    .in_B(in_B),
    .output_valid(output_valid),

    // mul_model Interface
    .mul_req_o(mul_req),
    .mul_a_o(mul_a),
    .mul_b_o(mul_b),
    .mul_res_i(mul_res),
    .mul_ack_i(mul_ack)
);


// --- Mul Model Instance ---
// This simulates the external multiplier IP
mul #(.pDATA_WIDTH(pDATA_WIDTH)) u_mul (
    .clk(clk),
    .rst_n(srst_n),
    .mode(2'b10), // Float Mode
    .in_valid(mul_req),
    .in_A(mul_a),
    .in_B(mul_b),
    .result_c(),       // Unused complex result port
    .result_int(mul_res), // Result connected here
    .out_valid(mul_ack)
);


// ===== Waveform Dumping ===== //
initial begin
    if(`FLAG_DUMPWV)begin
        $fsdbDumpfile("reciprocal_unit.fsdb");
        $fsdbDumpvars("+mda"); // +mda enables dumping of memory arrays
    end
end

// ===== System Reset & Clock ===== //
initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end

// Watchdog Timer
initial begin
    #(`CYCLE * `END_CYCLES);
    $display("\n========================================================");
    $display("   Error!!! Simulation time is too long...             ");
    $display("   There might be something wrong in your FSM/Mul handshake.");
    $display("========================================================");
    $finish;
end

// ===== Cycle Counter ===== //
integer cycle_cnt;
integer aver_cycle_cnt;
initial begin
    cycle_cnt = 0;
    aver_cycle_cnt = 0;
    while(1) begin 
        cycle_cnt = cycle_cnt + 1;
        @(negedge clk);
    end
end

// ===== Main Verification Flow ===== //
integer i_pat;
integer total_err_pat;
integer error_tmp;

// Assign debug wires for easy waveform viewing
assign debug_current_golden = golden_data[i_pat];
assign debug_current_input  = input_data[i_pat];

initial begin
    // Load Patterns
    load_golden;

    $display("\n%c[1;36mStart checking FP64 Reciprocal Unit ... %c[0m\n", 27, 27);

    total_err_pat = 0;
    srst_n = 1;
    in_valid = 0;
    in_A = 0;

    // Reset Sequence
    @(negedge clk); srst_n = 1'b0;
    @(negedge clk); srst_n = 1'b1; 
    @(negedge clk);

    // Loop through patterns
    for(i_pat = `PAT_L; i_pat <= `PAT_U; i_pat = i_pat + 1) begin
        
        // Feed Input
        in_valid = 1'b1;
        in_A = input_data[i_pat];
        @(negedge clk);
        in_valid = 1'b0; // Pulse input valid

        // Wait for Output
        wait(output_valid);
        
        // Compare
        compare_output(i_pat);
        
        // Wait a bit before next pattern (optional pipeline bubble)
        @(negedge clk);
    end

    aver_cycle_cnt = cycle_cnt / `NUM_PAT;

    // Summary
    $display("\n\n\n                    Summary of all patterns: ");
    if(total_err_pat == 0) begin 
        $display("------------------------------------------------------------\n");
        $write("%c[1;32mCongratulations! %c[0m",27, 27);
        $display("Your Reciprocal Unit is correct!");
        $display("Total cycle count = %0d", cycle_cnt);
        $display("Average cycle count per pattern = %0d", aver_cycle_cnt);
        $display("-----------------------------PASS---------------------------\n");
        
    end else begin
        $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
        $display("X                                                            X");
        $display("X        %c[1;31mFAIL%c[0m in Reciprocal Unit!!!                  X",27,27);
        $display("X               %4d patterns are failed... (T ~ T)           X", total_err_pat);
        $display("X                                                            X");
        $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
        $display("Total cycle count = %0d", cycle_cnt);
    end
    $finish;
end

// ===== Tasks ===== //

task load_golden;
    integer idx;
    begin
        $display("Loading golden.dat...");
        // Format assumed: Input_Hex(64) Expected_Hex(64) combined into 128 bits
        // Adjust this if your golden.dat format is different
        $readmemh("./fp64_recip_pat/golden.dat", test_vectors);

        for(idx = 0; idx < `NUM_PAT; idx = idx + 1) begin
            // Ensure proper bit slicing:
            // [127:64] contains the Input value (High part)
            // [63:0]   contains the Golden Expected value (Low part)
            input_data[idx]  = test_vectors[idx][127:64];
            golden_data[idx] = test_vectors[idx][63:0];
        end

        $display("Data Split Check:");
        $display("  input_data[0]  = %h", input_data[0]);
        $display("  golden_data[0] = %h", golden_data[0]);
    end
endtask

task compare_output(input integer pat_idx);
    reg [pFP_WIDTH-1:0] golden;
    reg [pFP_WIDTH-1:0] yours;
    reg [pFP_WIDTH-1:0] diff;
    begin
        golden = golden_data[pat_idx];
        yours  = in_B;
        
        // Calculate Absolute Difference (Bitwise for ULP check)
        if (golden > yours) diff = golden - yours;
        else                diff = yours - golden;

        // Check Tolerance
        if (diff > TOLERANCE && golden != yours) begin
            if(`FLAG_VERBOSE) begin
                $display("\n========================================================================");
                $display("======================== Pattern No. %04d ========================", pat_idx);
                $display("========================================================================");
                $display("FAIL!");
                display_error(yours, golden, diff);
                $display("========================================================================");
            end
            total_err_pat = total_err_pat + 1;
        end else begin
            // Optional: Uncomment to see PASS messages
            // if(`FLAG_VERBOSE) $display("Pattern No. %04d PASS (Diff: %0d ULP)", pat_idx, diff);
        end
    end
endtask

task display_error(
    input [pFP_WIDTH-1:0] user_val,
    input [pFP_WIDTH-1:0] gold_val,
    input [pFP_WIDTH-1:0] difference
);
    begin
        $write("Your answer is      : %h\n", user_val);
        $write("But the golden is   : %h\n", gold_val);
        $write("Difference (ULP)    : %0d (Tolerance: %0d)\n", difference, TOLERANCE);
        $write("Input value was     : %h\n", input_data[i_pat]);
    end
endtask

endmodule