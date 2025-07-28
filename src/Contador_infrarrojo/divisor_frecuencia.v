module divisor_frecuencia #(
    parameter integer CLK_IN_FREQ = 50_000_000,      // Frecuencia de entrada (Hz)
    parameter integer CLK_OUT_FREQ = 1_000_000       // Frecuencia deseada de salida (Hz)
)(
    input wire clk_in,       // Reloj del sistema
    input wire rst,          // Reset síncrono
    output reg clk_out       // Salida de reloj dividido
);

    localparam integer COUNT_MAX = CLK_IN_FREQ / (2 * CLK_OUT_FREQ);  // Cuenta hasta la mitad del periodo
    reg [$clog2(COUNT_MAX)-1:0] count = 0;

    always @(posedge clk_in) begin
        if (rst) begin
            count <= 0;
            clk_out <= 0;
        end else begin
            if (count == COUNT_MAX - 1) begin
                count <= 0;
                clk_out <= ~clk_out;
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule
