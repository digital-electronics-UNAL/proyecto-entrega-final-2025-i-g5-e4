module controlador_motor (
    input wire clk,
    input wire rst,
    input wire [1:0] sel,
    input wire [7:0] pwm_duty,
    output wire AIN1,
    output wire AIN2,
    output wire PWMA,
    output wire STBY
);

    reg [1:0] sel_protected;

    localparam IDLE = 2'b00, CLOCK_WISE = 2'b01, COUNTER_CLOCK_WISE = 2'b10, PROTECTION = 2'b11;
    reg [1:0] fsm_state, next_state;

    always @(negedge clk or posedge rst) begin
        if (rst)
            fsm_state <= IDLE;
        else
            fsm_state <= next_state;
    end

    always @(*) begin
        next_state = sel;
    end

    always @(*) begin
        if (fsm_state == PROTECTION)
            sel_protected = 2'b00;
        else
            sel_protected = sel;
    end

    
    assign AIN1 = sel_protected[0];  // bit bajo
    assign AIN2 = sel_protected[1];  // bit alto

    assign STBY = 1'b1;  // Habilitar driver

    // <<< PWM lento >>>
    reg [11:0] clkdiv = 0;
    always @(posedge clk) clkdiv <= clkdiv + 1;
    wire pwm_clk = clkdiv[11];  // 50MHz / 2048 ≈ 24kHz

    reg [7:0] pwm_counter = 0;
    always @(posedge pwm_clk) pwm_counter <= pwm_counter + 1;

    assign PWMA = (pwm_counter < pwm_duty);

endmodule
