`timescale 1ns/1ps
module mul_tb();

    reg [127:0]     A;
    reg [127:0]     B;
    reg [1:0]       mode;
    reg             in_valid;
    wire[127:0]     result_c ;
    wire[127:0]     result_int;
    wire            out_valid;
    reg             clk;
    reg             rst_n;

    mul mul_DUT(
        .in_A( A ),
        .in_B( B ),
        .mode( mode ), // * set mode = 0000 to do complex mul ， mode = 10 to do mul
        .clk  (clk  ),
        .rst_n ( rst_n ),
        .in_valid( in_valid ),
        .result_c( result_c ),  
        .result_int( result_int ),
        .out_valid ( out_valid )
    );

    initial begin
        $fsdbDumpfile("mul.fsdb");
        $fsdbDumpvars("+mda");
    end

    // initial begin
    //     $dumpfile("mul_tb.vcd");
    //     $dumpvars();
    // end

    initial begin
        clk = 0;
        forever begin
            #5 clk = (~clk);
        end
    end

    integer timeout = (20000);
    initial begin
        while(timeout > 0) begin
            @(posedge clk);
            timeout = timeout - 1;
        end
        $display($time, "Simualtion Hang ....");
        $finish;
    end

    initial begin
        rst_n <= 1;
        @(negedge clk);
        #2
        rst_n <= 0; 
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        rst_n <= 1;
    end


    integer Din_a_com  , Din_b_com , Gin_com;
    integer Din_num1_fp0, Din_num2_fp0, Gin_fp0;
    integer Din_num1_fp1, Din_num2_fp1, Gin_fp1;
    integer a_in_com , b_in_com , g_in_com ;
    integer m,n;

    localparam PAT_NUM = 100;
    localparam PAT2_NUM = 200;

    // complex number test set
    reg[127:0]   complex_A_list [0:PAT_NUM-1];
    reg[127:0]   complex_B_list [0:PAT_NUM-1];
    // float number test sets (two independent sets)
    reg[63:0]    float_A0_list [0:PAT2_NUM-1];
    reg[63:0]    float_B0_list [0:PAT2_NUM-1];
    reg[63:0]    float_A1_list [0:PAT2_NUM-1];
    reg[63:0]    float_B1_list [0:PAT2_NUM-1];
    reg[63:0]    golden_list_fp0 [0:PAT2_NUM-1];
    reg[63:0]    golden_list_fp1 [0:PAT2_NUM-1];

    reg[127:0]   golden_list_complex[0:PAT_NUM-1];
// set pattern //
    initial begin
        Din_a_com = $fopen("./mul_pat/complex_A.dat" , "r");
        Din_b_com = $fopen("./mul_pat/complex_B.dat" , "r");
        Din_num1_fp0 = $fopen("./mul_pat_v2/num1_hex_0.dat", "r");
        Din_num2_fp0 = $fopen("./mul_pat_v2/num2_hex_0.dat", "r");
        Din_num1_fp1 = $fopen("./mul_pat_v2/num1_hex_1.dat", "r");
        Din_num2_fp1 = $fopen("./mul_pat_v2/num2_hex_1.dat", "r");
        
        Gin_com   = $fopen("./mul_pat/golden_complex.dat" , "r");
        Gin_fp0   = $fopen("./mul_pat_v2/golden_0.dat", "r");
        Gin_fp1   = $fopen("./mul_pat_v2/golden_1.dat", "r");
        
        if (Din_a_com == 0 || Din_b_com == 0 || Gin_com == 0 || Din_num1_fp0 == 0 ||
        Din_num2_fp0 == 0 || Din_num1_fp1 == 0 || Din_num2_fp1 == 0 || Gin_fp0 == 0 || Gin_fp1 == 0) begin
            $display("[ERROR] Failed to open pattern file....");
            $finish;
        end else begin 
            for(m=0 ; m<PAT_NUM ;m=m+1)begin
                a_in_com    = $fscanf(Din_a_com , "%h" , complex_A_list[m]);
                b_in_com    = $fscanf(Din_b_com , "%h" , complex_B_list[m]);

                g_in_com    = $fscanf(Gin_com , "%h" , golden_list_complex[m]);
            end
            for(m=0 ; m<PAT2_NUM; m=m+1)begin
                a_in_com = $fscanf(Din_num1_fp0 , "%h" , float_A0_list[m]);
                b_in_com = $fscanf(Din_num2_fp0 , "%h" , float_B0_list[m]);
                g_in_com = $fscanf(Gin_fp0 , "%h" , golden_list_fp0[m]);

                a_in_com = $fscanf(Din_num1_fp1 , "%h" , float_A1_list[m]);
                b_in_com = $fscanf(Din_num2_fp1 , "%h" , float_B1_list[m]);
                g_in_com = $fscanf(Gin_fp1 , "%h" , golden_list_fp1[m]);
            end
        end
        $display("---------------------- papttern initialize done -----------------------------");
    end

//
    integer i;

    initial begin
        in_valid  <= 0;
        wait(rst_n == 0);
        wait(rst_n == 1);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        for(i=0 ; i<PAT_NUM ;i=i+1)begin
            complex_dat_in(complex_A_list[i] , complex_B_list[i] ) ;
        end

        repeat(30) @(posedge clk);
        for (i=0; i<PAT2_NUM; i=i+1)begin
            float_dat_in({float_A1_list[i], float_A0_list[i]}, {float_B1_list[i], float_B0_list[i]});
        end
        in_valid  <= 0;
    end

    integer j;
    integer err_cnt;

    reg com_error;

    initial begin
        com_error <=0;
        err_cnt = 0;
        wait(rst_n == 0);
        wait(rst_n == 1);
        @(posedge clk);
        for(j=0 ; j<PAT_NUM;j=j+1)begin
            complex_out_check(golden_list_complex[j] , j);
        end
        repeat(10) @(posedge clk);
        for(j=0 ; j<PAT2_NUM;j=j+1)begin
            float_out_check({golden_list_fp1[j], golden_list_fp0[j]} , j);
        end
        repeat(2000) @(posedge clk);
        if(com_error)begin
            $display("----------- Simulation ERROR (QAQ)-------------------");
            $display("%d pattern is fail.", err_cnt);
            //$finish;
        end else begin
            $display("###########################################################");
            $display("##             COMPLEX PATTERN PASS                      ##");
            $display("###########################################################");
        end
        $display("----------- Simulation PASS (^_^) -------------------");
        $finish;
    end


    task complex_dat_in ;
        input  [127:0]  in_1;
        input  [127:0]  in_2;
        begin
            @(posedge clk);
            @(posedge clk)            
            in_valid <= 1;
            mode     <= 0;
            A        <= in_1;
            B        <= in_2;
            @(posedge clk)
            in_valid <= 0;
            mode     <= 0;
            A        <= 0;
            B        <= 0;
        end
    endtask

        task float_dat_in ;
        input  [127:0]  in_1;
        input  [127:0]  in_2;
        begin
            @(posedge clk);
            @(posedge clk)            
            in_valid <= 1;
            mode     <= 2'b10;
            A        <= in_1;
            B        <= in_2;
            @(posedge clk)
            in_valid <= 0;
            mode     <= 2'b10;
            A        <= 0;
            B        <= 0;
        end
    endtask



    task complex_out_check ;
        input   [127:0] answer_complex;
        input   [31:0] ocnt;
        begin
            while (!out_valid) @(posedge clk);   
            if( (result_c !== answer_complex) )begin
                $display("[ERROR] [COMPLEX_Pattern %d] Golden : %h , Your : %h", ocnt, answer_complex, result_c);
                com_error <= 1;
                err_cnt = err_cnt + 1;
            end else begin
                $display("[PASS]  [COMPLEX_Pattern %d] Golden : %h , Your : %h", ocnt, answer_complex , result_c);
            end
            @(posedge clk);
        end
    endtask

    task float_out_check ;
        input   [127:0] answer_float;
        input   [31:0] ocnt;
        begin
            while (!out_valid) @(posedge clk);   
            if( (result_c !== answer_float) )begin
                $display("[ERROR] [FLOAT_Pattern %d] Golden : %h , Your : %h", ocnt, answer_float, result_c);
                com_error <= 1;
                err_cnt = err_cnt + 1;
            end else begin
                $display("[PASS]  [FLOAT_Pattern %d] Golden : %h , Your : %h", ocnt, answer_float , result_c);
            end
            @(posedge clk);
        end
    endtask

endmodule
