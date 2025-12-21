module fp64_reciprocal #(
    parameter pFP_WIDTH = 64
)(
    input wire clk,
    input wire srst_n, 
    
    input  wire in_valid,
    input  wire [(pFP_WIDTH-1):0] in_A,
    output reg  [(pFP_WIDTH-1):0] out_B,
    output reg  output_valid
);

    reg sign_0, sign_1, sign_2, sign_3, sign_next;
    reg [11-1:0] exponent_0, exponent_1, exponent_2, exponent_3, exponent_next;
    reg [52-1:0] mantissa_0, mantissa_1, mantissa_2, mantissa_3, mantissa_next;
    reg [(pFP_WIDTH-1):0] out_B_next;
    reg valid_0, valid_1, valid_2, valid_3;
    reg skip0, skip1, skip2, skip3, skip_next;

    reg [56:0] D_reg0, D_reg0_next, F_reg0, F_reg0_next;
    reg [56:0] N_reg1, N_reg1_next, D_reg1, D_reg1_next, F_reg1, F_reg1_next;
    reg [56:0] N_reg2, N_reg2_next, D_reg2, D_reg2_next, F_reg2, F_reg2_next;
    reg [56:0] N_reg3, N_reg3_next, D_reg3_next, F_reg3, F_reg3_next;
    reg [56:0] N_reg4_next;

    reg [113:0] DF_reg1_next;
    reg [113:0] NF_reg2_next, DF_reg2_next;
    reg [113:0] NF_reg3_next, DF_reg3_next;
    reg [113:0] NF_reg4_next;


    reg [54:0] rounded_mant;

    // 2 in Q2.55
    localparam [56:0] TWO_Q2_55 = {2'b10, 55'd0}; // for 2 - D

    always @(posedge clk) begin
        {sign_0, exponent_0} <= {sign_next, exponent_next};
        {sign_1, exponent_1} <= {sign_0, exponent_0};
        {sign_2, exponent_2} <= {sign_1, exponent_1};
        {sign_3, exponent_3} <= {sign_2, exponent_2};

        mantissa_0 <= mantissa_next;
        mantissa_1 <= mantissa_0;
        mantissa_2 <= mantissa_1;
        mantissa_3 <= mantissa_2;

        valid_0 <= in_valid;
        valid_1 <= valid_0;
        valid_2 <= valid_1;
        valid_3 <= valid_2;
        output_valid <= valid_3;

        skip0 <= skip_next;
        skip1 <= skip0;
        skip2 <= skip1;
        skip3 <= skip2;

        D_reg0 <= D_reg0_next;
        F_reg0 <= F_reg0_next;

        N_reg1 <= N_reg1_next;
        D_reg1 <= D_reg1_next;
        F_reg1 <= F_reg1_next;

        N_reg2 <= N_reg2_next; 
        D_reg2 <= D_reg2_next;
        F_reg2 <= F_reg2_next;

        N_reg3 <= N_reg3_next;
        F_reg3 <= F_reg3_next;

        out_B <= out_B_next;
    end

    always @(*) begin
        skip_next = 1'b0;
        {sign_next, exponent_next, mantissa_next} = 64'd0;

        if (in_valid) begin
            case(in_A[62:52])
                11'd2047: begin // Inf or NaN
                    skip_next = 1'b1;
                    if (in_A[51:0] == 0) {sign_next, exponent_next, mantissa_next} = {in_A[63], 63'd0}; 
                    else {sign_next, exponent_next, mantissa_next} = in_A; 
                end
                11'd0: begin // Zero or Denormal
                    if (in_A[51:0] == 0) begin
                        skip_next = 1'b1;
                        {sign_next, exponent_next, mantissa_next} = {in_A[63], 11'h7FF, 52'd0}; 
                    end
                    else begin
                        {sign_next, exponent_next, mantissa_next} = {in_A[63], 11'd2046, in_A[51:1], 1'b0}; 
                    end
                end
                default: begin // Normal
                    {sign_next, exponent_next, mantissa_next} = {in_A[63], 11'd2046 - in_A[62:52], in_A[51:0]}; 
                end
            endcase
        end
    end

    wire [7:0] lut_out;
    recip_lut u_lut (.addr(mantissa_next[51:45]), .data(lut_out));


    always @(*) begin
        // Stage 0
        D_reg0_next = {2'b01, mantissa_next, 3'd0}; 
        F_reg0_next = {2'b00, lut_out, 47'd0}; 

        // Stage 1
        DF_reg1_next = D_reg0 * F_reg0;

        N_reg1_next = F_reg0;
        D_reg1_next = DF_reg1_next[111:55];
        F_reg1_next = TWO_Q2_55 - D_reg1_next;

        // Stage 2
        NF_reg2_next = N_reg1 * F_reg1;
        DF_reg2_next = D_reg1 * F_reg1;
        
        N_reg2_next = NF_reg2_next[111:55];
        D_reg2_next = DF_reg2_next[111:55];
        F_reg2_next = TWO_Q2_55 - D_reg2_next;

        // Stage 3
        NF_reg3_next = N_reg2 * F_reg2;
        DF_reg3_next = D_reg2 * F_reg2;
        
        N_reg3_next = NF_reg3_next[111:55];
        D_reg3_next = DF_reg3_next[111:55];
        
        F_reg3_next = TWO_Q2_55 - D_reg3_next;

        // Stage 4
        NF_reg4_next = N_reg3 * F_reg3;
        N_reg4_next = NF_reg4_next[111:55];

        if (skip3) begin
            out_B_next = {sign_3, exponent_3, mantissa_3};
        end
        else begin
            
            rounded_mant = N_reg4_next[56:2] + N_reg4_next[1]; // rounding for 55 bits mantissa

            if (rounded_mant[53] == 1'b1) begin // if result >= 2.0 (1.0xxxxx)
                out_B_next = {sign_3, exponent_3, rounded_mant[52:1]};
            end 
            else begin // if result < 2.0 (0.1xxxxx)
                out_B_next = {sign_3, exponent_3 - 11'd1, rounded_mant[51:0]};
            end
        end
    end

endmodule