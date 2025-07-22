module controlador_ultrasonido #(
    parameter TIME_TRIG = 500,                     // Duración del pulso TRIG
    parameter CLOCK_FREQ = 50_000_000,             // Frecuencia del reloj en Hz
    parameter SOUND_SPEED = 34300,                 // Velocidad del sonido en cm/s
    parameter DIST_THRESHOLD_CM = 50               // Distancia mínima para detección (en cm)
)(
    input clk,
    input rst,
    input ready_i,
    input echo_i,
    output wire trigger_o,
    output wire object_detected_o,
    output reg [7:0] counter
);

	reg [$clog2(1_000)-1:0] echo_counter;

    // Estados de la FSM
    localparam IDLE       = 3'b000;
    localparam TRIGGER    = 3'b001;
    localparam WAIT_ECHO  = 3'b010;
    localparam COUNT_ECHO = 3'b011;
	 localparam GET_ECHO = 3'b100;

    reg [2:0] fsm_state, next_state;
    reg [$clog2(TIME_TRIG)-1:0] count_10us;

    wire trigger_done;
    assign trigger_o = (fsm_state == TRIGGER);  // TRIG activo en estado TRIGGER
    assign trigger_done = (count_10us == TIME_TRIG);

    // Cambio de estado
    always @(posedge clk) begin
        if (rst)
            fsm_state <= IDLE;
        else
            fsm_state <= next_state;
    end
	 
	 initial begin
		fsm_state <= IDLE;
		count_10us <= 'd0;
		counter <= 'd0;
		echo_counter <= 'd0;
	 end

    // Lógica de transición de estados
    always @(*) begin
        case (fsm_state)
            IDLE:        next_state = (ready_i) ? TRIGGER : IDLE;
            TRIGGER:     next_state = (trigger_done) ? WAIT_ECHO : TRIGGER;
            WAIT_ECHO:   next_state = (echo_i) ? COUNT_ECHO : WAIT_ECHO;
            COUNT_ECHO:  next_state = (echo_i) ? COUNT_ECHO : GET_ECHO;
				GET_ECHO: next_state = IDLE;
            default:     next_state = IDLE;
        endcase
    end

    // Contadores
    always @(posedge clk) begin
        if (rst) begin
            count_10us <= 0;
            echo_counter <= 0;
				counter <= 0;
        end else begin
            case (fsm_state)
                IDLE: begin
                    count_10us <= 0;
                    //echo_counter <= 0;
                end
                TRIGGER: begin
                    count_10us <= count_10us + 1;
                end
                WAIT_ECHO: begin
                    echo_counter <= 0;
                end
                COUNT_ECHO: begin
                    echo_counter <= echo_counter + 1;
                end
					 GET_ECHO: begin
						counter <= echo_counter;
					 end
            endcase
        end
    end

    // Cálculo de distancia y detección de objeto
    wire [31:0] distance_cm;
    assign distance_cm = (echo_counter * SOUND_SPEED) / (2 * CLOCK_FREQ);
    assign object_detected_o = (distance_cm < DIST_THRESHOLD_CM);

endmodule
