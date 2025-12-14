// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
// MIT License
// ---
// Copyright © 2023 Company
// .... Content of the license
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ============================================================================================================================================================================
// Module Name : butterfly
// Author : Jeese
// Create Date: 6/2025
// Features & Functions:
// . Butterfly process element
// .
// ============================================================================================================================================================================
// Revision History:
// Date          by         Version       Change Description
// 2025.7.23    hsuanjung      x          change ifft's operation to follow falcon ifft
//
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

module bpe
#(  
    parameter pDATA_WIDTH = 128 // two 64-bit numbers represent real & imaginary part
)
(
    input   wire clk,
    input   wire rst_n,

    input   wire [1:0] mode, // iFFT(01)/FFT(00) - NTT/iNTT removed

    input   wire i_vld,
    output  wire i_rdy,
    
    output  wire o_vld,
    input   wire o_rdy,

    input   wire [(pDATA_WIDTH-1):0] ai, // are(64bit)+aim(64bit)
    input   wire [(pDATA_WIDTH-1):0] bi, // bre(64bit)+bim(64bit)
    input   wire [(pDATA_WIDTH-1):0] gm, // gre(64bit)+gim(64bit)
    output  wire [(pDATA_WIDTH-1):0] ao,
    output  wire [(pDATA_WIDTH-1):0] bo,

    // Mul interface (external instance)
    // Note: mul inputs are 128-bit (pFP_WIDTH*2 = 64*2 = 128), not pDATA_WIDTH*2
    output  wire [127:0] mul_in_A,
    output  wire [127:0] mul_in_B,
    output  wire [1:0]                  mul_mode,
    output  wire                        mul_in_valid,
    input   wire [(pDATA_WIDTH-1):0]    mul_result_c,
    input   wire [(pDATA_WIDTH-1):0]    mul_result_int,
    input   wire                        mul_out_valid,

    // FP_ADD interfaces (external instances - 4 instances)
    // Note: pFP_WIDTH = 64, defined as localparam inside module
    output  wire [63:0]                 fp_add_01_in_A,
    output  wire [63:0]                 fp_add_01_in_B,
    output  wire                        fp_add_01_in_valid,
    input   wire [63:0]                 fp_add_01_result,
    input   wire                        fp_add_01_out_valid,

    output  wire [63:0]                 fp_add_02_in_A,
    output  wire [63:0]                 fp_add_02_in_B,
    output  wire                        fp_add_02_in_valid,
    input   wire [63:0]                 fp_add_02_result,
    input   wire                        fp_add_02_out_valid,

    output  wire [63:0]                 fp_add_11_in_A,
    output  wire [63:0]                 fp_add_11_in_B,
    output  wire                        fp_add_11_in_valid,
    input   wire [63:0]                 fp_add_11_result,
    input   wire                        fp_add_11_out_valid,

    output  wire [63:0]                 fp_add_12_in_A,
    output  wire [63:0]                 fp_add_12_in_B,
    output  wire                        fp_add_12_in_valid,
    input   wire [63:0]                 fp_add_12_result,
    input   wire                        fp_add_12_out_valid

);
//==================================================================================//

localparam FFT_MUL_LATENCY = 21;
localparam FP_ADD_LATENCY  = 5 ;

localparam FFT_LATENCY     = 28;
localparam iFFT_LATENCY    = 28;

localparam mode_FFT        = 2'b00;
localparam mode_iFFT       = 2'b01;

localparam FFT_WAIT  = 3'b000;
localparam iFFT_WAIT = 3'b001;
localparam READY     = 3'b111;
//==================================================================================//
localparam pFP_WIDTH       = 64 ;
localparam pEXP_WIDTH      = 11 ;
localparam pFRAC_WIDTH     = 52 ;
//==================================================================================//
localparam pEXP_DENOR      = 11'b000_0000_0000;
localparam pEXP_INF        = 11'b111_1111_1111;
//==================================================================================//
//-------------------- Input interface and mode control ----------------------------//
reg  [2:0]                  state;
reg  [2:0]                  state_next;
reg  [1:0]                  mode_state ; //control datapath
reg  [1:0]                  mode_state_next;

reg                         buf_en;
reg  [(pDATA_WIDTH-1):0]    buf_ai;
reg  [(pDATA_WIDTH-1):0]    buf_bi;
reg  [(pDATA_WIDTH-1):0]    buf_gm;
reg                         buf_i_vld;
reg                         i_vld_en;
reg                         trans_en;
reg  [4:0]                  count;
//----------------------------- MUL & ADD FIFO ------------------------------------//
reg  [(pDATA_WIDTH-1):0]    MUL_FIFO[0:(FFT_MUL_LATENCY-1)];
reg  [(pDATA_WIDTH-1):0]    ADD_FIFO[0:(FP_ADD_LATENCY-1)] ;
//-------------------------- Multiplier operand & result  -------------------------//
wire [(pDATA_WIDTH-1):0]    a_result;
wire [(pFP_WIDTH*2-1):0]    mul_in1 ;
wire [(pFP_WIDTH*2-1):0]    mul_in2 ;
// mul_in_valid is declared as output port, no need to redeclare here
wire [(pDATA_WIDTH-1):0]    mul_result_com_wire;  // Internal wire for mul_result_c port
wire [(pDATA_WIDTH-1):0]    mul_result_int_wire;  // Internal wire for mul_result_int port
wire [(pDATA_WIDTH-1):0]    mul_result;
wire [(pFP_WIDTH-1):0]      mul_result_re_inv;
wire [(pFP_WIDTH-1):0]      mul_result_im_inv;
wire [(pDATA_WIDTH-1):0]    mul_result_inv;
wire                        mul_out_valid_internal[0:1];  // Internal wire for array usage
wire                        cmul_valid_i[0:1];
wire                        cmul_valid_o[0:3];
//----------------------------- fp_add operand -------------------------------------//
wire [(pFP_WIDTH-1):0]      fp_add_in_01[0:1] ;
wire [(pFP_WIDTH-1):0]      fp_add_in_02[0:1] ;
wire [(pFP_WIDTH-1):0]      fp_add_in_11[0:1] ;
wire [(pFP_WIDTH-1):0]      fp_add_in_12[0:1] ;
reg                         fp_add_in_valid   ;
wire [3:0]                  fp_add_out_valid  ;
wire [(pFP_WIDTH*2-1):0]    fp_add_result[0:1];
//------------------------------ ifft result ---------------------------------------//
wire [(pEXP_WIDTH-1):0]     IFFT_result_exp_im [0:1] ;
wire [(pEXP_WIDTH-1):0]     IFFT_result_exp_re [0:1] ;
wire [(pFRAC_WIDTH-1):0]    IFFT_result_frac_im[0:1] ;
wire [(pFRAC_WIDTH-1):0]    IFFT_result_frac_re[0:1] ;
wire [(pDATA_WIDTH-1):0]    cmul_result_ifft   [0:1] ;
//----------------------------- output buffer --------------------------------------//
reg  [(pDATA_WIDTH-1):0]    ao_buf   [0:1];
reg  [(pDATA_WIDTH-1):0]    bo_buf   [0:1];
reg                         o_vld_buf[0:1];

//==================================================================================//

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                       Input interface and mode control                                                                              //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// state control
// i_rdy controller
always @(*) begin
    if (i_vld && (mode_state != mode)) begin
        case (state)
        READY: begin
            trans_en = 1'b0;
            if (mode_state == mode_FFT) begin
                state_next = FFT_WAIT;
                buf_en     = 1'b1;
                i_vld_en   = 1'b0;
            end else if (mode_state == mode_iFFT) begin
                state_next = iFFT_WAIT;
                buf_en     = 1'b1;
                i_vld_en   = 1'b0;
            end else begin
                state_next = READY;
                buf_en     = 1'b0;
                i_vld_en   = 1'b1;
            end
        end
        FFT_WAIT: begin
          buf_en   = 1'b0;
          i_vld_en = 1'b0;
          if (count == FFT_LATENCY - 1) begin
            state_next = READY;
            trans_en   = 1'b1;
          end else begin
            state_next = state;
            trans_en   = 1'b0;
          end
        end
        iFFT_WAIT: begin
          buf_en   = 1'b0;
          i_vld_en = 1'b0;
          if (count == iFFT_LATENCY - 1) begin
            state_next = READY;
            trans_en   = 1'b1;
          end else begin
            state_next = state;
            trans_en   = 1'b0;
          end
        end
        default: begin
          state_next = state;
          trans_en   = 1'b0;
          buf_en     = 1'b0;
          i_vld_en   = 1'b0;
        end
        endcase
    end else begin
        state_next  = state;
        trans_en    = 1'b0;
        buf_en      = (state == READY)? 1'b1:1'b0;
        i_vld_en    = (state == READY)? 1'b1:1'b0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= READY;
    end else begin
        state <= state_next;
    end
end
//counter
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 0;
    end else if (i_vld & i_rdy) begin
      count <= 0;
    end else begin
      count <= count + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mode_state <= mode_FFT;
    end else if (trans_en) begin
      mode_state <= mode;
    end else begin
      mode_state <= mode_state;
    end
end
assign i_rdy = (state == READY)? 1'b1:1'b0;

//==================================================================================//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      buf_ai    <= {(pDATA_WIDTH){1'b0}};
      buf_bi    <= {(pDATA_WIDTH){1'b0}};
      buf_gm    <= {(pDATA_WIDTH){1'b0}};
      buf_i_vld <= 1'b0;
    end else if (buf_en) begin
      buf_ai    <= ai;
      buf_bi    <= bi;
      buf_gm    <= gm;
      buf_i_vld <= i_vld & i_rdy;
    end else begin
      buf_ai    <= buf_ai;
      buf_bi    <= buf_bi;
      buf_gm    <= buf_gm;
      buf_i_vld <= buf_i_vld;
    end
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                  MUL/ADD FIFO                                                                                       //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//=====================================================================================================================================================================//
// In this data path , use group of reg as FIFO to store some data while others are being operated :                                                                   //
//                                                                                                                                                                     //
// 1. MUL_FIFO :                                                                                                                                                       //
//    * Use to store the ain while doing FFT's complex mul .                                                                                                           //
//    * Use to store the (ain+bin) from fp_add while doing iFFT's complex mul .                                                                                        //
//                                                                                                                                                                     //
// 2. ADD_FIFO :                                                                                                                                                       //
//    * Use to store the twiddle factor while doing iFFT's  floating point add .                                                                                       //
//=====================================================================================================================================================================//
integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < FFT_MUL_LATENCY; i = i + 1) begin
          MUL_FIFO[i] <= {(pDATA_WIDTH){1'b0}};
        end
    end else begin // * FFT:00, iFFT:01
        // DIT: For both FFT and IFFT, store ai in MUL_FIFO
        MUL_FIFO[0] <= buf_ai;
        for (i = 1; i < FFT_MUL_LATENCY; i = i + 1) begin
          MUL_FIFO[i] <= MUL_FIFO[i-1];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < FP_ADD_LATENCY; i = i + 1) begin
          ADD_FIFO[i] <= {(pDATA_WIDTH){1'b0}};
        end
    end else begin
        // DIT: For both FFT and IFFT, twiddle factor is stored in ADD_FIFO
        // IFFT uses conj(w) which is already provided in buf_gm
        ADD_FIFO[0] <=  {buf_gm};
        for (i = 1; i < FP_ADD_LATENCY; i = i + 1) begin
          ADD_FIFO[i] <= ADD_FIFO[i-1];
        end
    end
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                  Multiplier operand & result                                                                        //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//=====================================================================================================================================================================//
// * If  FFT mode , do bi * gm .                                                                                                                                       //
// * If IFFT mode (DIT), do bi * conj(gm) (same as FFT, but with conjugate twiddle)                                                                                  //
//=====================================================================================================================================================================//
// DIT IFFT: First multiply bi by conj(w), then do (ai + bi*conj(w)) and (ai - bi*conj(w))
assign mul_in1       = buf_bi;  // For both FFT and IFFT, multiply bi by twiddle
assign mul_in2       = buf_gm;  // For both FFT and IFFT, use gm (IFFT uses conj(w) which is already in gm)
assign mul_in_valid  = (buf_i_vld & i_vld_en);  // Same for both modes

// Mul instance moved to testbench - connect through ports
// Mul instance moved to testbench - connect through ports
assign mul_in_A = mul_in1;
assign mul_in_B = mul_in2;
assign mul_mode = mode_state;
assign mul_result_com_wire = mul_result_c;
assign mul_result_int_wire = mul_result_int;
assign mul_out_valid_internal[0] = mul_out_valid;  // Connect port to internal wire
assign mul_result        = mul_result_com_wire;

assign mul_result_re_inv = {~mul_result_com_wire[(pFP_WIDTH*2-1)], mul_result_com_wire[(pFP_WIDTH*2-2):pFP_WIDTH]};
assign mul_result_im_inv = {~mul_result_com_wire[(pFP_WIDTH-1)]  , mul_result_com_wire[(pFP_WIDTH-2):0]};
assign mul_result_inv    = {mul_result_re_inv, mul_result_im_inv} ;

assign a_result          = MUL_FIFO[(FFT_MUL_LATENCY-1)];

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                  FP_ADD operand & result                                                                            //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// select operand OF FP_ADD in FFT 、 iFFT
// DIT IFFT: (ai + bi*conj(w)) and (ai - bi*conj(w))
// DIT FFT:  (ai + bi*w) and (ai - bi*w)
assign fp_add_in_01[0] = a_result[(pFP_WIDTH-1):0];        // ai (from MUL_FIFO)
assign fp_add_in_01[1] = mul_result[(pFP_WIDTH-1):0];      // bi*w or bi*conj(w)

assign fp_add_in_02[0] = a_result[(pFP_WIDTH*2-1):(pFP_WIDTH)];  // ai (from MUL_FIFO)
assign fp_add_in_02[1] = mul_result[(pFP_WIDTH*2-1):(pFP_WIDTH)]; // bi*w or bi*conj(w)

assign fp_add_in_11[0] = a_result[(pFP_WIDTH-1):0];              // ai (from MUL_FIFO)
assign fp_add_in_11[1] = mul_result_inv[(pFP_WIDTH-1):0];        // -(bi*w) or -(bi*conj(w))

assign fp_add_in_12[0] = a_result[(pFP_WIDTH*2-1):(pFP_WIDTH)];  // ai (from MUL_FIFO)
assign fp_add_in_12[1] = mul_result_inv[(pFP_WIDTH*2-1):(pFP_WIDTH)]; // -(bi*w) or -(bi*conj(w))

// DIT: For both FFT and IFFT, fp_add starts after mul completes
always @(*) begin
    case (mode_state)
        mode_FFT:   fp_add_in_valid = mul_out_valid_internal[0];
        mode_iFFT:  fp_add_in_valid = mul_out_valid_internal[0];  // DIT IFFT: same as FFT
        default:    fp_add_in_valid = 1'b0; // safe default
    endcase
end

//* In FFT  mode these two fp_add do (  ai + bi*w  ) 
//* In IFFT mode (DIT) these two fp_add do (  ai + bi*conj(w)  )
// FP_ADD instances moved to testbench - connect through ports
assign fp_add_01_in_A = fp_add_in_01[0];
assign fp_add_01_in_B = fp_add_in_01[1];
assign fp_add_01_in_valid = fp_add_in_valid;
assign fp_add_result[0][(pFP_WIDTH-1):0] = fp_add_01_result;
assign fp_add_out_valid[0] = fp_add_01_out_valid;

assign fp_add_02_in_A = fp_add_in_02[0];
assign fp_add_02_in_B = fp_add_in_02[1];
assign fp_add_02_in_valid = fp_add_in_valid;
assign fp_add_result[0][(pFP_WIDTH*2-1):(pFP_WIDTH)] = fp_add_02_result;
assign fp_add_out_valid[1] = fp_add_02_out_valid;

//* In FFT  mode these two fp_add do (  ai - bi*w  )
//* In IFFT mode (DIT) these two fp_add do (  ai - bi*conj(w)  )
assign fp_add_11_in_A = fp_add_in_11[0];
assign fp_add_11_in_B = fp_add_in_11[1];
assign fp_add_11_in_valid = fp_add_in_valid;
assign fp_add_result[1][(pFP_WIDTH-1):0] = fp_add_11_result;
assign fp_add_out_valid[2] = fp_add_11_out_valid;

assign fp_add_12_in_A = fp_add_in_12[0];
assign fp_add_12_in_B = fp_add_in_12[1];
assign fp_add_12_in_valid = fp_add_in_valid;
assign fp_add_result[1][(pFP_WIDTH*2-1):(pFP_WIDTH)] = fp_add_12_result;
assign fp_add_out_valid[3] = fp_add_12_out_valid;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                  iFFT's div operation (DIT)                                                                        //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//=====================================================================================================================================================================//
//  DIT IFFT: Divide by 2 at each stage                                                                                                                               //
//  * IFFT_result[0] = (ai + bi*conj(w))/2                                                                                                                            //
//  * IFFT_result[1] = (ai - bi*conj(w))/2                                                                                                                            //
//=====================================================================================================================================================================//
// * exponent of complex (ai + bi*conj(w))/2
assign IFFT_result_exp_im [0] = ( (~(|fp_add_result[0][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]))   || (&fp_add_result[0][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]  ))?  fp_add_result[0][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]   : (fp_add_result[0][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]   - 1'b1 );
assign IFFT_result_exp_re [0] = ( (~(|fp_add_result[0][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)])) || (&fp_add_result[0][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)]))?  fp_add_result[0][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)] : (fp_add_result[0][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)] - 1'b1 );
// * exponent of complex (ai - bi*conj(w))/2
assign IFFT_result_exp_im [1] = ( (~(|fp_add_result[1][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]))   || (&fp_add_result[1][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]   ))?   fp_add_result[1][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]   : (fp_add_result[1][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]   - 1'b1);
assign IFFT_result_exp_re [1] = ( (~(|fp_add_result[1][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)])) || (&fp_add_result[1][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)] ))?   fp_add_result[1][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)] : (fp_add_result[1][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)] - 1'b1);
// * fraction of complex (ai + bi*conj(w))/2
assign IFFT_result_frac_im[0] = (|fp_add_result[0][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]  )?  ((|fp_add_result[0][(pFP_WIDTH-2):(pFP_WIDTH-pEXP_WIDTH)])?      fp_add_result[0][(pFP_WIDTH-pEXP_WIDTH-2):0]            : {1'b1 , fp_add_result[0][(pFP_WIDTH-pEXP_WIDTH-2):1]}                ) : {1'b0 , fp_add_result[0][(pFP_WIDTH-pEXP_WIDTH-2):1] };
assign IFFT_result_frac_re[0] = (|fp_add_result[0][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)])?  ((|fp_add_result[0][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH)])?  fp_add_result[0][(pFP_WIDTH*2-pEXP_WIDTH-2): pFP_WIDTH] : {1'b1 , fp_add_result[0][(pFP_WIDTH*2-pEXP_WIDTH-2): (pFP_WIDTH+1) ]}) : {1'b0 , fp_add_result[0][(pFP_WIDTH*2-pEXP_WIDTH-2): (pFP_WIDTH+1)]};
// * fraction of complex (ai - bi*conj(w))/2
assign IFFT_result_frac_im[1] = (|fp_add_result[1][(pFP_WIDTH-2)  :(pFP_WIDTH-pEXP_WIDTH-1)]  )?     ((|fp_add_result[1][(pFP_WIDTH-2):(pFP_WIDTH-pEXP_WIDTH)]    )?  fp_add_result[1][(pFP_WIDTH-pEXP_WIDTH-2):0]            : {1'b1 , fp_add_result[1][(pFP_WIDTH-pEXP_WIDTH-2):1]} )                : {1'b0 , fp_add_result[1][(pFP_WIDTH-pEXP_WIDTH-2):1]} ;
assign IFFT_result_frac_re[1] = (|fp_add_result[1][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH-1)])?     ((|fp_add_result[1][(pFP_WIDTH*2-2):(pFP_WIDTH*2-pEXP_WIDTH)])?  fp_add_result[1][(pFP_WIDTH*2-pEXP_WIDTH-2): pFP_WIDTH] : {1'b1 , fp_add_result[1][(pFP_WIDTH*2-pEXP_WIDTH-2): (pFP_WIDTH+1) ]}) : {1'b0 , fp_add_result[1][(pFP_WIDTH*2-pEXP_WIDTH-2): (pFP_WIDTH+1) ]};
// * combine into complex format {real , img}
assign cmul_result_ifft[0]    = {fp_add_result[0][(pFP_WIDTH*2-1)] , IFFT_result_exp_re[0] , IFFT_result_frac_re[0] , fp_add_result[0][(pFP_WIDTH-1)] , IFFT_result_exp_im[0] , IFFT_result_frac_im[0] };
assign cmul_result_ifft[1]    = {fp_add_result[1][(pFP_WIDTH*2-1)] , IFFT_result_exp_re[1] , IFFT_result_frac_re[1] , fp_add_result[1][(pFP_WIDTH-1)] , IFFT_result_exp_im[1] , IFFT_result_frac_im[1] };



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                      Output interface                                                                               //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(*) begin
    case (mode_state) 
    mode_FFT: begin //div 2 in each stage
        ao_buf[0] = fp_add_result[0];
        bo_buf[0] = fp_add_result[1];
    end
    mode_iFFT: begin //execute in exponent module?
        ao_buf[0] = cmul_result_ifft[0];
        bo_buf[0] = cmul_result_ifft[1];
    end
    default: begin
        ao_buf[0] = {(pDATA_WIDTH){1'b0}};
        bo_buf[0] = {(pDATA_WIDTH){1'b0}};
    end
    endcase
end

always @(*) begin
    case (mode_state)
        // FFT mode: need all 4 fp_add operations to complete
        // fp_add_01 and fp_add_02 form ao (real and imag parts)
        // fp_add_11 and fp_add_12 form bo (real and imag parts)
        mode_FFT:   o_vld_buf[0] = fp_add_01_out_valid & fp_add_02_out_valid & 
                                    fp_add_11_out_valid & fp_add_12_out_valid;
        // DIT IFFT: need all 4 fp_add operations to complete (same as FFT)
        mode_iFFT:  o_vld_buf[0] = fp_add_01_out_valid & fp_add_02_out_valid & 
                                    fp_add_11_out_valid & fp_add_12_out_valid;
        default:    o_vld_buf[0] = 1'b0; // safe default
    endcase
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ao_buf[1]    <= {(pDATA_WIDTH){1'b0}};
    bo_buf[1]    <= {(pDATA_WIDTH){1'b0}};
    o_vld_buf[1] <= 1'b0;
    // ao_buf[2]    <= {(pDATA_WIDTH){1'b0}};
    // bo_buf[2]    <= {(pDATA_WIDTH){1'b0}};
    // o_vld_buf[2] <= 1'b0;
  end else begin
    ao_buf[1]    <= ao_buf[0];
    bo_buf[1]    <= bo_buf[0];
    o_vld_buf[1] <= o_vld_buf[0];
    // ao_buf[2]    <= ao_buf[1];
    // bo_buf[2]    <= bo_buf[1];
    // o_vld_buf[2] <= o_vld_buf[1];
  end
end
assign ao    = ao_buf[1];
assign bo    = bo_buf[1];
assign o_vld = o_vld_buf[1];




endmodule

