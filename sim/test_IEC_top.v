`timescale 1ns/100ps
`define PAT_L 0
`define PAT_U 1
`define NUM_PAT (`PAT_U-`PAT_L+1)

`define CYCLE 10
`define END_CYCLES 20
`define FLAG_DUMPWV 1
`define FLAG_VERBOSE 1

module test_IEC_top;

// ===== Parameters ===== //
localparam INPUT = 5'd0;
localparam INIT = 5'd1;
localparam BW_PER_ADDR_A = 24;    // SRAM A: 24-bit per address 
localparam BW_PER_ADDR_B = 64;    // SRAM B: 64-bit per address 
localparam BW_PER_ADDR_I = 64;    // SRAM I: 64-bit per address
localparam SRAM_ADDR_WIDTH_A = 8; // SRAM A: 8-bit address (256 addresses)
localparam SRAM_ADDR_WIDTH_B = 8; // SRAM B: 8-bit address (256 addresses)
localparam SRAM_ADDR_WIDTH_I = 8; // SRAM B: 8-bit address (256 addresses)

// ===== Layer selection ===== //
// +define+LAYER=1 or +define+LAYER=2 in run_sim.sh
// LAYER=1 (input_image)
// LAYER=2 (init)
integer layer_value;

// ===== Pattern selection ===== //
// +define+PAT=1 or +define+PAT=2 in run_sim.sh
// PATCH_I, PATCH_J can be set via +define+PATCH_I=0 and +define+PATCH_J=0
// Example : patch_00_00_under/over.bmp -> patch_i_value = 00, patch_j_value = 00
reg [7:0] pat_value;
integer patch_i_value;
integer patch_j_value;

// ===== Initialization selection ===== //
// Control whether to initialize SRAM B (Layer 2)
// Validation for testbench
integer init_enable;  


// ===== Settings  ===== //
initial begin
    // LAYER 
    // INPUT: input_image -> 1
    // INIT : initial_illum_map -> 2
    `ifdef INPUT
        layer_value = 1;  
    `elsif INIT
        layer_value = 2;
    `endif
    
    // PAT 
    // 1 : imgs_lime1
    // 2 : imgs_lime2
    if(`PAT == 1)
        pat_value = "1";
    else if(`PAT == 2)
        pat_value = "2";
    else
        pat_value = "1";  
    
    // PATCH_I 
    `ifdef PATCH_I
        patch_i_value = `PATCH_I;
    `else
        patch_i_value = 0; 
    `endif
    
    // PATCH_J 
    `ifdef PATCH_J
        patch_j_value = `PATCH_J;
    `else
        patch_j_value = 0;  
    `endif
    
    // INIT_EN (Sram B initialization)
    `ifdef INIT_EN
        init_enable = `INIT_EN;
    `else
        init_enable = 0; 
    `endif
    
    // Print setting info
    $display("Using PAT = %c (lime%c), PATCH_I = %0d, PATCH_J = %0d, INIT_EN = %0d", 
             pat_value, pat_value, patch_i_value, patch_j_value, init_enable);
end


// ===== golden data for patch verification ===== //
// For SRAM A (24-bit RGB)
reg [BW_PER_ADDR_A-1:0] golden_bank_a0 [0:255];
reg [BW_PER_ADDR_A-1:0] golden_bank_a1 [0:255];
reg [BW_PER_ADDR_A-1:0] golden_bank_a2 [0:255];
reg [BW_PER_ADDR_A-1:0] golden_bank_a3 [0:255];
// For SRAM B (fp64 single channel) 
reg [BW_PER_ADDR_B-1:0] golden_bank_b0 [0:255];
reg [BW_PER_ADDR_B-1:0] golden_bank_b1 [0:255];
reg [BW_PER_ADDR_B-1:0] golden_bank_b2 [0:255];
reg [BW_PER_ADDR_B-1:0] golden_bank_b3 [0:255];


// ===== module I/O ===== //
reg clk;
reg rst_n;
reg enable;
wire done;

// SRAM A signals
wire sram_wen_a0;
wire sram_wen_a1;
wire sram_wen_a2;
wire sram_wen_a3;
wire [BW_PER_ADDR_A-1:0] sram_rdata_a0;
wire [BW_PER_ADDR_A-1:0] sram_rdata_a1;
wire [BW_PER_ADDR_A-1:0] sram_rdata_a2;
wire [BW_PER_ADDR_A-1:0] sram_rdata_a3;
wire [SRAM_ADDR_WIDTH_A-1:0] sram_addr_a0;
wire [SRAM_ADDR_WIDTH_A-1:0] sram_addr_a1;
wire [SRAM_ADDR_WIDTH_A-1:0] sram_addr_a2;
wire [SRAM_ADDR_WIDTH_A-1:0] sram_addr_a3;
wire [BW_PER_ADDR_A-1:0] sram_wdata_a0;
wire [BW_PER_ADDR_A-1:0] sram_wdata_a1;
wire [BW_PER_ADDR_A-1:0] sram_wdata_a2;
wire [BW_PER_ADDR_A-1:0] sram_wdata_a3;

// SRAM B signals
wire sram_wen_b0;
wire sram_wen_b1;
wire sram_wen_b2;
wire sram_wen_b3;
wire [BW_PER_ADDR_B-1:0] sram_rdata_b0;
wire [BW_PER_ADDR_B-1:0] sram_rdata_b1;
wire [BW_PER_ADDR_B-1:0] sram_rdata_b2;
wire [BW_PER_ADDR_B-1:0] sram_rdata_b3;
wire [SRAM_ADDR_WIDTH_B-1:0] sram_addr_b0;
wire [SRAM_ADDR_WIDTH_B-1:0] sram_addr_b1;
wire [SRAM_ADDR_WIDTH_B-1:0] sram_addr_b2;
wire [SRAM_ADDR_WIDTH_B-1:0] sram_addr_b3;
wire [BW_PER_ADDR_B-1:0] sram_wdata_b0;
wire [BW_PER_ADDR_B-1:0] sram_wdata_b1;
wire [BW_PER_ADDR_B-1:0] sram_wdata_b2;
wire [BW_PER_ADDR_B-1:0] sram_wdata_b3;

// SRAM I signals
wire sram_wen_i0;
wire sram_wen_i1;
wire sram_wen_i2;
wire sram_wen_i3;
wire [BW_PER_ADDR_I-1:0] sram_rdata_i0;
wire [BW_PER_ADDR_I-1:0] sram_rdata_i1;
wire [BW_PER_ADDR_I-1:0] sram_rdata_i2;
wire [BW_PER_ADDR_I-1:0] sram_rdata_i3;
wire [SRAM_ADDR_WIDTH_I-1:0] sram_addr_i0;
wire [SRAM_ADDR_WIDTH_I-1:0] sram_addr_i1;
wire [SRAM_ADDR_WIDTH_I-1:0] sram_addr_i2;
wire [SRAM_ADDR_WIDTH_I-1:0] sram_addr_i3;
wire [BW_PER_ADDR_I-1:0] sram_wdata_i0;
wire [BW_PER_ADDR_I-1:0] sram_wdata_i1;
wire [BW_PER_ADDR_I-1:0] sram_wdata_i2;
wire [BW_PER_ADDR_I-1:0] sram_wdata_i3;

// Instantiate IEC RTL module
IEC_top #(
    .BW_PER_ADDR_A(BW_PER_ADDR_A),
    .BW_PER_ADDR_B(BW_PER_ADDR_B),
    .ADDR_WIDTH_A(SRAM_ADDR_WIDTH_A),
    .ADDR_WIDTH_B(SRAM_ADDR_WIDTH_B) 
)U_IEC(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable), 
    .done(done),
    
    .sram_wen_a0(sram_wen_a0),
    .sram_wen_a1(sram_wen_a1),
    .sram_wen_a2(sram_wen_a2),
    .sram_wen_a3(sram_wen_a3),

    .sram_addr_a0(sram_addr_a0),
    .sram_addr_a1(sram_addr_a1),
    .sram_addr_a2(sram_addr_a2),
    .sram_addr_a3(sram_addr_a3),
    
    .sram_wdata_a0(sram_wdata_a0),
    .sram_wdata_a1(sram_wdata_a1),
    .sram_wdata_a2(sram_wdata_a2),
    .sram_wdata_a3(sram_wdata_a3),

    .sram_rdata_a0(sram_rdata_a0),
    .sram_rdata_a1(sram_rdata_a1),
    .sram_rdata_a2(sram_rdata_a2),
    .sram_rdata_a3(sram_rdata_a3),
    
    // SRAM B
    .sram_wen_b0(sram_wen_b0),
    .sram_wen_b1(sram_wen_b1),
    .sram_wen_b2(sram_wen_b2),
    .sram_wen_b3(sram_wen_b3),

    .sram_addr_b0(sram_addr_b0),
    .sram_addr_b1(sram_addr_b1),
    .sram_addr_b2(sram_addr_b2),
    .sram_addr_b3(sram_addr_b3),
    
    .sram_wdata_b0(sram_wdata_b0),
    .sram_wdata_b1(sram_wdata_b1),
    .sram_wdata_b2(sram_wdata_b2),
    .sram_wdata_b3(sram_wdata_b3),

    .sram_rdata_b0(sram_rdata_b0),
    .sram_rdata_b1(sram_rdata_b1),
    .sram_rdata_b2(sram_rdata_b2),
    .sram_rdata_b3(sram_rdata_b3),

    // SRAM I
    .sram_wen_i0(sram_wen_i0),
    .sram_wen_i1(sram_wen_i1),
    .sram_wen_i2(sram_wen_i2),
    .sram_wen_i3(sram_wen_i3),

    .sram_addr_i0(sram_addr_i0),
    .sram_addr_i1(sram_addr_i1),
    .sram_addr_i2(sram_addr_i2),
    .sram_addr_i3(sram_addr_i3),
    
    .sram_wdata_i0(sram_wdata_i0),
    .sram_wdata_i1(sram_wdata_i1),
    .sram_wdata_i2(sram_wdata_i2),
    .sram_wdata_i3(sram_wdata_i3),

    .sram_rdata_i0(sram_rdata_i0),
    .sram_rdata_i1(sram_rdata_i1),
    .sram_rdata_i2(sram_rdata_i2),
    .sram_rdata_i3(sram_rdata_i3)
    
);


// ===== sram connection ===== //
// SRAM for LAYER1: input_image (sram_a)
sram_256x3b #(
    .BW_PER_ADDR(BW_PER_ADDR_A),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_A)
) sram_a(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_a0), 
    .wsb_1(sram_wen_a1), 
    .wsb_2(sram_wen_a2), 
    .wsb_3(sram_wen_a3), 

    .wdata_0(sram_wdata_a0), 
    .wdata_1(sram_wdata_a1), 
    .wdata_2(sram_wdata_a2), 
    .wdata_3(sram_wdata_a3), 

    .waddr_0(sram_addr_a0),  
    .waddr_1(sram_addr_a1), 
    .waddr_2(sram_addr_a2), 
    .waddr_3(sram_addr_a3), 
    
    .raddr_0(sram_addr_a0),  
    .raddr_1(sram_addr_a1), 
    .raddr_2(sram_addr_a2), 
    .raddr_3(sram_addr_a3), 

    .rdata_0(sram_rdata_a0),
    .rdata_1(sram_rdata_a1),
    .rdata_2(sram_rdata_a2),
    .rdata_3(sram_rdata_a3)
);

// SRAM I(32x32x8b)

// SRAM for LAYER2: initial_illum_map (sram_b)
sram_256x8b #(
    .BW_PER_ADDR(BW_PER_ADDR_B),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_B)
) sram_b(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_b0), 
    .wsb_1(sram_wen_b1), 
    .wsb_2(sram_wen_b2), 
    .wsb_3(sram_wen_b3), 

    .wdata_0(sram_wdata_b0), 
    .wdata_1(sram_wdata_b1), 
    .wdata_2(sram_wdata_b2), 
    .wdata_3(sram_wdata_b3), 

    .waddr_0(sram_addr_b0),  
    .waddr_1(sram_addr_b1), 
    .waddr_2(sram_addr_b2), 
    .waddr_3(sram_addr_b3), 
    
    .raddr_0(sram_addr_b0),  
    .raddr_1(sram_addr_b1), 
    .raddr_2(sram_addr_b2), 
    .raddr_3(sram_addr_b3), 

    .rdata_0(sram_rdata_b0),
    .rdata_1(sram_rdata_b1),
    .rdata_2(sram_rdata_b2),
    .rdata_3(sram_rdata_b3)
);

// SRAM for LAYER2: initial_illum_map (sram_b)
sram_256x8b #(
    .BW_PER_ADDR(BW_PER_ADDR_I),
    .ADDR_WIDTH(SRAM_ADDR_WIDTH_I)
) sram_i(
    .clk(clk), 
    .csb(1'b0), 
    
    .wsb_0(sram_wen_i0), 
    .wsb_1(sram_wen_i1), 
    .wsb_2(sram_wen_i2), 
    .wsb_3(sram_wen_i3), 

    .wdata_0(sram_wdata_i0), 
    .wdata_1(sram_wdata_i1), 
    .wdata_2(sram_wdata_i2), 
    .wdata_3(sram_wdata_i3), 

    .waddr_0(sram_addr_i0),  
    .waddr_1(sram_addr_i1), 
    .waddr_2(sram_addr_i2), 
    .waddr_3(sram_addr_i3), 
    
    .raddr_0(sram_addr_i0),  
    .raddr_1(sram_addr_i1), 
    .raddr_2(sram_addr_i2), 
    .raddr_3(sram_addr_i3), 

    .rdata_0(sram_rdata_i0),
    .rdata_1(sram_rdata_i1),
    .rdata_2(sram_rdata_i2),
    .rdata_3(sram_rdata_i3)
);


// ===== waveform dumpping ===== //
initial begin
    if(`FLAG_DUMPWV)begin
        $fsdbDumpfile("IMC.fsdb");
        $fsdbDumpvars("+mda");
    end
end

// ===== system reset ===== //
initial begin
    clk = 0;
    rst_n = 0;
    enable = 0;
    
    #(`CYCLE * 5);
    
    // Initialize SRAM 
    if(layer_value == 1) begin // Layer 1: input_image
        // Initialize sramA
        $display("Initializing SRAM A (input_image)");
        sram_a.load_dat(pat_value, 1, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
        #(`CYCLE * 5);
        
        // Load golden data for comparison
        load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
        
        #(`CYCLE * 5);
        
        // Compare 
        compare_load();
        
        // Finish simulation after comparison
        $display("\nSimulation completed successfully!");
        $finish;
        
    end else if(layer_value == 2) begin // Layer 2: initial_illum_map 
        if(init_enable == 1) begin // INIT_EN = 1: Initialize mode
            $display("Initializing SRAM B (initial_illum_map)");
            sram_a.load_dat(pat_value, 1, patch_i_value, patch_j_value);
            sram_b.load_dat(pat_value, 2, patch_i_value, patch_j_value); // (PAT, LAYER, PATCH_I, PATCH_J)
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=1: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
            
        end else begin // INIT_EN = 0: Hardware mode
            // Initialize sramA 
            sram_a.load_dat(pat_value, 1, patch_i_value, patch_j_value);
            
            @(posedge clk); rst_n = 1;
            @(posedge clk); enable = 1;
            $display("Starting IEC processing");
            
            // Wait for done 
            wait(done);
            #(`CYCLE * 5);
            
            // Load golden data for comparison
            load_golden(pat_value, layer_value, patch_i_value, patch_j_value);
            #(`CYCLE * 5);
            
            // Compare 
            compare_load();
            
            // INIT_EN=0: Finish simulation after comparison
            $display("\nSimulation completed successfully!");
            $finish;
        end
    end
end

// ===== Clock generation ===== //
initial begin
    while(1) #(`CYCLE/2) clk = ~clk;
end

initial begin
  #(`CYCLE * `END_CYCLES);
    $display("\n========================================================");
    $display("   Error!!! Simulation time is too long...            ");
    $display("   There might be something wrong in your code.       ");
    $display("   If your design really needs such a long time,      ");
    $display("   increase the END_CYCLES setting in the testbench.  ");
    $display("========================================================");
    $finish;
end


// ===== Load golden data from BMP file ===== //
task load_golden;
    input [7:0] PAT;        // "1" for lime1, "2" for lime2
    input [31:0] LAYER;     // 1~5
    input [31:0] PATCH_I;   // patch row index (0-27)
    input [31:0] PATCH_J;   // patch column index (0-27)

    integer row, col, addr, file_in;
    integer i;
    reg [196*8-1:0] bmp_filepath;
    reg [7:0] r, g, b;  // RGB components
    reg [23:0] pixel_data;
    reg [7:0] patch_i_str [0:1];
    reg [7:0] patch_j_str [0:1];
    real pixel_val_fp64;  // For fp64 conversion

begin
    patch_i_str[0] = ((PATCH_I / 10) % 10) + "0";
    patch_i_str[1] = (PATCH_I % 10) + "0";
    patch_j_str[0] = ((PATCH_J / 10) % 10) + "0";
    patch_j_str[1] = (PATCH_J % 10) + "0";
    
   // filepath
    if(PAT == "1") begin // PAT == "1" (imgs_lime1)
        case(LAYER)
            1: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/input_image/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            2: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/initial_illum_map/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            3: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/refined_illum_map/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            4: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/gamma_illum_map/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            5: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/enhanced_image/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            default: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/unknown_layer/patch_%c%c_%c%c_under.bmp",
                              patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
        endcase
    end else begin  // PAT == "2" (imgs_lime2)
        case(LAYER)
            1: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/input_image/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            2: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/initial_illum_map/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            3: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/refined_illum_map/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            4: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/gamma_illum_map/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            5: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/enhanced_image/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            default: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/unknown_layer/patch_%c%c_%c%c_over.bmp",
                              patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
        endcase
    end

    file_in = $fopen(bmp_filepath, "rb");
    if(file_in == 0) begin
        $display("Error: Cannot open %s", bmp_filepath);
        disable load_golden;
    end

    if(LAYER == 1) begin
        // Skip 54-byte header 
        for(i = 0; i < 54; i = i + 1)
            r = $fgetc(file_in);
        
        // addr : 0~255
        addr = 0;
        for(row = 31; row >= 0; row = row - 1) begin  // BMP bottom-up
            for(col = 0; col < 32; col = col + 4) begin  // 4 pixel -> 4 bank
                // bmp order: B-> G -> R
                // pixel0 -> golden_bank_a0
                b = $fgetc(file_in);
                g = $fgetc(file_in);
                r = $fgetc(file_in);
                pixel_data = {r, g, b};
                golden_bank_a0[addr] = pixel_data;

                // pixel1 -> golden_bank_a1
                b = $fgetc(file_in);
                g = $fgetc(file_in);
                r = $fgetc(file_in);
                pixel_data = {r, g, b};
                golden_bank_a1[addr] = pixel_data;

                // pixel2 -> golden_bank_a2
                b = $fgetc(file_in);
                g = $fgetc(file_in);
                r = $fgetc(file_in);
                pixel_data = {r, g, b};
                golden_bank_a2[addr] = pixel_data;

                // pixel3 -> golden_bank_a3
                b = $fgetc(file_in);
                g = $fgetc(file_in);
                r = $fgetc(file_in);
                pixel_data = {r, g, b};
                golden_bank_a3[addr] = pixel_data;

                addr = addr + 1;
            end
        end
    end else begin
        // Skip header (54 bytes + 256*4 palette = 1078 bytes)
        for(i = 0; i < 1078; i = i + 1)
            r = $fgetc(file_in);
        
        // addr : 0~255
        addr = 0;
        for(row = 31; row >= 0; row = row - 1) begin  // BMP bottom-up
            for(col = 0; col < 32; col = col + 4) begin  // 4 pixel -> 4 bank
                // pixel0 -> golden_bank_b0 
                r = $fgetc(file_in);
                golden_bank_b0[addr] = r;  

                // pixel1 -> golden_bank_b1 
                r = $fgetc(file_in);
                golden_bank_b1[addr] = r;  

                // pixel2 -> golden_bank_b2 
                r = $fgetc(file_in);
                golden_bank_b2[addr] = r;  

                // pixel3 -> golden_bank_b3 
                r = $fgetc(file_in);
                golden_bank_b3[addr] = r; 

                addr = addr + 1;
            end
        end
    end

    $fclose(file_in);
end
endtask

// ===== Compare SRAM data with golden data ===== //
task compare_load;
    integer addr;
    integer bank_errors [0:3];
    integer total_errors;
    real sram_val_fp64;  // For fp64 conversion from sramB (layer 2)
    integer golden_val_uint8, sram_val_uint8;  // For uint8 comparison (layer 2)
    integer del;
begin
    total_errors = 0;
    bank_errors[0] = 0;
    bank_errors[1] = 0;
    bank_errors[2] = 0;
    bank_errors[3] = 0;
    del = 2;
    
    if(layer_value == 1) begin
        // Layer 1: Compare SRAM A (24-bit RGB)
        $display("\nSRAM A - Bank 0 Comparison (Address 0-255):");
        $display("Addr | Golden (R G B) | SRAM (R G B) | Match");
        $display("-----|----------------|--------------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            if(sram_a.bank0[addr] !== golden_bank_a0[addr]) begin
                bank_errors[0] = bank_errors[0] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | FAIL", 
                    addr,
                    golden_bank_a0[addr][23:16], golden_bank_a0[addr][15:8], golden_bank_a0[addr][7:0], golden_bank_a0[addr],
                    sram_a.bank0[addr][23:16], sram_a.bank0[addr][15:8], sram_a.bank0[addr][7:0], sram_a.bank0[addr]);
            end else begin
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | OK", 
                    addr,
                    golden_bank_a0[addr][23:16], golden_bank_a0[addr][15:8], golden_bank_a0[addr][7:0], golden_bank_a0[addr],
                    sram_a.bank0[addr][23:16], sram_a.bank0[addr][15:8], sram_a.bank0[addr][7:0], sram_a.bank0[addr]);
            end
        end
    
        $display("\nBank 1 Comparison (Address 0-255):");
        $display("Addr | Golden (R G B) | SRAM (R G B) | Match");
        $display("-----|----------------|--------------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            if(sram_a.bank1[addr] !== golden_bank_a1[addr]) begin
                bank_errors[1] = bank_errors[1] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | FAIL", 
                    addr,
                    golden_bank_a1[addr][23:16], golden_bank_a1[addr][15:8], golden_bank_a1[addr][7:0], golden_bank_a1[addr],
                    sram_a.bank1[addr][23:16], sram_a.bank1[addr][15:8], sram_a.bank1[addr][7:0], sram_a.bank1[addr]);
            end else begin
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | OK", 
                    addr,
                    golden_bank_a1[addr][23:16], golden_bank_a1[addr][15:8], golden_bank_a1[addr][7:0], golden_bank_a1[addr],
                    sram_a.bank1[addr][23:16], sram_a.bank1[addr][15:8], sram_a.bank1[addr][7:0], sram_a.bank1[addr]);
            end
        end
        
        $display("\nBank 2 Comparison (Address 0-255):");
        $display("Addr | Golden (R G B) | SRAM (R G B) | Match");
        $display("-----|----------------|--------------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            if(sram_a.bank2[addr] !== golden_bank_a2[addr]) begin
                bank_errors[2] = bank_errors[2] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | FAIL", 
                    addr,
                    golden_bank_a2[addr][23:16], golden_bank_a2[addr][15:8], golden_bank_a2[addr][7:0], golden_bank_a2[addr],
                    sram_a.bank2[addr][23:16], sram_a.bank2[addr][15:8], sram_a.bank2[addr][7:0], sram_a.bank2[addr]);
            end else begin
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | OK", 
                    addr,
                    golden_bank_a2[addr][23:16], golden_bank_a2[addr][15:8], golden_bank_a2[addr][7:0], golden_bank_a2[addr],
                    sram_a.bank2[addr][23:16], sram_a.bank2[addr][15:8], sram_a.bank2[addr][7:0], sram_a.bank2[addr]);
            end
        end
        
        $display("\nBank 3 Comparison (Address 0-255):");
        $display("Addr | Golden (R G B) | SRAM (R G B) | Match");
        $display("-----|----------------|--------------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            if(sram_a.bank3[addr] !== golden_bank_a3[addr]) begin
                bank_errors[3] = bank_errors[3] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | FAIL", 
                    addr,
                    golden_bank_a3[addr][23:16], golden_bank_a3[addr][15:8], golden_bank_a3[addr][7:0], golden_bank_a3[addr],
                    sram_a.bank3[addr][23:16], sram_a.bank3[addr][15:8], sram_a.bank3[addr][7:0], sram_a.bank3[addr]);
            end else begin
                $display("%4d | %3d %3d %3d (%06h) | %3d %3d %3d (%06h) | OK", 
                    addr,
                    golden_bank_a3[addr][23:16], golden_bank_a3[addr][15:8], golden_bank_a3[addr][7:0], golden_bank_a3[addr],
                    sram_a.bank3[addr][23:16], sram_a.bank3[addr][15:8], sram_a.bank3[addr][7:0], sram_a.bank3[addr]);
            end
        end
        
        // Summary
        $display("\n========================================================================");
        $display("Comparison Summary:");
        $display("  Bank 0 errors: %0d / 256", bank_errors[0]);
        $display("  Bank 1 errors: %0d / 256", bank_errors[1]);
        $display("  Bank 2 errors: %0d / 256", bank_errors[2]);
        $display("  Bank 3 errors: %0d / 256", bank_errors[3]);
        $display("  Total errors:  %0d / 1024", total_errors);
        
        if(total_errors == 0) begin
            $display("SUCCESS! All 1024 pixels match correctly!");
            $display("load_dat task loaded data successfully!");
        end else begin
            $display("FAIL! Found %0d errors out of 1024 pixels", total_errors);
            $display("load_dat task may have issues!");
        end
        $display("========================================================================");
    end else if(layer_value == 2) begin
        // Layer 2: Compare SRAM B (64-bit fp64, single channel)
        $display("\nSRAM B - Bank 0 Comparison (Address 0-255, fp64 IEEE754 -> uint8):");
        $display("Addr | Golden (IEEE754 fp64) | SRAM (IEEE754 fp64) | uint8 | Match");
        $display("-----|----------------------|---------------------|-------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            // golden_bank_b0 stores uint8 (0-255) directly, no conversion needed
            golden_val_uint8 = golden_bank_b0[addr];
            // Convert sramB fp64 (0.0-1.0) to uint8 (0-255) for comparison
            sram_val_fp64 = $bitstoreal(sram_b.bank0[addr]);
            sram_val_uint8 = $rtoi(sram_val_fp64 * 255.0);
            // Compare uint8 values
            
            if((golden_val_uint8 - del < sram_val_uint8) && (sram_val_uint8 < golden_val_uint8 + del)) begin
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | OK", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank0[addr]), sram_val_uint8);
            end else begin
                bank_errors[0] = bank_errors[0] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | FAIL", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank0[addr]), sram_val_uint8);
            end
        end
        
        $display("\nBank 1 Comparison (Address 0-255, fp64 IEEE754 -> uint8):");
        $display("Addr | Golden (uint8) | SRAM (IEEE754 fp64) | uint8 | Match");
        $display("-----|---------------|---------------------|-------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            // golden_bank_b1 stores uint8 (0-255) directly, no conversion needed
            golden_val_uint8 = golden_bank_b1[addr];
            // Convert sramB fp64 (0.0-1.0) to uint8 (0-255) for comparison
            sram_val_fp64 = $bitstoreal(sram_b.bank1[addr]);
            sram_val_uint8 = $rtoi(sram_val_fp64 * 255.0);
            // Compare uint8 values
            if((golden_val_uint8 - del < sram_val_uint8) && (sram_val_uint8 < golden_val_uint8 + del)) begin
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | OK", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank1[addr]), sram_val_uint8);
            end else begin
                bank_errors[1] = bank_errors[1] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | FAIL", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank1[addr]), sram_val_uint8);
            end
        end
        
        $display("\nBank 2 Comparison (Address 0-255, fp64 IEEE754 -> uint8):");
        $display("Addr | Golden (uint8) | SRAM (IEEE754 fp64) | uint8 | Match");
        $display("-----|---------------|---------------------|-------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            // golden_bank_b2 stores uint8 (0-255) directly, no conversion needed
            golden_val_uint8 = golden_bank_b2[addr];
            // Convert sramB fp64 (0.0-1.0) to uint8 (0-255) for comparison
            sram_val_fp64 = $bitstoreal(sram_b.bank2[addr]);
            sram_val_uint8 = $rtoi(sram_val_fp64 * 255.0);
            // Compare uint8 values
            if((golden_val_uint8 - del < sram_val_uint8) && (sram_val_uint8 < golden_val_uint8 + del)) begin
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | OK", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank2[addr]), sram_val_uint8);
            end else begin
                bank_errors[2] = bank_errors[2] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | FAIL", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank2[addr]), sram_val_uint8);
            end
        end
        
        $display("\nBank 3 Comparison (Address 0-255, fp64 IEEE754 -> uint8):");
        $display("Addr | Golden (uint8) | SRAM (IEEE754 fp64) | uint8 | Match");
        $display("-----|---------------|---------------------|-------|------");
        for(addr = 0; addr < 256; addr = addr + 1) begin
            // golden_bank_b3 stores uint8 (0-255) directly, no conversion needed
            golden_val_uint8 = golden_bank_b3[addr];
            // Convert sramB fp64 (0.0-1.0) to uint8 (0-255) for comparison
            sram_val_fp64 = $bitstoreal(sram_b.bank3[addr]);
            sram_val_uint8 = $rtoi(sram_val_fp64 * 255.0);
            // Compare uint8 values
            if((golden_val_uint8 - del < sram_val_uint8) && (sram_val_uint8 < golden_val_uint8 + del)) begin
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | OK", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank3[addr]), sram_val_uint8);
            end else begin
                bank_errors[3] = bank_errors[3] + 1;
                total_errors = total_errors + 1;
                $display("%4d | %3d (uint8) | %3.17f -> %3d (uint8) | FAIL", 
                    addr, golden_val_uint8, $bitstoreal(sram_b.bank3[addr]), sram_val_uint8);
            end
        end
        
        // Summary
        $display("\n========================================================================");
        $display("Comparison Summary:");
        $display("  Bank 0 errors: %0d / 256", bank_errors[0]);
        $display("  Bank 1 errors: %0d / 256", bank_errors[1]);
        $display("  Bank 2 errors: %0d / 256", bank_errors[2]);
        $display("  Bank 3 errors: %0d / 256", bank_errors[3]);
        $display("  Total errors:  %0d / 1024", total_errors);
        
        if(total_errors == 0) begin
            $display("SUCCESS! All 1024 pixels match correctly!");
            $display("load_dat task loaded data successfully!");
        end else begin
            $display("FAIL! Found %0d errors out of 1024 pixels", total_errors);
            $display("load_dat task may have issues!");
        end
        $display("========================================================================");
    end
end
endtask

endmodule