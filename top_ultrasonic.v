module top_ultrasonic #(parameter CLOCK_FREQ = 50_000_000,       // Frecuencia del sistema (50 MHz)
    parameter PULSE_INTERVAL_MS = 60,        // Intervalo entre pulsos
    parameter DIST_THRESHOLD_CM = 10)(
    input wire clk,
    input wire rst_n,
    input wire echo_i,
    output wire trigger_o,
    output wire [7:0] LCD_DATA,
    output wire LCD_RS,
    output wire LCD_RW,
    output wire LCD_E
//	 output wire object_detected_o_fpga  
	 
);


	wire rst = ~rst_n;
	
    wire object_detected;
    wire [7:0] echo_count;
    reg [7:0] conteo_objetos = 8'd0;
	     // Señal de pulso para habilitar medición
	wire ready_pulse;

    // Señal interna de detección
//    wire object_detected_internal;

    reg object_detected_prev;

    always @(posedge clk) begin
        if (rst) begin
            object_detected_prev <= 0;
            conteo_objetos <= 0;
        end else begin
            object_detected_prev <= object_detected;
            if (~object_detected_prev & object_detected) begin
                conteo_objetos <= conteo_objetos + 1;
            end
        end
    end
	 
	  generador_pulsos #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .PULSE_INTERVAL_MS(PULSE_INTERVAL_MS)
    ) u_pulsos (
        .clk(clk),
        .rst(rst),
        .pulse_out(ready_pulse)
   );

    controlador_ultrasonido #(
        .TIME_TRIG(500),
        .CLOCK_FREQ(50_000_000),
        .SOUND_SPEED(34300),
        .DIST_THRESHOLD_CM(50)
    ) sensor_ultrasonido (
        .clk(clk),
        .rst(rst),
        .ready_i(ready_pulse),
        .echo_i(echo_i),
        .trigger_o(trigger_o),
        .object_detected_o(object_detected_internal),
        .counter(echo_count)
    );
	 

    LCD1602_controller lcd (
        .clk(clk),
        .reset(rst),
        .in(echo_count),
        .ready_i(1'b1),
        .rs(LCD_RS),
        .rw(LCD_RW),
        .enable(LCD_E),
        .data(LCD_DATA)
    );
//	 assign object_detected_o_fpga = ~object_detected_internal;

endmodule
