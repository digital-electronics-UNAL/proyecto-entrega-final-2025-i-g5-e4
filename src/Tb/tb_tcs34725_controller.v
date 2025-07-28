// tb_tcs34725_controller.v
// Testbench para tcs34725_controller usando un I2C simulado

`timescale 1ns/1ps

module tb_tcs34725_controller;

    reg clk;
    reg rst;
    wire start_i2c;
    reg done_i2c;
    reg busy_i2c;
    wire [6:0] dev_addr;
    wire [7:0] reg_addr;
    reg [15:0] data_in;
    wire [15:0] red, green, blue;
    wire ready;

    // Instancia del DUT
    tcs34725_controller dut (
        .clk(clk),
        .rst(rst),
        .start_i2c(start_i2c),
        .done_i2c(done_i2c),
        .busy_i2c(busy_i2c),
        .dev_addr(dev_addr),
        .reg_addr(reg_addr),
        .data_in(data_in),
        .red(red),
        .green(green),
        .blue(blue),
        .ready(ready)
    );

    // Reloj 50 MHz
    always #10 clk = ~clk;

    initial begin
        $display("Iniciando testbench de TCS34725 controller");
        clk = 0;
        rst = 1;
        done_i2c = 0;
        busy_i2c = 0;
        data_in = 0;
        #100;

        rst = 0;
        #100;

        // Simular respuesta del sensor para RED
        wait(start_i2c == 1);
        #20; // delay arbitrario
        data_in = 16'h0123;
        done_i2c = 1;
        #20;
        done_i2c = 0;

        // Simular respuesta para GREEN
        wait(start_i2c == 1);
        #20;
        data_in = 16'h0456;
        done_i2c = 1;
        #20;
        done_i2c = 0;

        // Simular respuesta para BLUE
        wait(start_i2c == 1);
        #20;
        data_in = 16'h0789;
        done_i2c = 1;
        #20;
        done_i2c = 0;

        // Esperar señal ready
        wait(ready);
        $display("RED   = %h", red);
        $display("GREEN = %h", green);
        $display("BLUE  = %h", blue);

        #100;
        $finish;
    end

endmodule
