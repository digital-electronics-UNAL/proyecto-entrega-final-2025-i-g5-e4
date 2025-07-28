`include "src/Puente H/controlador_motor.v"
`timescale 1ns/1ps

module controlador_motor_tb();

    reg clk;
    reg rst;
    reg [1:0] sel;
    reg [7:0] pwm_duty;
    reg boton_pausa;

    wire AIN1;
    wire AIN2;
    wire PWMA;
    wire STBY;

    controlador_motor uut (
        .clk(clk),
        .rst(rst),
        .sel(sel),
        .pwm_duty(pwm_duty),
        .boton_pausa(boton_pausa),
        .AIN1(AIN1),
        .AIN2(AIN2),
        .PWMA(PWMA),
        .STBY(STBY)
    );

    // Reloj a 50 MHz -> Periodo 20 ns
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        // Inicialización
        rst = 1;
        sel = 2'b00;
        pwm_duty = 8'd128; // 50%
        boton_pausa = 0;
        #100;

        rst = 0;
        #100;

        // Giro horario (AIN1=1, AIN2=0)
        sel = 2'b01;
        #50000;

        // Giro antihorario (AIN1=0, AIN2=1)
        sel = 2'b10;
        #50000;

        // Activar pausa
        boton_pausa = 1;
        #20;
        boton_pausa = 0;
        #220_000_000; // Esperar más de 2 segundos para que pase la pausa

        // Protección (sel = 2'b11)
        sel = 2'b11;
        #50000;

        // Regreso a IDLE
        sel = 2'b00;
        #20000;

        $finish;
    end

    initial begin
        $dumpfile("controlador_motor_tb.vcd");
        $dumpvars(-1, uut);
    end

endmodule
