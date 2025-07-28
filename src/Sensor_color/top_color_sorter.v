// top_color_sorter.v
// Módulo top que integra el sensor TCS34725 con salida en display 7 segmentos

module top_color_sorter (
    input wire clk,
    input wire rst,
    // I2C
    inout wire sda,
    output wire scl,
    // Display
    output wire [6:0] seg,
    output wire [3:0] an
);

    // Señales internas
    wire [15:0] red, green, blue;
    wire [1:0] color_code;
    wire [7:0] ascii_color;

    // Señales I2C
    wire i2c_start;
    wire [6:0] i2c_dev_addr;
    wire [7:0] i2c_reg_addr;
    wire [15:0] i2c_data_out;
    wire i2c_done;
    wire busy_i2c;

    // --- Controlador del sensor de color ---
    tcs34725_controller color_controller (
        .clk(clk),
        .rst(rst),
        .start_i2c(i2c_start),
        .done_i2c(i2c_done),
        .busy_i2c(busy_i2c),
        .dev_addr(i2c_dev_addr),
        .reg_addr(i2c_reg_addr),
        .data_in(i2c_data_out),
        .red(red),
        .green(green),
        .blue(blue),
        .ready() // opcional
    );

    // --- Interfaz I2C compartida ---
    i2c_master_read2bytes i2c_inst (
        .clk(clk),
        .rst(rst),
        .start(i2c_start),
        .dev_addr(i2c_dev_addr),
        .reg_addr(i2c_reg_addr),
        .data_out(i2c_data_out),
        .done(i2c_done),
        .busy(busy_i2c),
        .scl(scl),
        .sda(sda)
    );

    // --- Procesador de color ---
    color_processor color_decider (
        .red(red),
        .green(green),
        .blue(blue),
        .color_code(color_code),
        .ascii_color(ascii_color)
    );

    // --- Visualización en display de 7 segmentos ---
    bcd_to_7seg display (
        .clk(clk),
        .rst(rst),
        .color_code(color_code),
        .seg(seg),
        .an(an)
    );

endmodule
