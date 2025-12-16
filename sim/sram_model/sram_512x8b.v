module sram_512x8b #(
    parameter BW_PER_ADDR = 64,
    parameter ADDR_WIDTH = 9  
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
    localparam MEM_DEPTH = 1 << ADDR_WIDTH;  // 2^ADDR_WIDTH = 512
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
// Initialization each layer
task load_dat;
    input [7:0] PAT;        // "lime1" or "lime2"
    input [31:0] LAYER;     // 1~17
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
    real pixel_val_fp64;  // For fp64 conversion
    integer hex_char;
    reg [7:0] hex_line [0:15];  // 16 characters for hex string
    reg [63:0] hex_value;
    integer char_idx;
    integer nibble_val;
    reg [63:0] data_byte;
    
begin
    // Format patch indices with leading zeros (00-99)
    patch_i_str[0] = ((PATCH_I / 10) % 10) + "0";
    patch_i_str[1] = (PATCH_I % 10) + "0";
    patch_j_str[0] = ((PATCH_J / 10) % 10) + "0";
    patch_j_str[1] = (PATCH_J % 10) + "0";
    
    // Build file path directly based on LAYER and PAT to avoid string padding issues
    if(PAT == "1") begin
        case(LAYER)
            1 : $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/input_image/patch_%c%c_%c%c_under.bmp",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            2 : $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/initial_illum_map/patch_%c%c_%c%c_under.bmp",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);

            3 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramU_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            4 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramW_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            5 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramX_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            6 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramE_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            7 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramT_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            8 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramE_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            9 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramC_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            10: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramT_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            11: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramX_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            12: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramG_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            13: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramU_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            14: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_under/iter_000/sramZ_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            
            16: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/refined_illum_map/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            17: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/gamma_illum_map/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            18: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/enhanced_image/patch_%c%c_%c%c_under.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            default: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime1/unknown_layer/patch_%c%c_%c%c_under.bmp",
                              patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
        endcase
    end else begin  // PAT == "2"
        case(LAYER)
            1 : $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/input_image/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            2 : $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/initial_illum_map/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            
            3 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramU_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            4 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramW_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            5 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramX_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            6 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramE_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            7 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramT_1.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            8 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramE_2.dat",
                         patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            9 : $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramC_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            10: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramT_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            11: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramX_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            12: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramG_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            13: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramU_2.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            14: $sformat(bmp_filepath, "../py/py_overlap_partition/alm/patch_%c%c_%c%c_over/iter_000/sramZ_1.dat",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);

            16: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/refined_illum_map/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            17: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/gamma_illum_map/patch_%c%c_%c%c_over.bmp",
                        patch_i_str[0], patch_i_str[1], patch_j_str[0], patch_j_str[1]);
            18: $sformat(bmp_filepath, "../py/py_overlap_partition/imgs_lime2/enhanced_image/patch_%c%c_%c%c_over.bmp",
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

    // For .dat files, read binary data directly (64-bit fp64)
    // For .bmp files, skip header and convert
    if(LAYER <= 2) begin
        // BMP file: Skip header
        if(LAYER == 1) begin
            for(i = 0; i < 54; i = i + 1)
                r = $fgetc(file_in);
        end else begin
            for(i = 0; i < 1078; i = i + 1)
                r = $fgetc(file_in);
        end
        
        // addr : 0~255 (256 addresses for 32x32 image = 1024 pixels, 4 banks)
        // For 32x32 = 1024 pixels, with 4 banks we have 256 addresses per bank
        // Each address stores 4 pixels (one from each bank)
        addr = 0;
        for(row = 31; row >= 0; row = row - 1) begin  // BMP bottom-up
            for(col = 0; col < 32; col = col + 4) begin  // 4 pixel -> 4 bank
                if(addr < 256) begin  // Only read 256 addresses for 32x32 image
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
        end
    end else begin
        // .dat file: Read ASCII text file, each line is a 16-character hex string (64-bit)
        // File format: One hex string per line (e.g., "0000000000000000" or "4085122654878d59")
        
        addr = 0;
        while(addr < MEM_DEPTH && !$feof(file_in)) begin
            // Read 16 hex characters for bank0
            char_idx = 0;
            while(char_idx < 16) begin
                hex_char = $fgetc(file_in);
                if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin  // EOF, LF, or CR
                    if(addr == 0 && char_idx == 0) begin
                        disable load_dat;  // Empty file
                    end
                    // Pad remaining with '0'
                    for(i = char_idx; i < 16; i = i + 1) begin
                        hex_line[i] = "0";
                    end
                    char_idx = 16;  // Exit loop
                end else begin
                    hex_line[char_idx] = hex_char;
                    char_idx = char_idx + 1;
                end
            end
            // Skip newline if present (should be after 16 hex chars)
            hex_char = $fgetc(file_in);
            // If it's not a newline, we've already read too much - continue anyway
            
            // Convert hex string to 64-bit value manually
            hex_value = 64'h0;
            for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                    nibble_val = hex_line[char_idx] - "0";
                end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                    nibble_val = hex_line[char_idx] - "a" + 10;
                end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                    nibble_val = hex_line[char_idx] - "A" + 10;
                end else begin
                    nibble_val = 0;
                end
                hex_value = (hex_value << 4) | nibble_val;
            end
            bank0[addr] = hex_value;
            
            // Read 16 hex characters for bank1
            char_idx = 0;
            while(char_idx < 16) begin
                hex_char = $fgetc(file_in);
                if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                    for(i = char_idx; i < 16; i = i + 1) begin
                        hex_line[i] = "0";
                    end
                    char_idx = 16;  // Exit loop
                end else begin
                    hex_line[char_idx] = hex_char;
                    char_idx = char_idx + 1;
                end
            end
            hex_char = $fgetc(file_in);
            // If it's not a newline, we've already read too much - continue anyway
            hex_value = 64'h0;
            for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                    nibble_val = hex_line[char_idx] - "0";
                end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                    nibble_val = hex_line[char_idx] - "a" + 10;
                end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                    nibble_val = hex_line[char_idx] - "A" + 10;
                end else begin
                    nibble_val = 0;
                end
                hex_value = (hex_value << 4) | nibble_val;
            end
            bank1[addr] = hex_value;
            
            // Read 16 hex characters for bank2
            char_idx = 0;
            while(char_idx < 16) begin
                hex_char = $fgetc(file_in);
                if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                    for(i = char_idx; i < 16; i = i + 1) begin
                        hex_line[i] = "0";
                    end
                    char_idx = 16;  // Exit loop
                end else begin
                    hex_line[char_idx] = hex_char;
                    char_idx = char_idx + 1;
                end
            end
            hex_char = $fgetc(file_in);
            // If it's not a newline, we've already read too much - continue anyway
            hex_value = 64'h0;
            for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                    nibble_val = hex_line[char_idx] - "0";
                end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                    nibble_val = hex_line[char_idx] - "a" + 10;
                end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                    nibble_val = hex_line[char_idx] - "A" + 10;
                end else begin
                    nibble_val = 0;
                end
                hex_value = (hex_value << 4) | nibble_val;
            end
            bank2[addr] = hex_value;
            
            // Read 16 hex characters for bank3
            char_idx = 0;
            while(char_idx < 16) begin
                hex_char = $fgetc(file_in);
                if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                    for(i = char_idx; i < 16; i = i + 1) begin
                        hex_line[i] = "0";
                    end
                    char_idx = 16;  // Exit loop
                end else begin
                    hex_line[char_idx] = hex_char;
                    char_idx = char_idx + 1;
                end
            end
            hex_char = $fgetc(file_in);
            // If it's not a newline, we've already read too much - continue anyway
            hex_value = 64'h0;
            for(char_idx = 0; char_idx < 16; char_idx = char_idx + 1) begin
                if(hex_line[char_idx] >= "0" && hex_line[char_idx] <= "9") begin
                    nibble_val = hex_line[char_idx] - "0";
                end else if(hex_line[char_idx] >= "a" && hex_line[char_idx] <= "f") begin
                    nibble_val = hex_line[char_idx] - "a" + 10;
                end else if(hex_line[char_idx] >= "A" && hex_line[char_idx] <= "F") begin
                    nibble_val = hex_line[char_idx] - "A" + 10;
                end else begin
                    nibble_val = 0;
                end
                hex_value = (hex_value << 4) | nibble_val;
            end
            bank3[addr] = hex_value;
            
            addr = addr + 1;
        end
    end

    $fclose(file_in);
    $display("Finished loading %s into 4 banks", bmp_filepath);
end
endtask

endmodule

