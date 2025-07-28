module bcd_to_7seg (
    input wire clk,
    input wire rst,
    input wire [1:0] color_code,   // Entrada del color codificado
    output reg [6:0] seg,          // Salida para display (ánodo común)
    output reg [3:0] an            // Activación de dígitos
);

    always @(*) begin
        // Activamos solo un dígito (por ejemplo el primero)
        an = 4'b1110;  // Display de 4 dígitos: activo bajo, activamos solo el más bajo

        // Decodificamos el color a segmentos
        case (color_code)
            2'b00: seg = 7'b1110001; // 'r' (parecido a 'P' sin segmentos f y g)
            2'b01: seg = 7'b1000000; // 'g' (como el número 6)
            2'b10: seg = 7'b1111000; // 'b' (como un 3 o B)
            2'b11: seg = 7'b0111111; // '-' (solo segmento g)
            default: seg = 7'b1111111; // Apagar todo
        endcase
    end

endmodule
