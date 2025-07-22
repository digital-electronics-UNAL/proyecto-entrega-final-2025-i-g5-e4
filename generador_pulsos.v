module generador_pulsos #(
    parameter CLOCK_FREQ = 50_000_000,         // 50 MHz
    parameter PULSE_INTERVAL_MS = 60           // Intervalo entre pulsos en milisegundos
)(
    input clk,
    input rst,
    output reg pulse_out
);

    localparam PULSE_CYCLES = (CLOCK_FREQ / 10000) * PULSE_INTERVAL_MS;

    reg [7:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            pulse_out <= 0;
        end else begin
            if (counter >= PULSE_CYCLES) begin
                counter <= 0;
                pulse_out <= 1;
            end else begin
                counter <= counter + 1;
                pulse_out <= 0;
            end
        end
    end

endmodule
