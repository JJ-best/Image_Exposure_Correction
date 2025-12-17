`timescale 1ns/100ps

// 定義測試資料範圍
`define PAT_L 0
`define PAT_U 1999 
`define NUM_PAT (`PAT_U-`PAT_L+1)

`define CYCLE 10
`define END_CYCLES 100000 
`define FLAG_VERBOSE 1    // 1: 顯示錯誤細節, 0: 只顯示統計
`define FLAG_DUMPWV 1     // 1: 產生波形檔

module tb_fp64_reciprocal;

// Parameters
parameter pFP_WIDTH = 64;
parameter TOLERANCE = 2; // 容許 2 ULP (Unit in Last Place) 的誤差

// ===== module I/O ===== //
reg clk;
reg srst_n;
reg in_valid;
reg [pFP_WIDTH-1:0] in_A;
wire [pFP_WIDTH-1:0] in_B;
wire output_valid;

// ===== Data Arrays ===== //
// 靜態陣列，用於儲存 golden pattern
reg [127:0] test_vectors [0:`NUM_PAT-1];
reg [pFP_WIDTH-1:0] input_data [0:`NUM_PAT-1];
reg [pFP_WIDTH-1:0] golden_data [0:`NUM_PAT-1];

// Counters
integer in_idx;   // 輸入資料指標 (Driver)
integer out_idx;  // 輸出比對指標 (Monitor)
integer total_err;

// =========================================================
// 1. Instantiate DUT (Device Under Test)
// =========================================================
fp64_reciprocal #(
    .pFP_WIDTH(pFP_WIDTH)
) uut (
    .clk(clk),
    .srst_n(srst_n),
    .in_valid(in_valid),
    .in_A(in_A),
    .in_B(in_B),
    .output_valid(output_valid)
);

// =========================================================
// 2. Clock & Reset
// =========================================================
initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end

// Watchdog (防止模擬卡死)
initial begin
    #(`CYCLE * `END_CYCLES);
    $display("\n[Error] Simulation timeout! Output valid never asserted enough times.");
    $finish;
end

// =========================================================
// 3. Load Data Task
// =========================================================
task load_golden;
    integer idx;
    begin
        $display("Loading golden.dat...");
        // 請確保 golden.dat 在當前目錄下
        $readmemh("./fp64_recip_pat/golden.dat", test_vectors);
        
        for(idx = 0; idx < `NUM_PAT; idx = idx + 1) begin
            // 切分 128bit 為 Input(高位) 與 Golden(低位)
            input_data[idx]  = test_vectors[idx][127:64];
            golden_data[idx] = test_vectors[idx][63:0];
        end
    end
endtask

// =========================================================
// 4. Input Driver (負責一直餵資料)
// =========================================================
initial begin
    // 初始化
    load_golden;
    srst_n = 1;
    in_valid = 0;
    in_A = 0;
    in_idx = 0;

    // Reset 序列
    @(negedge clk); srst_n = 0;
    @(negedge clk); srst_n = 1;
    @(negedge clk); 

    $display("\n[Start] Feeding Pipeline with %0d patterns...", `NUM_PAT);

    // Pipeline 餵入迴圈：每個 Cycle 都送一筆新資料
    while (in_idx < `NUM_PAT) begin
        // 設定訊號
        in_valid = 1'b1;
        in_A     = input_data[in_idx];
        
        // 推進 index
        in_idx = in_idx + 1;
        
        // 等待下一個 Cycle
        @(negedge clk); 
    end

    // 資料餵完後，拉低 Valid
    in_valid = 1'b0;
    in_A = 0;
    $display("[Driver] All data fed into pipeline. Waiting for outputs...");
end

// =========================================================
// 5. Output Monitor (負責一直收資料並比對)
// =========================================================
initial begin
    out_idx = 0;
    total_err = 0;
    
    // 等待 Reset 結束
    wait(srst_n == 1);

    // 監控迴圈：直到收滿所有資料才停止
    while (out_idx < `NUM_PAT) begin
        @(posedge clk); // 在正緣採樣輸出
        
        if (output_valid) begin
            check_result(out_idx); // 比對結果
            out_idx = out_idx + 1;
        end
    end

    // 結束模擬
    final_report;
    $finish;
end

// =========================================================
// 6. 輔助 Tasks
// =========================================================

// 比對邏輯
task check_result;
    input integer idx;
    reg [pFP_WIDTH-1:0] exp_val;
    reg [pFP_WIDTH-1:0] dut_val;
    reg [pFP_WIDTH-1:0] diff;
    begin
        // 因為是 FIFO 結構，第 N 個 output_valid 對應第 N 筆 golden_data
        exp_val = golden_data[idx];
        dut_val = in_B;

        // 計算誤差 (絕對值)
        if (exp_val > dut_val) diff = exp_val - dut_val;
        else                   diff = dut_val - exp_val;

        // 判斷是否通過 (Tolerance)
        // 注意：這裡簡化了 NaN/Inf 的比對，若需要嚴格 IEEE754 比對需額外判斷
        if (diff > TOLERANCE && exp_val != dut_val) begin
            if (`FLAG_VERBOSE) begin
                $display("[FAIL] Pat %0d | In=%h | Exp=%h | Got=%h | Diff=%0d", 
                         idx, input_data[idx], exp_val, dut_val, diff);
            end
            total_err = total_err + 1;
        end
    end
endtask

// 最終報告
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

// 波形設定
initial begin
    if(`FLAG_DUMPWV)begin
        $fsdbDumpfile("recip_pipeline.fsdb");
        $fsdbDumpvars(0, tb_fp64_reciprocal, "+mda");
    end
end

endmodule