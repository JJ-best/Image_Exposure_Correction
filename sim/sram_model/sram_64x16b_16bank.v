module sram_64x16b_16bank #(
    parameter BW_PER_ADDR = 128,
    parameter ADDR_WIDTH = 6  
)(
    input clk,
    input csb,      // chip enable (active low)

    // write enable (active low = write)
    input wsb_0,    
    input wsb_1,    
    input wsb_2,    
    input wsb_3,
    input wsb_4,
    input wsb_5,
    input wsb_6,
    input wsb_7,
    input wsb_8,
    input wsb_9,
    input wsb_10,
    input wsb_11,
    input wsb_12,
    input wsb_13,
    input wsb_14,
    input wsb_15,

    // write data
    input [BW_PER_ADDR-1:0] wdata_0,  
    input [BW_PER_ADDR-1:0] wdata_1,  
    input [BW_PER_ADDR-1:0] wdata_2,  
    input [BW_PER_ADDR-1:0] wdata_3,
    input [BW_PER_ADDR-1:0] wdata_4,
    input [BW_PER_ADDR-1:0] wdata_5,
    input [BW_PER_ADDR-1:0] wdata_6,
    input [BW_PER_ADDR-1:0] wdata_7,
    input [BW_PER_ADDR-1:0] wdata_8,
    input [BW_PER_ADDR-1:0] wdata_9,
    input [BW_PER_ADDR-1:0] wdata_10,
    input [BW_PER_ADDR-1:0] wdata_11,
    input [BW_PER_ADDR-1:0] wdata_12,
    input [BW_PER_ADDR-1:0] wdata_13,
    input [BW_PER_ADDR-1:0] wdata_14,
    input [BW_PER_ADDR-1:0] wdata_15,

    // write address
    input [ADDR_WIDTH-1:0] waddr_0,   
    input [ADDR_WIDTH-1:0] waddr_1,   
    input [ADDR_WIDTH-1:0] waddr_2,   
    input [ADDR_WIDTH-1:0] waddr_3,
    input [ADDR_WIDTH-1:0] waddr_4,
    input [ADDR_WIDTH-1:0] waddr_5,
    input [ADDR_WIDTH-1:0] waddr_6,
    input [ADDR_WIDTH-1:0] waddr_7,
    input [ADDR_WIDTH-1:0] waddr_8,
    input [ADDR_WIDTH-1:0] waddr_9,
    input [ADDR_WIDTH-1:0] waddr_10,
    input [ADDR_WIDTH-1:0] waddr_11,
    input [ADDR_WIDTH-1:0] waddr_12,
    input [ADDR_WIDTH-1:0] waddr_13,
    input [ADDR_WIDTH-1:0] waddr_14,
    input [ADDR_WIDTH-1:0] waddr_15,

    // read address
    input [ADDR_WIDTH-1:0] raddr_0,   
    input [ADDR_WIDTH-1:0] raddr_1,   
    input [ADDR_WIDTH-1:0] raddr_2,   
    input [ADDR_WIDTH-1:0] raddr_3,
    input [ADDR_WIDTH-1:0] raddr_4,
    input [ADDR_WIDTH-1:0] raddr_5,
    input [ADDR_WIDTH-1:0] raddr_6,
    input [ADDR_WIDTH-1:0] raddr_7,
    input [ADDR_WIDTH-1:0] raddr_8,
    input [ADDR_WIDTH-1:0] raddr_9,
    input [ADDR_WIDTH-1:0] raddr_10,
    input [ADDR_WIDTH-1:0] raddr_11,
    input [ADDR_WIDTH-1:0] raddr_12,
    input [ADDR_WIDTH-1:0] raddr_13,
    input [ADDR_WIDTH-1:0] raddr_14,
    input [ADDR_WIDTH-1:0] raddr_15,

    // read data
    output reg [BW_PER_ADDR-1:0] rdata_0,  
    output reg [BW_PER_ADDR-1:0] rdata_1,  
    output reg [BW_PER_ADDR-1:0] rdata_2,  
    output reg [BW_PER_ADDR-1:0] rdata_3,
    output reg [BW_PER_ADDR-1:0] rdata_4,
    output reg [BW_PER_ADDR-1:0] rdata_5,
    output reg [BW_PER_ADDR-1:0] rdata_6,
    output reg [BW_PER_ADDR-1:0] rdata_7,
    output reg [BW_PER_ADDR-1:0] rdata_8,
    output reg [BW_PER_ADDR-1:0] rdata_9,
    output reg [BW_PER_ADDR-1:0] rdata_10,
    output reg [BW_PER_ADDR-1:0] rdata_11,
    output reg [BW_PER_ADDR-1:0] rdata_12,
    output reg [BW_PER_ADDR-1:0] rdata_13,
    output reg [BW_PER_ADDR-1:0] rdata_14,
    output reg [BW_PER_ADDR-1:0] rdata_15
);

    // Memory array
    localparam MEM_DEPTH = 1 << ADDR_WIDTH;  // 2^ADDR_WIDTH = 64
    reg [BW_PER_ADDR-1:0] bank0 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank1 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank2 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank3 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank4 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank5 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank6 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank7 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank8 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank9 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank10 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank11 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank12 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank13 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank14 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] bank15 [0:MEM_DEPTH-1];
    reg [BW_PER_ADDR-1:0] _rdata_0, _rdata_1, _rdata_2, _rdata_3;
    reg [BW_PER_ADDR-1:0] _rdata_4, _rdata_5, _rdata_6, _rdata_7;
    reg [BW_PER_ADDR-1:0] _rdata_8, _rdata_9, _rdata_10, _rdata_11;
    reg [BW_PER_ADDR-1:0] _rdata_12, _rdata_13, _rdata_14, _rdata_15;

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
        if (~csb && ~wsb_4) begin
            bank4[waddr_4] <= wdata_4;
        end
        if (~csb && ~wsb_5) begin
            bank5[waddr_5] <= wdata_5;
        end
        if (~csb && ~wsb_6) begin
            bank6[waddr_6] <= wdata_6;
        end
        if (~csb && ~wsb_7) begin
            bank7[waddr_7] <= wdata_7;
        end
        if (~csb && ~wsb_8) begin
            bank8[waddr_8] <= wdata_8;
        end
        if (~csb && ~wsb_9) begin
            bank9[waddr_9] <= wdata_9;
        end
        if (~csb && ~wsb_10) begin
            bank10[waddr_10] <= wdata_10;
        end
        if (~csb && ~wsb_11) begin
            bank11[waddr_11] <= wdata_11;
        end
        if (~csb && ~wsb_12) begin
            bank12[waddr_12] <= wdata_12;
        end
        if (~csb && ~wsb_13) begin
            bank13[waddr_13] <= wdata_13;
        end
        if (~csb && ~wsb_14) begin
            bank14[waddr_14] <= wdata_14;
        end
        if (~csb && ~wsb_15) begin
            bank15[waddr_15] <= wdata_15;
        end
    end

    // Read 
    always @(posedge clk) begin
        if (~csb) begin
            _rdata_0 <= bank0[raddr_0];
            _rdata_1 <= bank1[raddr_1];
            _rdata_2 <= bank2[raddr_2];
            _rdata_3 <= bank3[raddr_3];
            _rdata_4 <= bank4[raddr_4];
            _rdata_5 <= bank5[raddr_5];
            _rdata_6 <= bank6[raddr_6];
            _rdata_7 <= bank7[raddr_7];
            _rdata_8 <= bank8[raddr_8];
            _rdata_9 <= bank9[raddr_9];
            _rdata_10 <= bank10[raddr_10];
            _rdata_11 <= bank11[raddr_11];
            _rdata_12 <= bank12[raddr_12];
            _rdata_13 <= bank13[raddr_13];
            _rdata_14 <= bank14[raddr_14];
            _rdata_15 <= bank15[raddr_15];
        end
    end

    // Output read data
    always @* begin
        rdata_0 = _rdata_0;
        rdata_1 = _rdata_1;
        rdata_2 = _rdata_2;
        rdata_3 = _rdata_3;
        rdata_4 = _rdata_4;
        rdata_5 = _rdata_5;
        rdata_6 = _rdata_6;
        rdata_7 = _rdata_7;
        rdata_8 = _rdata_8;
        rdata_9 = _rdata_9;
        rdata_10 = _rdata_10;
        rdata_11 = _rdata_11;
        rdata_12 = _rdata_12;
        rdata_13 = _rdata_13;
        rdata_14 = _rdata_14;
        rdata_15 = _rdata_15;
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
    integer i, j;
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

    // For .dat files, read ASCII text file
    // Layer 7,9,10: 32 hex characters with underscore separator (e.g., "408b37e7e7e7e7e8_0000000000000000")
    // Layer 6,8: 16 hex characters per line (64-bit, duplicate for 128-bit)
    // 64 addresses * 16 banks = 1024 lines
    
    if(LAYER == 7 || LAYER == 9 || LAYER == 10) begin
        // Layer 7,9,10: 32 hex characters with underscore (high_low)
        // Format: high_low, where high is [127:64] (real part), low is [63:0] (imaginary part)
        addr = 0;
        while(addr < MEM_DEPTH && !$feof(file_in)) begin
            // Read for bank0 (high_low format)
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
            bank0[addr] = {hex_value_high, hex_value_low};
            
            // Read for bank1-15 (high_low format)
            for(i = 1; i < 16; i = i + 1) begin
                char_idx = 0;
                while(char_idx < 16) begin
                    hex_char = $fgetc(file_in);
                    if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                        for(j = char_idx; j < 16; j = j + 1) begin
                            hex_line[j] = "0";
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
                        for(j = char_idx; j < 16; j = j + 1) begin
                            hex_line[j] = "0";
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
                case(i)
                    1: bank1[addr] = {hex_value_high, hex_value_low};
                    2: bank2[addr] = {hex_value_high, hex_value_low};
                    3: bank3[addr] = {hex_value_high, hex_value_low};
                    4: bank4[addr] = {hex_value_high, hex_value_low};
                    5: bank5[addr] = {hex_value_high, hex_value_low};
                    6: bank6[addr] = {hex_value_high, hex_value_low};
                    7: bank7[addr] = {hex_value_high, hex_value_low};
                    8: bank8[addr] = {hex_value_high, hex_value_low};
                    9: bank9[addr] = {hex_value_high, hex_value_low};
                    10: bank10[addr] = {hex_value_high, hex_value_low};
                    11: bank11[addr] = {hex_value_high, hex_value_low};
                    12: bank12[addr] = {hex_value_high, hex_value_low};
                    13: bank13[addr] = {hex_value_high, hex_value_low};
                    14: bank14[addr] = {hex_value_high, hex_value_low};
                    15: bank15[addr] = {hex_value_high, hex_value_low};
                endcase
            end
            
            addr = addr + 1;
        end
    end else begin
        // Layer 6,8: 128-bit fp64, 64 addresses, 16 banks
        // Layer 6: File format is 16 hex characters (real part only, FFT input), low is always 0
        // Layer 8: File format is high_low (32 hex characters with underscore separator)
        addr = 0;
        while(addr < MEM_DEPTH && !$feof(file_in)) begin
            if(LAYER == 6) begin
                // Layer 6: Read 16 hex characters (real part only), low is always 0
                // Read for bank0
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
                hex_char = $fgetc(file_in); // Consume newline
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
                // high is [127:64] (real part), low is [63:0] (imaginary part, always 0 for layer 6)
                bank0[addr] = {hex_value_high, 64'h0};
            end else begin
                // Layer 8: Read high_low format (32 hex characters with underscore separator)
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
                hex_char = $fgetc(file_in); // Consume newline
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
                // high is [127:64] (real part), low is [63:0] (imaginary part)
                bank0[addr] = {hex_value_high, hex_value_low};
            end
            
            // Read for bank1-15
            for(i = 1; i < 16; i = i + 1) begin
                if(LAYER == 6) begin
                    // Layer 6: Read 16 hex characters (real part only), low is always 0
                    char_idx = 0;
                    while(char_idx < 16) begin
                        hex_char = $fgetc(file_in);
                        if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                            for(j = char_idx; j < 16; j = j + 1) begin
                                hex_line[j] = "0";
                            end
                            char_idx = 16;
                        end else begin
                            hex_line[char_idx] = hex_char;
                            char_idx = char_idx + 1;
                        end
                    end
                    hex_char = $fgetc(file_in); // Consume newline
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
                    // high is [127:64] (real part), low is [63:0] (imaginary part, always 0 for layer 6)
                    case(i)
                        1: bank1[addr] = {hex_value_high, 64'h0};
                        2: bank2[addr] = {hex_value_high, 64'h0};
                        3: bank3[addr] = {hex_value_high, 64'h0};
                        4: bank4[addr] = {hex_value_high, 64'h0};
                        5: bank5[addr] = {hex_value_high, 64'h0};
                        6: bank6[addr] = {hex_value_high, 64'h0};
                        7: bank7[addr] = {hex_value_high, 64'h0};
                        8: bank8[addr] = {hex_value_high, 64'h0};
                        9: bank9[addr] = {hex_value_high, 64'h0};
                        10: bank10[addr] = {hex_value_high, 64'h0};
                        11: bank11[addr] = {hex_value_high, 64'h0};
                        12: bank12[addr] = {hex_value_high, 64'h0};
                        13: bank13[addr] = {hex_value_high, 64'h0};
                        14: bank14[addr] = {hex_value_high, 64'h0};
                        15: bank15[addr] = {hex_value_high, 64'h0};
                    endcase
                end else begin
                    // Layer 8: Read high_low format (32 hex characters with underscore separator)
                    // Read 16 hex characters for high 64-bit (before underscore)
                    char_idx = 0;
                    while(char_idx < 16) begin
                        hex_char = $fgetc(file_in);
                        if(hex_char == -1 || hex_char == 10 || hex_char == 13 || hex_char == "_") begin
                            for(j = char_idx; j < 16; j = j + 1) begin
                                hex_line[j] = "0";
                            end
                            char_idx = 16;
                        end else begin
                            hex_line[char_idx] = hex_char;
                            char_idx = char_idx + 1;
                        end
                    end
                    // Skip underscore
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
                    
                    // Read 16 hex characters for low 64-bit (after underscore)
                    char_idx = 0;
                    while(char_idx < 16) begin
                        hex_char = $fgetc(file_in);
                        if(hex_char == -1 || hex_char == 10 || hex_char == 13) begin
                            for(j = char_idx; j < 16; j = j + 1) begin
                                hex_line[j] = "0";
                            end
                            char_idx = 16;
                        end else begin
                            hex_line[char_idx] = hex_char;
                            char_idx = char_idx + 1;
                        end
                    end
                    hex_char = $fgetc(file_in); // Consume newline
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
                    // high is [127:64] (real part), low is [63:0] (imaginary part)
                    case(i)
                        1: bank1[addr] = {hex_value_high, hex_value_low};
                        2: bank2[addr] = {hex_value_high, hex_value_low};
                        3: bank3[addr] = {hex_value_high, hex_value_low};
                        4: bank4[addr] = {hex_value_high, hex_value_low};
                        5: bank5[addr] = {hex_value_high, hex_value_low};
                        6: bank6[addr] = {hex_value_high, hex_value_low};
                        7: bank7[addr] = {hex_value_high, hex_value_low};
                        8: bank8[addr] = {hex_value_high, hex_value_low};
                        9: bank9[addr] = {hex_value_high, hex_value_low};
                        10: bank10[addr] = {hex_value_high, hex_value_low};
                        11: bank11[addr] = {hex_value_high, hex_value_low};
                        12: bank12[addr] = {hex_value_high, hex_value_low};
                        13: bank13[addr] = {hex_value_high, hex_value_low};
                        14: bank14[addr] = {hex_value_high, hex_value_low};
                        15: bank15[addr] = {hex_value_high, hex_value_low};
                    endcase
                end
            end
            
            addr = addr + 1;
        end
    end

    $fclose(file_in);
    $display("Finished loading %s into 16 banks", bmp_filepath);
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

