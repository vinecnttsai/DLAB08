module marquee #(parameter N = 32) (
    input sys_clk,
    input sys_rst_n,
    input enable,
    input dir,
    input [N-1:0] seq,
    output CA, 
    output CB,
    output CC, 
    output CD,
    output CE,
    output CF, 
    output CG,
    output DP,
    output [7:0] AN
);

wire [2:0] cnt;
wire clk_low;
wire clk_high;
parameter WIDTH = 4;
wire [N - 1 : 0] seq_shift;

fq_div #(50_000_000) fq_div_200 (
    .sys_rst_n(sys_rst_n),
    .org_clk(sys_clk),
    .div_n_clk(clk_low)
);


fq_div #(5_000) fq_div_10 (
    .sys_rst_n(sys_rst_n),
    .org_clk(sys_clk),
    .div_n_clk(clk_high)
);

cnt_nb #(.Max(8 - 1), .Min(0)) cnt_7 (
    .clk(clk_high),
    .sys_rst_n(sys_rst_n),
    .enable(1'b1),
    .U_D(1'b0),
    .cnt(cnt)
);

svn_dcdr_n svn1 (
    .in(seq_shift[cnt * WIDTH +: WIDTH]),
    .clk(clk_high),
    .sys_rst_n(sys_rst_n),
    .CA(CA),
    .CB(CB),
    .CC(CC),
    .CD(CD),
    .CE(CE),
    .CF(CF),
    .CG(CG),
    .DP(DP),
    .AN(AN)
);
assign temp = seq_shift[cnt * WIDTH +: WIDTH];

marquee_shift #(.N(N), .SHIFT(WIDTH)) sequence_shift (
    .sys_rst_n(sys_rst_n),
    .clk(clk_low),
    .enable(enable),
    .seq(seq),
    .init(seq),
    .dir(dir),
    .out(seq_shift)
);

endmodule


module marquee_shift #(parameter N = 32, parameter SHIFT = 4) (
    input sys_rst_n,
    input clk,
    input enable,
    input [N-1:0] seq,
    input [N-1:0] init,
    input dir, // 1: right, 0: left
    output [N-1:0] out
);

    reg [N-1:0] shift;
    wire [$clog2(N/SHIFT)-1:0] cnt;

    always @(*) begin
        if (!sys_rst_n) begin
            shift <= init;
        end else begin
            shift <= (seq >> (SHIFT * cnt)) | (seq << (N - SHIFT * cnt));
        end
    end

    assign out = shift;

    cnt_nb #(.Max(N/SHIFT - 1), .Min(0)) cnt_ (
        .clk(clk),
        .sys_rst_n(sys_rst_n),
        .enable(enable),
        .U_D(dir),
        .cnt(cnt)
    );
    
endmodule