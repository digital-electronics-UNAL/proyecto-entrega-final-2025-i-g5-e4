`timescale 1ns/1ps
`include "src/Sensor_color/i2c_refactor.v"

module i2c_refactor_tb;

  reg clk = 0;
  reg rst = 0;
  reg start = 0;
  reg rw = 1;  // lectura
  reg [6:0] addr = 7'h29;       // Dirección I2C del TCS3472
  reg [7:0] reg_addr = 8'h16;   // Registro de color rojo
  reg [7:0] data_in = 8'h00;
  wire [7:0] data_out;
  wire done;

  wire scl;
  wire sda;

  always #10 clk = ~clk;

  i2c_refactor dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .rw(rw),
    .addr(addr),
    .reg_addr(reg_addr),
    .data_in(data_in),
    .data_out(data_out),
    .done(done),
    .sda(sda),
    .scl(scl)
  );

  reg sda_slave = 1'bz;
  assign sda = (sda_drive_en) ? sda_slave : 1'bz;

  reg sda_drive_en = 0;
  reg [7:0] slave_memory [0:255]; // Memoria simulada del sensor
  reg [7:0] shift_out;
  reg [3:0] bit_cnt;
  reg ack_phase = 0;

  initial begin
    // Simulamos que en el registro 0x16 (RED) hay el valor 0xAB
    slave_memory[8'h16] = 8'hAB;
  end

  // Slave emulado: responde con ACKs
  always @(negedge scl) begin
    if (sda_drive_en && ack_phase == 0) begin
      sda_slave <= 0; // ACK
      ack_phase <= 1;
    end else if (ack_phase == 1) begin
      sda_slave <= 1'bz;
      ack_phase <= 0;
    end
  end

  // Emulación de envío de datos al maestro
  always @(posedge scl) begin
    if (!sda_drive_en && dut.state == 9) begin // READ_BYTE state
      sda_drive_en <= 1;
      shift_out <= slave_memory[reg_addr];
      bit_cnt <= 7;
    end else if (sda_drive_en && bit_cnt >= 0 && dut.state == 9) begin
      sda_slave <= shift_out[bit_cnt];
      bit_cnt <= bit_cnt - 1;
    end else begin
      sda_drive_en <= 0;
      sda_slave <= 1'bz;
    end
  end

  initial begin 
    rst = 1;
    #100;
    // Reset
    rst = 0;
    #100;
    rst = 1;

    // Esperar antes de iniciar la transacción
    #200;
    start = 1;

    // Esperar a que termine la transacción
    // wait (done);
  end

  initial begin
    $dumpfile("i2c_refactor_tb.vcd");
    $dumpvars(0, i2c_refactor_tb);
    #400000 $finish;
  end

endmodule