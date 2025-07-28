// Módulo I2C Master para comunicación con TCS3472
module i2c_refactor (
    input clk,           // Reloj del sistema
    input rst,           // Reset global
    input start,         // Señal de inicio de transacción
    input rw,            // 0 = write , 1 = read
    //input [6:0] addr,    // Dirección del esclavo (0x29)
   //input [7:0] reg_addr,// Dirección del registro a leer o escribir
    //input [7:0] data_in, // Dato a escribir si rw = 0
    output reg [7:0] data_out,// Dato leído si rw = 1
    output reg done,          // Señal que indica fin de transacción
    inout sda,           // Línea de datos bidireccional
    output scl           // Línea de reloj (salida)

);

// Parámetros
parameter CLK_DIV = 250; // para 100 kHz si clk = 50 MHz

//FSM
localparam IDLE            = 4'd0;
localparam START           = 4'd1;
localparam SEND_ADDR_WR    = 4'd2;
localparam WAIT_ACK_WR     = 4'd3;
localparam SEND_REG_ADDR   = 4'd4;
localparam WAIT_ACK_REG    = 4'd5;
localparam RESTART         = 4'd6;
localparam SEND_ADDR_RD    = 4'd7;
localparam WAIT_ACK_RD     = 4'd8;
localparam READ_BYTE       = 4'd9;
localparam SEND_NACK       = 4'd10;  
localparam STOP            = 4'd11;
localparam DONE            = 4'd12;

//Registros internos
reg [3:0] state, next_state;
reg [7:0] shift_reg;
reg [2:0] bit_cnt;
reg [15:0] clk_cnt;
reg scl_reg, sda_out, sda_out_en;
wire scl_tick;

assign scl = (state == SEND_ADDR_WR || state == WAIT_ACK_WR)? scl_reg : 1'b1;
assign sda = sda_out_en ? sda_out : 1'bz;

wire [7:0] addr_wr = {8'h29, 1'b0}; // write
wire [7:0] addr_rd = {8'h29}; // read

initial begin
    state <= IDLE;
    data_out <= 'd0;
    scl_reg <= 'd0;
    sda_out <= 'd0;
    sda_out_en <= 'd0;
    clk_cnt <= 'd0;
    bit_cnt <= 'd0;
    shift_reg <= 'd0;
end


always @(posedge clk) begin
    if (!rst) begin
        clk_cnt <= 0;
        scl_reg <= 1;
    end else begin
        if (clk_cnt == (CLK_DIV - 1)*2) begin
            clk_cnt <= 0;
            scl_reg <= ~scl_reg;
        end else begin
            clk_cnt <= clk_cnt + 1;
        end
    end
end

assign scl_tick = (clk_cnt == (CLK_DIV - 1)*2 && scl_reg);

always @(posedge clk) begin
    if (!rst)
        state <= IDLE;
    else if (scl_tick) begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        IDLE: next_state <= (start)? START : IDLE;
        START: next_state <= SEND_ADDR_WR;
        SEND_ADDR_WR: next_state <=  (bit_cnt==3'd0)? WAIT_ACK_WR : SEND_ADDR_WR;
        WAIT_ACK_WR: next_state <=  (sda == 0)? SEND_REG_ADDR : STOP;
        SEND_REG_ADDR: next_state <= (bit_cnt == 0)? WAIT_ACK_REG : SEND_REG_ADDR;
        WAIT_ACK_REG:  next_state = (sda == 0) ? RESTART : STOP;
        RESTART: next_state = SEND_ADDR_RD;
        SEND_ADDR_RD:  next_state = (bit_cnt == 0) ? WAIT_ACK_RD : SEND_ADDR_RD;
        WAIT_ACK_RD:   next_state = (sda == 0) ? READ_BYTE : STOP;
        READ_BYTE:     next_state = (bit_cnt == 0) ? SEND_NACK : READ_BYTE;
        SEND_NACK:     next_state = STOP;
        STOP:          next_state = DONE;
        DONE:    next_state = IDLE;
        default:       next_state = IDLE;
    endcase
end

always @(posedge clk) begin
    if (!rst) begin
        sda_out <= 1;
        sda_out_en <= 1;
        done <= 0;
        bit_cnt <= 3'd7;
    end else if(scl_tick) begin
        case (state)
            IDLE: begin
                done <= 0;
                sda_out_en <= 1;
                sda_out <= 1;
            end
            START: begin
                sda_out_en <= 1;
                sda_out <= 0; // START: SDA baja mientras SCL alto
                shift_reg <= addr_wr;
                bit_cnt <= 3'd7;
            end
            SEND_ADDR_WR: begin
                sda_out_en <= 1;
                sda_out <= shift_reg[bit_cnt];
                if (bit_cnt > 3'd0)
                    bit_cnt <= bit_cnt - 1;
            end
            WAIT_ACK_WR: begin
                sda_out_en <= 0; // Liberar SDA para leer ACK
            end

            RESTART: begin
                sda_out_en <= 1;
                sda_out <= 1;
                sda_out <= 0; // Nueva condición START
                shift_reg <= addr_rd;
                bit_cnt <= 3'd7;
            end

            READ_BYTE: begin
                sda_out_en <= 0; // Leer SDA
                shift_reg[bit_cnt] <= sda;
                if (bit_cnt > 0)
                    bit_cnt <= bit_cnt - 1;
                else
                    data_out <= shift_reg;
            end

            SEND_NACK: begin
                sda_out_en <= 1;
                sda_out <= 1; // NACK
            end

            STOP: begin
                sda_out_en <= 1;
                sda_out <= 0;
            end

            DONE: begin
                sda_out <= 1; // STOP: SDA sube mientras SCL alto
                done <= 1;
            end
        endcase
    end
end

endmodule