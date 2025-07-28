// color_processor.v
// Módulo para clasificar color a partir de valores R, G, B

module color_processor (
    input wire [15:0] red,
    input wire [15:0] green,
    input wire [15:0] blue,
    output reg [1:0] color_code,  // 00 = RED, 01 = GREEN, 10 = BLUE, 11 = UNKNOWN
    output reg [7:0] ascii_color  // Código ASCII del nombre (R, G, B, U)
);

    always @(*) begin
        if (red > green && red > blue) begin
            color_code = 2'b00;
            ascii_color = "R";  // ASCII 82
        end else if (green > red && green > blue) begin
            color_code = 2'b01;
            ascii_color = "G";  // ASCII 71
        end else if (blue > red && blue > green) begin
            color_code = 2'b10;
            ascii_color = "B";  // ASCII 66
        end else begin
            color_code = 2'b11;
            ascii_color = "U";  // ASCII 85
        end
    end

endmodule
