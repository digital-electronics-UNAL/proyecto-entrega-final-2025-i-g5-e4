module controlador_motor (
    input wire clk,
    input wire rst,
    input wire [1:0] sel,
    input wire [7:0] pwm_duty,
    input wire boton_pausa,
    output wire AIN1,
    output wire AIN2,
    output wire PWMA,
    output wire STBY
);

    reg [1:0] sel_protected;
    reg [1:0] fsm_state, next_state;
    localparam IDLE = 2'b00, CLOCK_WISE = 2'b01, COUNTER_CLOCK_WISE = 2'b10, PROTECTION = 2'b11;

 
    reg pause_active = 0;
    reg [26:0] pause_counter = 0;  // 2^27 / 50e6 ≈ 2.68 segundos

    always @(posedge clk) begin
        if (rst) begin
            pause_active <= 0;
            pause_counter <= 0;
        end else if (boton_pausa && !pause_active) begin
            pause_active <= 1;
            pause_counter <= 0;
        end else if (pause_active) begin
            if (pause_counter < 100_000_000)  // 2 segundos a 50 MHz
                pause_counter <= pause_counter + 1;
            else
                pause_active <= 0;
        end
    end

 
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
        if (fsm_state == PROTECTION || pause_active)
            sel_protected = 2'b00;
        else
            sel_protected = sel;
    end

    assign AIN1 = sel_protected[0];
    assign AIN2 = sel_protected[1];
    assign STBY = 1'b1;

 
    reg [11:0] clkdiv = 0;
    always @(posedge clk) clkdiv <= clkdiv + 1;
    wire pwm_clk = clkdiv[11];  // ~24kHz

    reg [7:0] pwm_counter = 0;
    always @(posedge pwm_clk) pwm_counter <= pwm_counter + 1;

    assign PWMA = (pause_active) ? 1'b0 : (pwm_counter < pwm_duty);

endmodule
