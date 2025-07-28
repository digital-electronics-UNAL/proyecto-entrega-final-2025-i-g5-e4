`include "src/Contador_infrarrojo/contador.v"
`timescale 1ns/1ps

module contador_tb();


reg infrarrojo;
reg rst;


    contador uut (
        .cuenta(infrarrojo),
        .rst_n(rst)
    );

    initial begin
        rst = 1'b1;
        infrarrojo = 1'b0;
        #20;
        rst = 1'b0;
        #20;
        rst = 1'b1;
        #100
        infrarrojo = 1'b1;
        #10;
        infrarrojo = 1'b0;
        #10;
        infrarrojo = 1'b1;
        #10;
        infrarrojo = 1'b0;
        #1000;
        infrarrojo = 1'b1;
        #10;
        infrarrojo = 1'b0;
        #10;
        rst = 1'b0;
        #20;
        rst = 1'b1;

       
    end

    initial begin
        $dumpfile("contador_tb.vcd");
        $dumpvars(-1, uut);
        #10000 $finish;
    end

endmodule