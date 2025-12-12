module sram_256x8b #(
    parameter BW_PER_ADDR = 64,
    parameter ADDR_WIDTH = 8  
)(
    input clk,
    input csb,      // chip enable (active low)

    // write enable (active low = write)
    input wsb_0,    
    input wsb_1,    
    input wsb_2,    
    input wsb_3, 

    // write data
    input [BW_PER_ADDR-1:0] wdata_0,  
    input [BW_PER_ADDR-1:0] wdata_1,  
    input [BW_PER_ADDR-1:0] wdata_2,  
    input [BW_PER_ADDR-1:0] wdata_3,  

    // write address
    input [ADDR_WIDTH-1:0] waddr_0,   
    input [ADDR_WIDTH-1:0] waddr_1,   
    input [ADDR_WIDTH-1:0] waddr_2,   
    input [ADDR_WIDTH-1:0] waddr_3,   

    // read address
    input [ADDR_WIDTH-1:0] raddr_0,   
    input [ADDR_WIDTH-1:0] raddr_1,   
    input [ADDR_WIDTH-1:0] raddr_2,   
    input [ADDR_WIDTH-1:0] raddr_3,   

    // read data
    output reg [BW_PER_ADDR-1:0] rdata_0,  
    output reg [BW_PER_ADDR-1:0] rdata_1,  
    output reg [BW_PER_ADDR-1:0] rdata_2,  
    output reg [BW_PER_ADDR-1:0] rdata_3   
);

    // Memory array
    localparam MEM_DEPTH = 1 << ADDR_WIDTH;  // 2^ADDR_WIDTH = 256
    reg [BW_PER_ADDR-1:0] bank0 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank1 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank2 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank3 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] _rdata_0, _rdata_1, _rdata_2, _rdata_3;

    // Write 
    always @(posedge clk) begin
        if (~csb && ~wsb_0) begin
            bank0[waddr_0] <= wdata_0;
        end
        if (~csb && ~wsb_1) begin
            bank1[waddr_1] <= wdata_1;
        end
        if (~csb && ~wsb_2) begin
            bank2[waddr_2] <= wdata_2;
        end
        if (~csb && ~wsb_3) begin
            bank3[waddr_3] <= wdata_3;
        end
    end

    // Read 
    always @(posedge clk) begin
        if (~csb) begin
            _rdata_0 <= bank0[raddr_0];
            _rdata_1 <= bank1[raddr_1];
            _rdata_2 <= bank2[raddr_2];
            _rdata_3 <= bank3[raddr_3];
        end
    end

    // Output read data
    always @* begin
        rdata_0 = _rdata_0;
        rdata_1 = _rdata_1;
        rdata_2 = _rdata_2;
        rdata_3 = _rdata_3;
    end


//-------------------- task --------------------
// Task to load data directly into memory 
// Initialization each layer, mainly init layer
task load_dat;
    input [7:0] PAT;        // "lime1" or "lime2"
    input [31:0] LAYER;     // 1~5
    input [31:0] PATCH_I;   // patch row index (0-27)
    input [31:0] PATCH_J;   // patch column index (0-27)

    integer row, col, addr, file_in;
    integer i;
    reg [196*8-1:0] bmp_filepath;
    reg [32*8-1:0] layer_name;
    reg [7:0] r, g, b;  // RGB components
    reg [23:0] pixel_data;
    reg [7:0] patch_i_str [0:1];
    reg [7:0] patch_j_str [0:1];
    real pixel_val_fp64;  // For fp64 conversion (used in layer 2-5)
    
begin
    // Format patch indices with leading zeros (00-99)
    patch_i_str[0] = ((PATCH_I / 10) % 10) + "0";
    patch_i_str[1] = (PATCH_I % 10) + "0";
    patch_j_str[0] = ((PATCH_J / 10) % 10) + "0";
    patch_j_str[1] = (PATCH_J % 10) + "0";
    
    // Build file path directly based on LAYER and PAT to avoid string padding issues
    if(PAT == "1") begin
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
    end else begin  // PAT == "2"
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
    
    $display("Loading %s", bmp_filepath);

    file_in = $fopen(bmp_filepath, "rb");
    if(file_in == 0) begin
        $display("Error: Cannot open %s", bmp_filepath);
        disable load_dat;
    end

    // Skip BMP header 
    if(LAYER == 1) begin
        for(i = 0; i < 54; i = i + 1)
            r = $fgetc(file_in);
    end else begin
        for(i = 0; i < 1078; i = i + 1)
            r = $fgetc(file_in);
    end
    
    // addr : 0~255
    addr = 0;
    for(row = 31; row >= 0; row = row - 1) begin  // BMP bottom-up
        for(col = 0; col < 32; col = col + 4) begin  // 4 pixel -> 4 bank
            // Convert each uint8 (0-255) to fp64 (0.0-1.0) using IEEE 754 double precision format
            // pixel0 -> bank0
            r = $fgetc(file_in);
            pixel_val_fp64 = r / 255.0;  // Convert uint8 to float64 (0.0-1.0)
            bank0[addr] = $realtobits(pixel_val_fp64);  // Convert to IEEE 754 double (64-bit)

            // pixel1 -> bank1
            r = $fgetc(file_in);
            pixel_val_fp64 = r / 255.0;  
            bank1[addr] = $realtobits(pixel_val_fp64);  

            // pixel2 -> bank2
            r = $fgetc(file_in);
            pixel_val_fp64 = r / 255.0;  
            bank2[addr] = $realtobits(pixel_val_fp64);  

            // pixel3 -> bank3
            r = $fgetc(file_in);
            pixel_val_fp64 = r / 255.0;  
            bank3[addr] = $realtobits(pixel_val_fp64);  

            addr = addr + 1;
        end
    end

    $fclose(file_in);
    $display("Finished loading %s into 4 banks", bmp_filepath);
end
endtask

endmodule