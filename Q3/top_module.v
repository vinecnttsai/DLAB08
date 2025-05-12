module top_module (
    input sys_clk,
    input sys_rst_n,
    input seq,
    output ans,
    output reg [7:0] LED
);

    fq_div #(50_000_000) div_clk ( // 1. theoretically 2 Hz 2. "2" for simulation
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(clk)
    );

    always @(posedge clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            LED = 8'h00;
        end

        LED = {LED[6:0], seq};
    end

    assign ans = (LED == 8'b10111001);

endmodule