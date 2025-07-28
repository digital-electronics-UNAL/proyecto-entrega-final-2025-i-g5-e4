`include "src/Contador_infrarrojo/antirrebote.v"
`timescale 1ns/1ps

module antirrebote_tb();

    reg clk;
    reg btn;
    wire clean;

    antirrebote uut (
        .clk(clk),
        .btn(btn),
        .clean(clean)
    );

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk; // Periodo de 20 ns (50 MHz)
    end

    initial begin
        btn = 1'b0;
        #100;

        // Simulación de rebotes rápidos
        btn = 1'b1; #30;
        btn = 1'b0; #20;
        btn = 1'b1; #50;
        btn = 1'b0; #40;
        btn = 1'b1; #20;
        btn = 1'b0; #20;
        btn = 1'b1; // Pulso estable
        #500000;

        btn = 1'b0; // Soltar el botón con rebotes
        #50;
        btn = 1'b1; #30;
        btn = 1'b0; #20;
        btn = 1'b1; #40;
        btn = 1'b0;
        #500000;

        $finish;
    end

    initial begin
        $dumpfile("antirrebote_tb.vcd");
        $dumpvars(-1, uut);
    end

endmodule
