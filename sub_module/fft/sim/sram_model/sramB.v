module sram_256x8b #(
    parameter BW_PER_ADDR = 128,
    parameter ADDR_WIDTH = 8  
)(
    input clk,
    input csb,      // chip enable (active low)

    // write enable (active low = write)
    input wsb_0, wsb_1, wsb_2, wsb_3, wsb_4, wsb_5, wsb_6, wsb_7,
    input wsb_8, wsb_9, wsb_10, wsb_11, wsb_12, wsb_13, wsb_14, wsb_15,

    // write data
    input [BW_PER_ADDR-1:0] wdata_0, wdata_1, wdata_2, wdata_3, wdata_4, wdata_5, wdata_6, wdata_7,
    input [BW_PER_ADDR-1:0] wdata_8, wdata_9, wdata_10, wdata_11, wdata_12, wdata_13, wdata_14, wdata_15,

    // address (shared for read and write)
    input [ADDR_WIDTH-1:0] addr_0, addr_1, addr_2, addr_3, addr_4, addr_5, addr_6, addr_7,
    input [ADDR_WIDTH-1:0] addr_8, addr_9, addr_10, addr_11, addr_12, addr_13, addr_14, addr_15,

    // read data
    output reg [BW_PER_ADDR-1:0] rdata_0, rdata_1, rdata_2, rdata_3, rdata_4, rdata_5, rdata_6, rdata_7,
    output reg [BW_PER_ADDR-1:0] rdata_8, rdata_9, rdata_10, rdata_11, rdata_12, rdata_13, rdata_14, rdata_15   
);

    // Memory array - 16 banks, each with 256 addresses
    localparam MEM_DEPTH = 1 << ADDR_WIDTH;  // 2^ADDR_WIDTH = 256
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
    reg [BW_PER_ADDR-1:0] _rdata_0, _rdata_1, _rdata_2, _rdata_3, _rdata_4, _rdata_5, _rdata_6, _rdata_7;
    reg [BW_PER_ADDR-1:0] _rdata_8, _rdata_9, _rdata_10, _rdata_11, _rdata_12, _rdata_13, _rdata_14, _rdata_15;

    // Write - each bank has independent write control
    always @(posedge clk) begin
        if (~csb && ~wsb_0) bank0[addr_0] <= wdata_0;
        if (~csb && ~wsb_1) bank1[addr_1] <= wdata_1;
        if (~csb && ~wsb_2) bank2[addr_2] <= wdata_2;
        if (~csb && ~wsb_3) bank3[addr_3] <= wdata_3;
        if (~csb && ~wsb_4) bank4[addr_4] <= wdata_4;
        if (~csb && ~wsb_5) bank5[addr_5] <= wdata_5;
        if (~csb && ~wsb_6) bank6[addr_6] <= wdata_6;
        if (~csb && ~wsb_7) bank7[addr_7] <= wdata_7;
        if (~csb && ~wsb_8) bank8[addr_8] <= wdata_8;
        if (~csb && ~wsb_9) bank9[addr_9] <= wdata_9;
        if (~csb && ~wsb_10) bank10[addr_10] <= wdata_10;
        if (~csb && ~wsb_11) bank11[addr_11] <= wdata_11;
        if (~csb && ~wsb_12) bank12[addr_12] <= wdata_12;
        if (~csb && ~wsb_13) bank13[addr_13] <= wdata_13;
        if (~csb && ~wsb_14) bank14[addr_14] <= wdata_14;
        if (~csb && ~wsb_15) bank15[addr_15] <= wdata_15;
    end

    // Read - each bank has independent read port
    always @(posedge clk) begin
        if (~csb) begin
            _rdata_0 <= bank0[addr_0];
            _rdata_1 <= bank1[addr_1];
            _rdata_2 <= bank2[addr_2];
            _rdata_3 <= bank3[addr_3];
            _rdata_4 <= bank4[addr_4];
            _rdata_5 <= bank5[addr_5];
            _rdata_6 <= bank6[addr_6];
            _rdata_7 <= bank7[addr_7];
            _rdata_8 <= bank8[addr_8];
            _rdata_9 <= bank9[addr_9];
            _rdata_10 <= bank10[addr_10];
            _rdata_11 <= bank11[addr_11];
            _rdata_12 <= bank12[addr_12];
            _rdata_13 <= bank13[addr_13];
            _rdata_14 <= bank14[addr_14];
            _rdata_15 <= bank15[addr_15];
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

//-------------------- task: load hex file --------------------
// Task to load hex file (format: real_hex imag_hex per line)
// Data is stored in row-major order: row 0, col 0-31; row 1, col 0-31; ...
// Mapping: 16 pixels per address, using 16 banks
// New mapping: row 0 has 2 addresses (addr 0-1), each with 16 banks
// addr = row * 2 + (col / 16), bank = col % 16
task load_hex;
    input [256*8-1:0] hex_filename;
    
    integer file_in;
    integer row, col, addr, bank;
    integer line_count;
    reg [63:0] real_hex, imag_hex;
    reg [127:0] complex_data;
    
begin
    $display("Loading hex file: %s into SRAM", hex_filename);
    
    file_in = $fopen(hex_filename, "r");
    if (file_in == 0) begin
        $display("ERROR: Cannot open file %s", hex_filename);
        disable load_hex;
    end
    
    line_count = 0;
    
    // Read hex file line by line
    while (!$feof(file_in)) begin
        // Read one line (real_hex imag_hex)
        if ($fscanf(file_in, "%h %h", real_hex, imag_hex) == 2) begin
            // Combine real and imag into 128-bit complex number
            complex_data = {real_hex, imag_hex};
            
            // Calculate row and col from line_count
            row = line_count / 32;
            col = line_count % 32;
            
            // Calculate address and bank
            // 16 pixels per address: col 0-15 -> addr 0, bank 0-15; col 16-31 -> addr 1, bank 0-15
            addr = row * 2 + (col / 16);
            bank = col % 16;
            
            // Write directly to memory array
            case(bank)
                0: bank0[addr] = complex_data;
                1: bank1[addr] = complex_data;
                2: bank2[addr] = complex_data;
                3: bank3[addr] = complex_data;
                4: bank4[addr] = complex_data;
                5: bank5[addr] = complex_data;
                6: bank6[addr] = complex_data;
                7: bank7[addr] = complex_data;
                8: bank8[addr] = complex_data;
                9: bank9[addr] = complex_data;
                10: bank10[addr] = complex_data;
                11: bank11[addr] = complex_data;
                12: bank12[addr] = complex_data;
                13: bank13[addr] = complex_data;
                14: bank14[addr] = complex_data;
                15: bank15[addr] = complex_data;
            endcase
            
            line_count = line_count + 1;
        end
    end
    
    $fclose(file_in);
    $display("Finished loading %0d complex numbers into SRAM (32x32 matrix)", line_count);
end
endtask

endmodule

