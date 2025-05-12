module top_module (
    input sys_clk,
    input sys_rst_n,
    output CA,
    output CB,
    output CC,
    output CD,
    output CE,
    output CF,
    output CG,
    output DP,
    output [7:0] AN,
    output R_out,
    output G_out,
    output B_out
);

    parameter threshold = 1;
    parameter RED = 0, YELLOW = 1, GREEN = 2;
    reg [1:0] Q, Q_next;

    parameter [3*3-1:0] cnt_next_enable = 9'b001_100_010;
    reg [2:0] cnt_enable;
    wire [3:0] cnt [2:0];
    reg [3:0] cnt_out;
    wire [7:0] cnt_out_dec;
    wire clk;

    parameter R = 0, G = 1, B = 2;
    parameter [8*3-1:0] in_RED = 24'h00_00_32;
    parameter [8*3-1:0] in_YELLOW = 24'h00_19_19;
    parameter [8*3-1:0] in_GREEN = 24'h00_32_00;
    reg [8*3-1:0] in;

    (* keep_hierarchy = "yes" *)fq_div #(50_000_000) div_clk ( // 2 for simulation
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(clk)
    );

    (* keep_hierarchy = "yes" *)cnt_nb_down #(.Max(10), .Min(1)) cnt_RED (
        .clk(clk),
        .sys_rst_n(sys_rst_n),
        .enable(cnt_enable[RED]),
        .cnt(cnt[RED])
    );
    (* keep_hierarchy = "yes" *)cnt_nb_down #(.Max(5), .Min(1)) cnt_YELLOW (
        .clk(clk),
        .sys_rst_n(sys_rst_n),
        .enable(cnt_enable[YELLOW]),
        .cnt(cnt[YELLOW])
    );
    (* keep_hierarchy = "yes" *)cnt_nb_down #(.Max(10), .Min(1)) cnt_GREEN (
        .clk(clk),
        .sys_rst_n(sys_rst_n),
        .enable(cnt_enable[GREEN]),
        .cnt(cnt[GREEN])
    );


    (* keep_hierarchy = "yes" *)bin_to_bcd_converter #(.DIGITS(2)) b2d1 (
        .in({4'h0, cnt_out}),
        .out(cnt_out_dec)
    );
    (* keep_hierarchy = "yes" *)marquee #(.N(32)) m1 (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .enable(1'b0),
        .dir(1'b0),
        .seq({24'hfff_fff, cnt_out_dec}),
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

    (* keep_hierarchy = "yes" *)RGB_led led (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .in_R(in[R*8 +: 8]),
        .in_G(in[G*8 +: 8]),
        .in_B(in[B*8 +: 8]),
        .R(R_out),
        .G(G_out),
        .B(B_out)
    );



    always @(posedge clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
            Q <= RED;
        end else begin
            Q <= Q_next;
        end
    end
       
    always @(*) begin
        case (Q)
            RED: begin
                if (cnt_out == threshold) begin
                    Q_next = YELLOW;
                end else begin
                    Q_next = RED;
                end
            end
            YELLOW: begin
                if (cnt_out == threshold) begin
                    Q_next = GREEN;
                end else begin
                    Q_next = YELLOW;
                end
            end
            GREEN: begin
                if (cnt_out == threshold) begin
                    Q_next = RED;
                end else begin
                    Q_next = GREEN;
                end
            end
            default: Q_next <= RED;
        endcase
    end

    always @(*) begin
        case (Q)
            RED: begin
                cnt_out = cnt[RED];
            end
            YELLOW: begin
                cnt_out = cnt[YELLOW];
            end
            GREEN: begin
                cnt_out = cnt[GREEN];
            end
            default: cnt_out = cnt[RED];
        endcase
    end


    always @(posedge clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt_enable <= 3'b001;
        end else if (cnt_out == threshold) begin
            cnt_enable <= cnt_next_enable[Q*3 +: 3];
        end else begin
            cnt_enable <= cnt_enable;
        end
    end

    always @(*) begin
        case (Q)
            RED: begin
                in = in_RED;
            end
            YELLOW: begin
                in = in_YELLOW;
            end
            GREEN: begin
                in = in_GREEN;
            end
            default: in = in_RED;
        endcase
    end

endmodule

module cnt_nb_down #(
    parameter Max = 15,
    parameter Min = 0
)(
    input clk,
    input enable,
    input sys_rst_n,
    output reg [$clog2(Max + 1) - 1:0] cnt
);

    always @(posedge clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt <= Max;
        end else if (!enable) begin
            cnt <= cnt;
        end else if (cnt == Min) begin
            cnt <= Max;
        end else begin
            cnt <= cnt - 1;
        end
    end

endmodule
