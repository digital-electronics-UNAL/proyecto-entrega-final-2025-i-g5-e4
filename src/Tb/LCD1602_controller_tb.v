`include "src/LCD/LCD1602_controller.v"
`timescale 1ns/1ps

module LCD1602_controller_tb();

reg clk;
reg [6:0] in;
reg reset;
reg ready_i;
wire rs;
wire rw;
wire enable;
wire [7:0] data;

LCD1602_controller uut (
    .clk(clk),
    .in(in),
    .reset(reset),
    .ready_i(ready_i),
    .rs(rs),
    .rw(rw),
    .enable(enable),
    .data(data)
);

initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

initial begin
    in = 7'd0;
    reset = 1;
    ready_i = 0;
    #100;
    reset = 0;
    ready_i = 1;
    #100000;
    in = 7'd123;
    #3000000;
    in = 7'd250;
    #3000000;
    in = 7'd7;
    #3000000;
    $finish;
end

initial begin
    $dumpfile("LCD1602_controller_tb.vcd");
    $dumpvars(-1, uut);
end

endmodule
