`timescale 1ns/1ps

module PWM_tb;

reg clk;
reg sys_rst_n;
reg [6:0] duty_cycle;
wire out;

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end

PWM uut (
    .clk(clk),
    .sys_rst_n(sys_rst_n),
    .duty_cycle(duty_cycle),
    .out(out)
);
integer i;
initial begin
    sys_rst_n = 0;
    duty_cycle = 7'd50;
    
    // apply reset
    #20 sys_rst_n = 1;
    
    for (i = 0; i <= 100; i = i + 10) begin
        set_duty(i);
        #200;
    end
    
    $finish;
end

task set_duty(input [6:0] new_duty);
begin
    duty_cycle = new_duty;
end
endtask

endmodule
