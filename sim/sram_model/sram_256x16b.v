module sram_256x16b #(
    parameter BW_PER_ADDR = 128,
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
    reg [63:0] data_byte;
    integer hex_char;
    reg [7:0] hex_line [0:15];  // 16 characters for hex string
    reg [63:0] hex_value;
    reg [63:0] hex_value_low, hex_value_high;
    integer char_idx;
    integer nibble_val;
    
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

    // For .dat files, read binary data directly (128-bit per address = 16 bytes)
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
        
        // addr : 0~255 (256 addresses for 32x32 image)
        // Each address stores 128-bit (16 bytes)
        // For 32x32 = 1024 pixels, with 4 banks, we have 256 addresses per bank
        // Each address stores 128-bit = 16 bytes, so we can store 16 pixels per address
        // But we process 4 pixels at a time (one per bank), so we need 4 iterations per address
        addr = 0;
        for(row = 31; row >= 0; row = row - 1) begin  // BMP bottom-up
            for(col = 0; col < 32; col = col + 4) begin  // 4 pixel -> 4 bank
                // Read 4 pixels, each pixel is 1 byte
                // Store them in the first 4 bytes of each bank's address
                // For 128-bit addresses, we'll store 4 pixels per address (repeating pattern)
                r = $fgetc(file_in);
                bank0[addr][7:0] = r;
                bank0[addr][15:8] = r;  // Repeat for simplicity, or read more pixels
                bank0[addr][23:16] = r;
                bank0[addr][31:24] = r;
                // Pad remaining bytes with 0 or repeat pattern
                for(i = 4; i < 16; i = i + 1)
                    bank0[addr][i*8 +: 8] = 8'h0;
                
                r = $fgetc(file_in);
                bank1[addr][7:0] = r;
                bank1[addr][15:8] = r;
                bank1[addr][23:16] = r;
                bank1[addr][31:24] = r;
                for(i = 4; i < 16; i = i + 1)
                    bank1[addr][i*8 +: 8] = 8'h0;
                
                r = $fgetc(file_in);
                bank2[addr][7:0] = r;
                bank2[addr][15:8] = r;
                bank2[addr][23:16] = r;
                bank2[addr][31:24] = r;
                for(i = 4; i < 16; i = i + 1)
                    bank2[addr][i*8 +: 8] = 8'h0;
                
                r = $fgetc(file_in);
                bank3[addr][7:0] = r;
                bank3[addr][15:8] = r;
                bank3[addr][23:16] = r;
                bank3[addr][31:24] = r;
                for(i = 4; i < 16; i = i + 1)
                    bank3[addr][i*8 +: 8] = 8'h0;
                
                addr = addr + 1;
            end
        end
    end else begin
        // .dat file: Read ASCII text file
        // Layer 7,10: 32 hex characters with underscore separator (e.g., "408b37e7e7e7e7e8_0000000000000000")
        // Layer 6,8,9: 16 hex characters per line (64-bit, duplicate for 128-bit)
        // 256 addresses * 4 banks = 1024 lines
        
        if(LAYER == 7 || LAYER == 9 || LAYER == 10) begin
            // Layer 7,9,10: 32 hex characters with underscore (high_low)
            // Format: high_low, where high is [127:64] (real part), low is [63:0] (imaginary part)
            addr = 0;
            while(addr < MEM_DEPTH && !$feof(file_in)) begin
                // Read 16 hex characters for high 64-bit (before underscore)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                // Skip underscore
                hex_char = $fgetc(file_in);
                // Convert hex string to 64-bit value (high)
                hex_value_high = 64'h0;
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
                    hex_value_high = (hex_value_high << 4) | nibble_val;
                end
                // Read 16 hex characters for low 64-bit (after underscore)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                // Convert hex string to 64-bit value (low)
                hex_value_low = 64'h0;
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
                    hex_value_low = (hex_value_low << 4) | nibble_val;
                end
                bank0[addr] = {hex_value_high, hex_value_low};
                
                // Read for bank1 (high_low format)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_high = 64'h0;
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
                    hex_value_high = (hex_value_high << 4) | nibble_val;
                end
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_low = 64'h0;
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
                    hex_value_low = (hex_value_low << 4) | nibble_val;
                end
                bank1[addr] = {hex_value_high, hex_value_low};
                
                // Read for bank2 (high_low format)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_high = 64'h0;
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
                    hex_value_high = (hex_value_high << 4) | nibble_val;
                end
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_low = 64'h0;
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
                    hex_value_low = (hex_value_low << 4) | nibble_val;
                end
                bank2[addr] = {hex_value_high, hex_value_low};
                
                // Read for bank3 (high_low format)
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_high = 64'h0;
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
                    hex_value_high = (hex_value_high << 4) | nibble_val;
                end
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                hex_value_low = 64'h0;
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
                    hex_value_low = (hex_value_low << 4) | nibble_val;
                end
                bank3[addr] = {hex_value_high, hex_value_low};
                
                addr = addr + 1;
            end
        end else begin
            // Layer 6,8,9: 16 hex characters per line (64-bit, duplicate for 128-bit)
            addr = 0;
            while(addr < MEM_DEPTH && !$feof(file_in)) begin
                // Read 16 hex characters for bank0
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
                // Convert hex string to 64-bit value
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
                // For 128-bit, use the same value for both low and high 64-bit
                bank0[addr] = {hex_value, hex_value};
                
                // Read 16 hex characters for bank1
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
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
                bank1[addr] = {hex_value, hex_value};
                
                // Read 16 hex characters for bank2
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
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
                bank2[addr] = {hex_value, hex_value};
                
                // Read 16 hex characters for bank3
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                        for(i = char_idx; i < 16; i = i + 1) begin
                            hex_line[i] = "0";
                        end
                        char_idx = 16;
                    end else begin
                        hex_line[char_idx] = hex_char;
                        char_idx = char_idx + 1;
                    end
                end
                hex_char = $fgetc(file_in);
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
                bank3[addr] = {hex_value, hex_value};
                
                addr = addr + 1;
            end
        end
    end

    $fclose(file_in);
    $display("Finished loading %s into 4 banks", bmp_filepath);
end
endtask

task load_param_hex;
    input [256*8-1:0] hex_filename;
    input [19:0] dat_num;
    
    integer file_in;
    integer addr;
    integer bank_idx, bank_addr;
    reg [63:0] real_hex, imag_hex;
    reg [127:0] complex_data;
    reg file_ok;

    begin
         $display("Loading param from: %s", hex_filename);
        
        file_ok = 1;
        file_in = $fopen(hex_filename, "r");
        if (file_in == 0) begin
            $display("ERROR: Cannot open param file %s", hex_filename);
            file_ok = 0;
        end

        if (file_ok) begin
            addr = 0;
            
            // Read hex file line by line
            while (!$feof(file_in) && addr < (dat_num)) begin
                // Read one line (real_hex imag_hex)
                if ($fscanf(file_in, "%16h_%16h", real_hex, imag_hex) == 2) begin
                    // Combine real and imag into 128-bit complex number
                    complex_data = {real_hex, imag_hex};
                    
                    case (addr[1:0])
                        0: bank0[addr[19:2]] = complex_data;
                        1: bank1[addr[19:2]] = complex_data;
                        2: bank2[addr[19:2]] = complex_data;
                        3: bank3[addr[19:2]] = complex_data;
                    endcase
                    
                    addr = addr + 1;
                end
            end
            
            $fclose(file_in);
            $display("Loaded %0d parameter into sram (distributed to 4 banks)", addr);
            $display("sram initialization flag set");
        end else begin
            $display("WARNING: sram initialization failed - file not opened");
        end
    end
    
endtask

task clear_sram;
    input [BW_PER_ADDR-1:0] value;
    integer addr;
begin
    for (addr = 0; addr < MEM_DEPTH; addr = addr + 1) begin
        bank0[addr] = value;
        bank1[addr] = value;
        bank2[addr] = value;
        bank3[addr] = value;
    end
end
endtask

endmodule

