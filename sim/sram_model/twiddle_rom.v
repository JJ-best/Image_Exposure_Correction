module twiddle_rom #(
    parameter DATA_WIDTH = 128,  // 64-bit real + 64-bit imag
    parameter BANK_ADDR_WIDTH = 1  // Each bank has 2 addresses (0-1) to store 2 twiddle factors
)(
    // Bank 0-15 address inputs
    input  wire [BANK_ADDR_WIDTH-1:0] addr_0, addr_1, addr_2, addr_3,
    input  wire [BANK_ADDR_WIDTH-1:0] addr_4, addr_5, addr_6, addr_7,
    input  wire [BANK_ADDR_WIDTH-1:0] addr_8, addr_9, addr_10, addr_11,
    input  wire [BANK_ADDR_WIDTH-1:0] addr_12, addr_13, addr_14, addr_15,
    // Bank 0-15 data outputs
    output reg  [DATA_WIDTH-1:0] twiddle_out_0, twiddle_out_1, twiddle_out_2, twiddle_out_3,
    output reg  [DATA_WIDTH-1:0] twiddle_out_4, twiddle_out_5, twiddle_out_6, twiddle_out_7,
    output reg  [DATA_WIDTH-1:0] twiddle_out_8, twiddle_out_9, twiddle_out_10, twiddle_out_11,
    output reg  [DATA_WIDTH-1:0] twiddle_out_12, twiddle_out_13, twiddle_out_14, twiddle_out_15
);

    // ROM存储所有twiddle factor (31个)
    localparam ROM_DEPTH = 31;  // 1+2+4+8+16 = 31 twiddle factors
    reg [DATA_WIDTH-1:0] rom [0:ROM_DEPTH-1];
    
    // 16个bank，每个bank深度为2 (总共可存32个，足够31个)
    localparam BANK_DEPTH = 2;
    localparam NUM_BANKS = 16;
    
    // Bank storage: bank[i] stores rom[i*2] and rom[i*2+1] (if exists)
    reg [DATA_WIDTH-1:0] bank_0 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_1 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_2 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_3 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_4 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_5 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_6 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_7 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_8 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_9 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_10 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_11 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_12 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_13 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_14 [0:BANK_DEPTH-1];
    reg [DATA_WIDTH-1:0] bank_15 [0:BANK_DEPTH-1];
    
    reg rom_initialized = 0;  // Flag to indicate ROM initialization complete

    // initialize the weight from data file
    initial begin
        load_twiddle_hex("fft_pat/twiddle_factors.hex");
    end

    // Task to load twiddle factors from hex file and distribute to banks
    task load_twiddle_hex;
        input [256*8-1:0] hex_filename;
        
        integer file_in;
        integer addr;
        integer bank_idx, bank_addr;
        reg [63:0] real_hex, imag_hex;
        reg [127:0] complex_data;
        reg file_ok;
        
    begin
        $display("Loading twiddle factors from: %s", hex_filename);
        
        file_ok = 1;
        file_in = $fopen(hex_filename, "r");
        if (file_in == 0) begin
            $display("ERROR: Cannot open twiddle file %s", hex_filename);
            file_ok = 0;
        end
        
        if (file_ok) begin
            addr = 0;
            
            // Read hex file line by line
            while (!$feof(file_in) && addr < ROM_DEPTH) begin
                // Read one line (real_hex imag_hex)
                if ($fscanf(file_in, "%h %h", real_hex, imag_hex) == 2) begin
                    // Combine real and imag into 128-bit complex number
                    complex_data = {real_hex, imag_hex};
                    rom[addr] = complex_data;
                    
                    // New distribution scheme:
                    // - First 15 (ROM[0-14]): addr[0], bank[0-14]
                    // - Bank[15] addr[0]: 0
                    // - Last 16 (ROM[15-30]): addr[1], bank[0-15]
                    if (addr < 15) begin
                        // First 15: store in addr[0] of bank[0-14]
                        bank_idx = addr;
                        bank_addr = 0;
                    end else begin
                        // Last 16: store in addr[1] of bank[0-15]
                        bank_idx = addr - 15;
                        bank_addr = 1;
                    end
                    
                    case (bank_idx)
                        0: bank_0[bank_addr] = complex_data;
                        1: bank_1[bank_addr] = complex_data;
                        2: bank_2[bank_addr] = complex_data;
                        3: bank_3[bank_addr] = complex_data;
                        4: bank_4[bank_addr] = complex_data;
                        5: bank_5[bank_addr] = complex_data;
                        6: bank_6[bank_addr] = complex_data;
                        7: bank_7[bank_addr] = complex_data;
                        8: bank_8[bank_addr] = complex_data;
                        9: bank_9[bank_addr] = complex_data;
                        10: bank_10[bank_addr] = complex_data;
                        11: bank_11[bank_addr] = complex_data;
                        12: bank_12[bank_addr] = complex_data;
                        13: bank_13[bank_addr] = complex_data;
                        14: bank_14[bank_addr] = complex_data;
                        15: bank_15[bank_addr] = complex_data;
                    endcase
                    
                    addr = addr + 1;
                end
            end
            
            // Initialize Bank[15] addr[0] to 0
            bank_15[0] = {DATA_WIDTH{1'b0}};
            
            $fclose(file_in);
            $display("Loaded %0d twiddle factors into ROM (distributed to 16 banks)", addr);
            rom_initialized = 1;  // Mark initialization complete after successful load
            $display("Twiddle ROM initialization flag set");
        end else begin
            $display("WARNING: Twiddle ROM initialization failed - file not opened");
        end
    end
    endtask

    // 读取Bank 0
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_0 = {DATA_WIDTH{1'bx}};
        end else if (addr_0 < BANK_DEPTH) begin
            twiddle_out_0 = bank_0[addr_0];
        end else begin
            twiddle_out_0 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 1
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_1 = {DATA_WIDTH{1'bx}};
        end else if (addr_1 < BANK_DEPTH) begin
            twiddle_out_1 = bank_1[addr_1];
        end else begin
            twiddle_out_1 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 2
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_2 = {DATA_WIDTH{1'bx}};
        end else if (addr_2 < BANK_DEPTH) begin
            twiddle_out_2 = bank_2[addr_2];
        end else begin
            twiddle_out_2 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 3
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_3 = {DATA_WIDTH{1'bx}};
        end else if (addr_3 < BANK_DEPTH) begin
            twiddle_out_3 = bank_3[addr_3];
        end else begin
            twiddle_out_3 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 4
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_4 = {DATA_WIDTH{1'bx}};
        end else if (addr_4 < BANK_DEPTH) begin
            twiddle_out_4 = bank_4[addr_4];
        end else begin
            twiddle_out_4 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 5
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_5 = {DATA_WIDTH{1'bx}};
        end else if (addr_5 < BANK_DEPTH) begin
            twiddle_out_5 = bank_5[addr_5];
        end else begin
            twiddle_out_5 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 6
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_6 = {DATA_WIDTH{1'bx}};
        end else if (addr_6 < BANK_DEPTH) begin
            twiddle_out_6 = bank_6[addr_6];
        end else begin
            twiddle_out_6 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 7
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_7 = {DATA_WIDTH{1'bx}};
        end else if (addr_7 < BANK_DEPTH) begin
            twiddle_out_7 = bank_7[addr_7];
        end else begin
            twiddle_out_7 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 8
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_8 = {DATA_WIDTH{1'bx}};
        end else if (addr_8 < BANK_DEPTH) begin
            twiddle_out_8 = bank_8[addr_8];
        end else begin
            twiddle_out_8 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 9
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_9 = {DATA_WIDTH{1'bx}};
        end else if (addr_9 < BANK_DEPTH) begin
            twiddle_out_9 = bank_9[addr_9];
        end else begin
            twiddle_out_9 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 10
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_10 = {DATA_WIDTH{1'bx}};
        end else if (addr_10 < BANK_DEPTH) begin
            twiddle_out_10 = bank_10[addr_10];
        end else begin
            twiddle_out_10 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 11
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_11 = {DATA_WIDTH{1'bx}};
        end else if (addr_11 < BANK_DEPTH) begin
            twiddle_out_11 = bank_11[addr_11];
        end else begin
            twiddle_out_11 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 12
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_12 = {DATA_WIDTH{1'bx}};
        end else if (addr_12 < BANK_DEPTH) begin
            twiddle_out_12 = bank_12[addr_12];
        end else begin
            twiddle_out_12 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 13
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_13 = {DATA_WIDTH{1'bx}};
        end else if (addr_13 < BANK_DEPTH) begin
            twiddle_out_13 = bank_13[addr_13];
        end else begin
            twiddle_out_13 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 14
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_14 = {DATA_WIDTH{1'bx}};
        end else if (addr_14 < BANK_DEPTH) begin
            twiddle_out_14 = bank_14[addr_14];
        end else begin
            twiddle_out_14 = {DATA_WIDTH{1'b0}};
        end
    end

    // 读取Bank 15
    always @(*) begin
        if (!rom_initialized) begin
            twiddle_out_15 = {DATA_WIDTH{1'bx}};
        end else if (addr_15 < BANK_DEPTH) begin
            twiddle_out_15 = bank_15[addr_15];
        end else begin
            twiddle_out_15 = {DATA_WIDTH{1'b0}};
        end
    end

endmodule

