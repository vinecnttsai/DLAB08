module top_module (
    input sys_clk,
    input sys_rst_n,
    output wire R,
    output wire G,
    output wire B
);

parameter [11:0] color_R = 12'b01_01_00_00_11_11;
parameter [11:0] color_G = 12'b00_00_11_11_01_01;
parameter [11:0] color_B = 12'b11_11_01_01_00_00;

parameter [7:0] color_init_R = 8'h32;
parameter [7:0] color_init_G = 8'h00;
parameter [7:0] color_init_B = 8'h00;

parameter state_max = 6;
parameter gradient_max = 25;
parameter duty_cycle_max = 100;
parameter N = duty_cycle_max * 100_000; // duty_cycle_max * 1 for Simulation

reg [7:0] duty_cycle [0:2];
wire clk;
reg threshold;
wire [4:0] cnt;
wire [2:0] state;
integer i;

always @(posedge clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        threshold <= 0;
    else
        threshold <= (cnt == gradient_max - 1);
end

fq_div #(.N(N)) div_clk (
    .org_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .div_n_clk(clk)
);

cnt_nb #(.Max(gradient_max-1), .Min(0)) cnt_24 (
    .clk(clk),
    .sys_rst_n(sys_rst_n),
    .enable(1'b1),
    .U_D(1'b0),
    .cnt(cnt)
);

cnt_nb #(.Max(state_max-1), .Min(0)) cnt_5 (
    .clk(threshold),
    .sys_rst_n(sys_rst_n),
    .enable(1'b1),
    .U_D(1'b0),
    .cnt(state)
);


PWM pwmR (
    .clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .duty_cycle(duty_cycle[0]),
    .out(R)
);
PWM pwmG (
    .clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .duty_cycle(duty_cycle[1]),
    .out(G)
);
PWM pwmB (
    .clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .duty_cycle(duty_cycle[2]),
    .out(B)
);

always @(posedge clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        duty_cycle[0] <= color_init_R;
        duty_cycle[1] <= color_init_G;
        duty_cycle[2] <= color_init_B;
    end else begin
        for (i = 0; i < 3; i = i + 1) begin
            case ( (i == 0) ? color_R[state*2 +: 2] :
                   (i == 1) ? color_G[state*2 +: 2] :
                              color_B[state*2 +: 2] )
                2'b00: duty_cycle[i] <= duty_cycle[i];
                2'b01: duty_cycle[i] <= duty_cycle[i] + 1;
                2'b11: duty_cycle[i] <= duty_cycle[i] - 1;
                default: duty_cycle[i] <= duty_cycle[i];
            endcase
        end
    end
end

endmodule
