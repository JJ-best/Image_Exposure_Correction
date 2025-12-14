module fp64_reciprocal #(
    parameter pFP_WIDTH = 64
)(
    input wire clk,
    input wire srst_n, 
    
    // --- Control and Data Interface ---
    input  wire in_valid,
    input  wire [(pFP_WIDTH-1):0] in_A,
    output reg  [(pFP_WIDTH-1):0] in_B,
    output reg  output_valid,

    // --- External SIMD Multiplier Interface ---
    output reg  mul_req_o,
    output reg  [(2*pFP_WIDTH-1):0] mul_a_o,
    output reg  [(2*pFP_WIDTH-1):0] mul_b_o,
    input  wire [(2*pFP_WIDTH-1):0] mul_res_i,
    input  wire mul_ack_i
);

    // ===============================================================
    // 1. Parameters and Register Definitions
    // ===============================================================
    localparam S_IDLE = 2'd0;
    localparam S_CALC = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0] state, state_next;

    // Data Registers
    reg [63:0] N_reg, N_reg_next, D_reg, D_reg_next, F_reg, F_reg_next;

    reg mul_req_o_next;

    reg [1:0] cnt, cnt_next; 
    
    reg output_valid_next;

    reg sign, sign_next;
    reg [11-1:0] exponent, exponent_next;
    reg exponent_s, exponent_s_next;
    reg [52-1:0] mantissa, mantissa_next;

    // ===============================================================
    // 2. Combinational Logic Block
    // ===============================================================
    
    // --- A. LUT Connection ---
    wire [7:0] lut_out;
    recip_lut u_lut (.addr(in_A[51:45]), .data(lut_out));

    // --- B. Fixed-Point to Fake Float Conversion ---
    // These wires are always ready for the multiplier
    wire [63:0] N_float = {1'b0, 11'h3FF, N_reg_next[62:11]};
    wire [63:0] D_float = {1'b0, 11'h3FF, D_reg_next[62:11]};
    wire [63:0] F_float = {1'b0, 11'h3FF, F_reg_next[62:11]};


    // FSM Sequential Logic

    // --- State Register Update ---
    always @(posedge clk) begin
        if (~srst_n) state <= S_IDLE;
        else         state <= state_next;
    end

    // --- Data Registers Update ---
    always @(posedge clk) begin
        {sign, exponent, mantissa} <= {sign_next, exponent_next, mantissa_next};
        cnt <= cnt_next;
        mul_req_o <= mul_req_o_next;
        N_reg <= N_reg_next;
        D_reg <= D_reg_next;
        F_reg <= F_reg_next;
        exponent_s <= exponent_s_next;
        output_valid <= output_valid_next;
    end

    // --- E. Next State Logic (Combinational) ---
    always @(*) begin
        state_next = state; // Default stay
        {sign_next, exponent_next, mantissa_next} = {sign, exponent, mantissa}; // Default hold
        cnt_next = cnt; // Default hold
        mul_req_o_next = 0;
        exponent_s_next = exponent_s;
        output_valid_next = 0;
        
        case (state)
            S_IDLE: begin
                cnt_next = 2'd0;
                if (in_valid) begin
                    // Rapid exception check; if exception, jump directly to S_DONE
                    case(in_A[62:52])
                        11'd2047: begin
                            exponent_s_next = 12'd0;
                            if (in_A[51:0] == 0) begin {sign_next, exponent_next, mantissa_next} = {sign, 63'd0}; state_next = S_DONE; end // Zero
                            else begin {sign_next, exponent_next, mantissa_next} = in_A; state_next = S_DONE; end // NaN
                        end
                        11'd0: begin
                            exponent_s_next = 12'd0;
                            mul_req_o_next = 1;
                            if (in_A[51:27] == 0) begin // first 27 bits zero (26:0)
                                if (in_A[26:13] == 0) begin // first 41 bits zero (12:0)
                                    if (in_A[12:6] == 0) begin // (5:0)
                                        if (in_A[5:3] == 0) begin // (2:0)
                                            if (in_A[2:1] == 0) begin // (0 or Inf)
                                                if (in_A[0] == 0) begin // (Inf)
                                                    {sign_next, exponent_next, mantissa_next} = {sign, 11'h7FF, 52'd0}; state_next = S_DONE; // Inf
                                                    mul_req_o_next = 0;
                                                end
                                                else begin // (0)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd0 + 1, in_A[51:0], {1{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                            else begin// (2:1)
                                                if (in_A[2] == 0) begin // (1)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd1 + 1, in_A[50:0], {2{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (2)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd2 + 1, in_A[49:0], {3{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                        else begin // (5:3)
                                            if (in_A[5] == 0) begin // (4:3)
                                                if (in_A[4] == 0) begin // (3)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd4 + 1, in_A[48:0], {4{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (4)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd5 + 1, in_A[47:0], {5{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                            else begin // (5)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd6 + 1, in_A[46:0], {6{1'd0}}}; state_next = S_CALC;
                                            end
                                        end
                                    end
                                    else begin // (12:6)
                                        if (in_A[12:10] == 0) begin // (9:6)
                                            if (in_A[9:8] == 0) begin // (7:6)
                                                if (in_A[7] == 0) begin // (6)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd7 + 1, in_A[45:0], {7{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (7)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd8 + 1, in_A[44:0], {8{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                            else begin // (9:8)
                                                if (in_A[9] == 0) begin // (8)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd9 + 1, in_A[43:0], {9{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (9)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd20 + 1, in_A[42:0], {10{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                        else begin // (12:10)
                                            if (in_A[12] == 0) begin // (10:11)
                                                if (in_A[11] == 0) begin // (10)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd21 + 1, in_A[41:0], {10{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (11)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd22 + 1, in_A[40:0], {11{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                            else begin // (12)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd23 + 1, in_A[39:0], {12{1'd0}}}; state_next = S_CALC;
                                            end
                                        end
                                    end
                                end
                                else begin // first 41 bits not zero (26:13)
                                    if (in_A[26:20] == 0) begin // (19:13)
                                        if (in_A[19:16] == 0) begin // (15:13)
                                            if (in_A[15:14] == 0) begin // (13)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd24 + 1, in_A[38:0], {13{1'd0}}}; state_next = S_CALC;
                                            end
                                            else begin // (15:14)
                                                if (in_A[15] == 0) begin // (14)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd25 + 1, in_A[37:0], {14{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (15)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd26 + 1, in_A[36:0], {15{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                        else begin // (19:16)
                                            if (in_A[19:18] == 0) begin // (17:16)
                                                if (in_A[17] == 0) begin // (16)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd27 + 1, in_A[35:0], {16{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (17)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd28 + 1, in_A[34:0], {17{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                            else begin // (19:18)
                                                if (in_A[19] == 0) begin // (18)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd29 + 1, in_A[33:0], {18{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (19)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd20 + 1, in_A[32:0], {19{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                    end
                                    else begin // (26:20)
                                        if (in_A[26:23] == 0) begin // (22:20)
                                            if (in_A[22:21] == 0) begin // (20)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd21 + 1, in_A[32:0], {20{1'd0}}}; state_next = S_CALC;
                                            end
                                            else begin // (22:21)
                                                if (in_A[22] == 0) begin // (21)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd22 + 1, in_A[31:0], {21{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (22)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd23 + 1, in_A[30:0], {22{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                        else begin // (26:23)
                                            if (in_A[26:25] == 0) begin // (24:23)
                                                if (in_A[24] == 0) begin // (23)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd24 + 1, in_A[29:0], {23{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (24)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd25 + 1, in_A[28:0], {24{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                            else begin // (26:25)
                                                if (in_A[26] == 0) begin // (25)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd26 + 1, in_A[27:0], {25{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (26)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd27 + 1, in_A[26:0], {26{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            else begin // first 27 bits not zero (51:27)
                                if (in_A[51:40] == 0) begin // (39:27)
                                    if (in_A[39:33] == 0) begin // (32:27)
                                        if (in_A[32:30] == 0) begin // (29:27)
                                            if (in_A[29:28] == 0) begin // (27)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd28 + 1, in_A[25:0], {27{1'd0}}}; state_next = S_CALC;
                                            end
                                            else begin // (29:28)
                                                if (in_A[29] == 0) begin // (28)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd29 + 1, in_A[24:0], {28{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (29)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd30 + 1, in_A[23:0], {29{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                        else begin // (32:30)
                                            if (in_A[32] == 0) begin // (31:30)
                                                if (in_A[31] == 0) begin // (30)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd31 + 1, in_A[23:0], {30{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (31)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd32 + 1, in_A[22:0], {31{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                            else begin // (32)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd33 + 1, in_A[21:0], {32{1'd0}}}; state_next = S_CALC;
                                            end
                                        end
                                    end
                                    else begin // (39:33)
                                        if (in_A[39:36] == 0) begin // (35:33)
                                            if (in_A[35:34] == 0) begin // (33)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd34 + 1, in_A[20:0], {33{1'd0}}}; state_next = S_CALC;
                                            end
                                            else begin // (35:34)
                                                if (in_A[35] == 0) begin // (34)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd35 + 1, in_A[19:0], {34{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (35)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd36 + 1, in_A[18:0], {35{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                        else begin // (39:36)
                                            if (in_A[39:38] == 0) begin // (37:36)
                                                if (in_A[37] == 0) begin // (36)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd37 + 1, in_A[17:0], {36{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (37)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd38 + 1, in_A[16:0], {37{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                            else begin // (39:38)
                                                if (in_A[39] == 0) begin // (38)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd39 + 1, in_A[15:0], {38{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (39)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd40 + 1, in_A[14:0], {39{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                    end
                                end
                                else begin  // (51:40)
                                    if (in_A[51:47] == 0) begin // (46:40)
                                        if (in_A[46:43] == 0) begin // (42:40)
                                            if (in_A[42:41] == 0) begin // (40)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd41 + 1, in_A[12:0], {40{1'd0}}}; state_next = S_CALC;
                                            end
                                            else begin // (42:41)
                                                if (in_A[42] == 0) begin // (41)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd42 + 1, in_A[11:0], {41{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (42)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd44 + 1, in_A[10:0], {42{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                        else begin // (46:43)
                                            if (in_A[46:45] == 0) begin // (44:43)
                                                if (in_A[44] == 0) begin // (43)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd45 + 1, in_A[9:0], {43{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (44)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd46 + 1, in_A[8:0], {44{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                            else begin // (46:45)
                                                if (in_A[46] == 0) begin // (45)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd46 + 1, in_A[7:0], {45{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (46)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd47 + 1, in_A[6:0], {46{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                    end
                                    else begin // (51:47)
                                        if (in_A[51:50] == 0) begin // (49:47)
                                            if (in_A[49:48] == 0) begin // (47)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd48 + 1, in_A[5:0], {47{1'd0}}}; state_next = S_CALC;
                                            end
                                            else begin // (49:48)
                                                if (in_A[49] == 0) begin // (48)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd49 + 1, in_A[4:0], {48{1'd0}}}; state_next = S_CALC;
                                                end
                                                else begin // (49)
                                                    {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd50 + 1, in_A[3:0], {49{1'd0}}}; state_next = S_CALC;
                                                end
                                            end
                                        end
                                        else begin // (51:50)
                                            if (in_A[51] == 0) begin // (50)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd51 + 1, in_A[2:0], {50{1'd0}}}; state_next = S_CALC;
                                            end
                                            else begin // (51)
                                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, ~12'd52 + 1, in_A[1:0], {51{1'd0}}}; state_next = S_CALC;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        default: begin // Normal Case
                            mul_req_o_next = 1;
                            if (in_A[51:0] == 52'd0) begin
                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, 1'b0, in_A[62:52], in_A[51:0]}; state_next = S_DONE;
                            end
                            else begin
                                {sign_next, exponent_s_next, exponent_next, mantissa_next} = {sign, 1'b0, in_A[62:52], in_A[51:0]}; state_next = S_CALC;
                            end
                        end
                    endcase
                end
                else begin
                    state_next = S_IDLE;
                end
            end

            S_CALC: begin
                // Init(0) + Iter(1,2,3) = Total 4 calculations
                // Finish when Ack received and counter is 2 (Total 3 iterations: 0,1,2)
                if (mul_ack_i && (cnt == 2'd2)) begin
                    state_next = S_DONE;
                    mul_req_o_next = 1;
                end
                else if (mul_ack_i) begin
                    mul_req_o_next = 1;
                    state_next = S_CALC;
                    cnt_next = cnt + 1;
                end
                else begin
                    mul_req_o_next = 0;
                    state_next = S_CALC;
                end
            end

            S_DONE: begin
                if (mul_ack_i) begin
                    state_next = S_IDLE;
                    output_valid_next = 1;
                end
                else begin
                    state_next = S_DONE;
                end
            end

            default: state_next = S_IDLE;
        endcase
    end 

    // Datapath Logic

    always @(*) begin
        // Default values
        N_reg_next = N_reg;
        D_reg_next = D_reg;
        F_reg_next = F_reg;
        mul_a_o = 128'd0;
        mul_b_o = 128'd0;

        case (state)
            S_IDLE: begin
                // N = 1
                N_reg_next = {1'b1, 63'd0};
                // D = 1.Mantissa (Q1.63)
                D_reg_next = {1'b1, mantissa_next, 11'd0};
                // F = LUT Output (Q1.63)
                F_reg_next = (~D_reg_next) + 64'd1;
                mul_a_o = {64'd0, D_float};
                mul_b_o = {64'd0, F_float};
            end
            S_CALC: begin
                if (cnt == 0) begin
                    // Iter Stage: 1*F, D*F
                    N_reg_next = F_reg;
                    D_reg_next = {1'b1, mul_res_i[51:0], 11'd0};
                    F_reg_next = (~D_reg_next) + 64'd1;
                    // Init Stage: D*F (Low slot), N unchanged
                    mul_a_o = {N_reg_next, D_float};
                    mul_b_o = {F_reg_next, F_float};
                end
                else if (cnt == 2) begin
                    // Iter Stage: N*F, D*F
                    N_reg_next = {1'b1, mul_res_i[115:64], 11'd0};
                    D_reg_next = {1'b1, mul_res_i[51:0], 11'd0};
                    F_reg_next = (~D_reg_next) + 64'd1;
                    mul_a_o = {N_float, 64'd0};
                    mul_b_o = {F_float, 64'd0};
                end
                else begin
                    // Iter Stage: N*F, D*F
                    N_reg_next = {1'b1, mul_res_i[115:64], 11'd0};
                    D_reg_next = {1'b1, mul_res_i[51:0], 11'd0};
                    F_reg_next = (~D_reg_next) + 64'd1;
                    mul_a_o = {N_float, D_float};
                    mul_b_o = {F_float, F_float};
                end
            end
            S_DONE: begin
                N_reg_next = {1'b1, mul_res_i[115:64], 11'd0};
            end
        endcase
    end   

    // --- Variable Declarations ---
    // Expanded to 13-bit to handle underflow (e.g., result is -1)
    reg signed [12:0] calc_exp_raw;
    reg signed [12:0] aligned_exp;
    reg [63:0]        aligned_mant;
    reg [12:0]        r_shift_amt;
    reg [63:0]        final_mant;
    reg [10:0]        final_exp_bits;
    reg [(pFP_WIDTH-1):0] in_B_next;

    always @(posedge clk) begin
        in_B <= in_B_next;
    end

    // Output Logic
    always @(*) begin
        // --- Default Values ---
        in_B_next = 64'd0;
        calc_exp_raw = 13'sd0;
        aligned_exp  = 13'sd0;
        aligned_mant = 64'd0;
        r_shift_amt  = 13'd0;
        final_mant   = 64'd0;
        final_exp_bits = 11'd0;
        
        if (state == S_DONE) begin

            if (cnt != 2'd0) begin
                // ---------------------------------------------------
                // A. Calculation Path
                // ---------------------------------------------------

                // 1. Calculate Initial Exponent
                // Formula: 2046 + (-Exp_in)
                // Trick: Sign Extend 12-bit {s, exp} to 13-bit
                //      {exponent_s, exponent_s, exponent} 
                calc_exp_raw = 13'sd2046 + {exponent_s, exponent_s, exponent};

                // 2. Normalization Correction (Pre-correction)
                // If Mantissa is 0.1xxxx (bit 63 is 0), left shift and subtract 1
                if (N_reg[63] == 1'b0) begin
                    aligned_mant = N_reg << 1;
                    aligned_exp  = calc_exp_raw - 13'sd1;
                end else begin
                    aligned_mant = N_reg;
                    aligned_exp  = calc_exp_raw;
                end

                // 3. Underflow (Denormal) Handling
                // Because aligned_exp is signed, direct comparison with <= 0 works
                if (aligned_exp <= 13'sd0) begin
                    // --- Denormal Case ---
                    // Calculate Right Shift Amount: 1 - aligned_exp
                    // e.g., aligned_exp = -1, shift = 1 - (-1) = 2
                    r_shift_amt = 13'sd1 - aligned_exp;

                    // Safety Guard: Avoid excessive shifting
                    if (r_shift_amt > 13'd63) begin
                        final_mant = 64'd0; 
                    end else begin
                        final_mant = aligned_mant >> r_shift_amt;
                    end
                    final_exp_bits = 11'd0; // Denormal exponent field is 0

                end else begin
                    // --- Normal Case ---
                    final_mant = aligned_mant;

                    // Check Overflow (Result > 2046)
                    // 13'sd2046 is Max Normal Exp 
                    // (Actually 2046, IEEE 754 2047 is Infinity)
                    if (aligned_exp >= 13'sd2047) begin
                        final_exp_bits = 11'h7FF; // Infinity
                        final_mant     = 64'd0;   // Mantissa 0
                    end else begin
                        final_exp_bits = aligned_exp[10:0];
                    end
                end

                // 4. Pack Output (Remove implicit bit / Handle overflow)
                in_B_next = {sign, final_exp_bits, final_mant[62:11]};

            end else begin
                // ---------------------------------------------------
                // B. Special Case Pass-through
                // ---------------------------------------------------
                // Use register values directly
                // Note: exponent_s should not be used here as special values have positive exp
                // Simply recombine (assuming no sign change needed for special values)
                in_B_next = {sign, exponent, mantissa}; 
            end
        end
    end

endmodule