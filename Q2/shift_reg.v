module shift_reg #(parameter N = 8, parameter SHIFT = 1) (
    input sys_rst_n,
    input clk,
    input enable,
    input [N-1:0] in,
    input [N-1:0] init,
    input load,
    input dir, // 1: right, 0: left
    output [N-1:0] out
);

    reg [N-1:0] shift;

    always @(posedge clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            shift <= init;
        end else if (!enable) begin
            shift <= shift;
        end else if (load) begin
            shift <= in;
        end else begin
            shift <= (dir) ? {shift[N-SHIFT-1:0], shift[N - 1: N - SHIFT]} : {shift[SHIFT - 1: 0], shift[N-1:SHIFT]};
        end
    end

    assign out = shift;
    
endmodule