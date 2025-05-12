module tb_top_module;

reg sys_clk;
reg sys_rst_n;
wire R, G, B;

top_module dut (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .R(R),
    .G(G),
    .B(B)
);

always begin
    #5 sys_clk = ~sys_clk;
end

initial begin
    sys_clk = 1;
    sys_rst_n = 0;
    
    // apply reset
    #3 sys_rst_n = 0;
    #3 sys_rst_n = 1;
    
    // simulate for some time to check the state transitions
    #1000;
    
    $finish;
end

endmodule
