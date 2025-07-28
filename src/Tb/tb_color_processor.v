// tb_color_processor.v
// Testbench para el módulo color_processor

`timescale 1ns/1ps

module tb_color_processor;

    reg [15:0] red;
    reg [15:0] green;
    reg [15:0] blue;
    wire [1:0] color_code;
    wire [7:0] ascii_color;

    // Instancia del módulo bajo prueba
    color_processor uut (
        .red(red),
        .green(green),
        .blue(blue),
        .color_code(color_code),
        .ascii_color(ascii_color)
    );

    initial begin
        $display("Iniciando testbench para color_processor");

        // Prueba 1: Rojo dominante
        red = 16'd300;
        green = 16'd100;
        blue = 16'd100;
        #10;
        $display("Test Rojo -> color_code = %b, ascii = %c", color_code, ascii_color);

        // Prueba 2: Verde dominante
        red = 16'd100;
        green = 16'd300;
        blue = 16'd100;
        #10;
        $display("Test Verde -> color_code = %b, ascii = %c", color_code, ascii_color);

        // Prueba 3: Azul dominante
        red = 16'd100;
        green = 16'd100;
        blue = 16'd300;
        #10;
        $display("Test Azul -> color_code = %b, ascii = %c", color_code, ascii_color);

        // Prueba 4: Indefinido
        red = 16'd200;
        green = 16'd200;
        blue = 16'd200;
        #10;
        $display("Test Indefinido -> color_code = %b, ascii = %c", color_code, ascii_color);

        $finish;
    end

endmodule
