// tcs34725_controller.v
// FSM de control para el sensor TCS34725 usando el módulo i2c_master_read2bytes

module tcs34725_controller (
    input wire clk,
    input wire rst,
    output reg start_i2c,
    input wire done_i2c,
    input wire busy_i2c,
    output reg [6:0] dev_addr,
    output reg [7:0] reg_addr,
    input wire [15:0] data_in,
    output reg [15:0] red,
    output reg [15:0] green,
    output reg [15:0] blue,
    output reg ready
);

    reg [3:0] state;

    localparam IDLE       = 0,
               START_R    = 1,
               WAIT_R     = 2,
               START_G    = 3,
               WAIT_G     = 4,
               START_B    = 5,
               WAIT_B     = 6,
               DONE       = 7;

    // Constantes del sensor
    localparam [6:0] SENSOR_ADDR = 7'h29;
    localparam [7:0] REG_RDATAL  = 8'h16;
    localparam [7:0] REG_GDATAL  = 8'h18;
    localparam [7:0] REG_BDATAL  = 8'h1A;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            start_i2c <= 0;
            dev_addr <= SENSOR_ADDR;
            reg_addr <= 0;
            red <= 0;
            green <= 0;
            blue <= 0;
            ready <= 0;
        end else begin
            case (state)
                IDLE: begin
                    start_i2c <= 1;
                    reg_addr <= REG_RDATAL;
                    state <= START_R;
                end

                START_R: begin
                    start_i2c <= 0;
                    state <= WAIT_R;
                end

                WAIT_R: begin
                    if (done_i2c) begin
                        red <= data_in;
                        start_i2c <= 1;
                        reg_addr <= REG_GDATAL;
                        state <= START_G;
                    end
                end

                START_G: begin
                    start_i2c <= 0;
                    state <= WAIT_G;
                end

                WAIT_G: begin
                    if (done_i2c) begin
                        green <= data_in;
                        start_i2c <= 1;
                        reg_addr <= REG_BDATAL;
                        state <= START_B;
                    end
                end

                START_B: begin
                    start_i2c <= 0;
                    state <= WAIT_B;
                end

                WAIT_B: begin
                    if (done_i2c) begin
                        blue <= data_in;
                        state <= DONE;
                    end
                end

                DONE: begin
                    ready <= 1;
                    state <= IDLE; // ← Repetir lectura continua
                end
            endcase
        end
    end

endmodule
