module tb_top_module;

    reg sys_clk;
    reg sys_rst_n;
    wire CA, CB, CC, CD, CE, CF, CG, DP;
    wire [7:0] AN;
    wire R_out, G_out, B_out;

    wire [1:0] Q, Q_next;
    
    top_module dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .DP(DP),
        .AN(AN),
        .R_out(R_out),
        .G_out(G_out),
        .B_out(B_out)
    );

    always begin
        #1 sys_clk = ~sys_clk;
    end

    initial begin
        sys_clk = 0;
        sys_rst_n = 1;

        // apply reset
        #8 sys_rst_n = 0;
        #3 sys_rst_n = 1;
        
        // simulate for some time to check the state transitions
        #2000;
        
        $finish;
    end

endmodule
