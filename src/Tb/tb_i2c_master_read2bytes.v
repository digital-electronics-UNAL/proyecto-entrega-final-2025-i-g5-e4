teclado y todo // tb_i2c_master_read2bytes.v
// Testbench para el módulo i2c_master_read2bytes

`timescale 1ns/1ps

module tb_i2c_master_read2bytes;

    reg clk;
    reg rst;
    reg start;
    reg [6:0] dev_addr;
    reg [7:0] reg_addr;
    wire [15:0] data_out;
    wire busy;
    wire done;
    wire sda;
    wire scl;

    // Pull-up para SDA simulada
    tri1 sda_pullup = sda;

    // Instancia del DUT
    i2c_master_read2bytes dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .dev_addr(dev_addr),
        .reg_addr(reg_addr),
        .data_out(data_out),
        .busy(busy),
        .done(done),
        .sda(sda_pullup),
        .scl(scl)
    );

    // Reloj de 50 MHz
    always #10 clk = ~clk;

    initial begin
        $display("Testbench iniciado");
        clk = 0;
        rst = 1;
        start = 0;
        dev_addr = 7'h29; // Dirección típica del TCS34725
        reg_addr = 8'h16; // Registro RDATAL (Red low byte)

        #100;
        rst = 0;
        #100;

        start = 1;
        #20;
        start = 0;

        // Esperar a que done se active
        wait(done);

        $display("Lectura completa: %h", data_out);
        #100;
        $stop;
    end

endmodule
