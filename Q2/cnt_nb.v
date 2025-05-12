module cnt_nb #(
    parameter Max = 15,
    parameter Min = 0
)(
    input clk,
    input enable,
    input sys_rst_n,
    input U_D, // 1: down, 0: up
    output reg [$clog2(Max + 1) - 1:0] cnt
);

    reg dir;

    always @(posedge clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt <= Min;
        end else if (!enable) begin
            cnt <= cnt;
        end else if (cnt == Max && dir == 0) begin
            cnt <= Min;
        end else if (cnt == Min && dir == 1) begin
            cnt <= Max;
        end else begin
            cnt <= (dir) ? cnt - 1 : cnt + 1;
        end
    end

    always @(negedge clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            dir <= 1'b0;
        end else begin
            dir <= U_D;
        end
    end

endmodule
