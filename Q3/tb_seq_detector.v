`timescale 1ns/1ps

module tb_top_module;

reg sys_clk;
reg sys_rst_n;
reg seq;
wire ans;
wire [7:0] LED;

top_module uut (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .seq(seq),
    .ans(ans),
    .LED(LED)
);

parameter [7:0] input_sequence = 8'b10111001;
integer i, k;

initial begin
    sys_clk = 0;
    forever #10 sys_clk = ~sys_clk;
end

initial begin
    sys_rst_n = 0;
    seq = 0;
    // apply reset
    #3 sys_rst_n = 1;

    for (k = 0; k < 10; k = k + 1) begin
        for (i = 7; i >= 0; i = i - 1) begin
            seq = input_sequence[i];
            @(posedge uut.clk);
        end
    end

    $finish;
end

endmodule
