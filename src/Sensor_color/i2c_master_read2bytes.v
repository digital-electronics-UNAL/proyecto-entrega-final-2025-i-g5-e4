module i2c_master_read2bytes (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [6:0] dev_addr,
    input wire [7:0] reg_addr,
    output reg [15:0] data_out,
    output reg busy,
    output reg done,
    inout wire sda,
    output reg scl
);

    reg [7:0] clk_div;
    wire tick = (clk_div == 0);

    always @(posedge clk or posedge rst) begin
        if (rst) clk_div <= 200;
        else clk_div <= tick ? 200 : clk_div - 1;
    end

    reg [3:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg [7:0] byte1, byte2;

    reg sda_out, sda_oe;
    assign sda = sda_oe ? sda_out : 1'bz;

    localparam IDLE=0, START=1, SLA_W=2, REG=3, REP_START=4, 
               SLA_R=5, READ1=6, ACK1=7, READ2=8, NACK=9, 
               STOP=10, DONE=11;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            scl <= 1;
            sda_out <= 1;
            sda_oe <= 1;
            busy <= 0;
            done <= 0;
            data_out <= 0;
        end else if (tick) begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        busy <= 1;
                        sda_out <= 1;
                        scl k<= 1;
                        sda_oe <= 1;
                        state <= START;
                    end
                end
                START: begin
                    sda_out <= 0; // START: SDA baja mientras SCL alto
                    scl <= 1;
                    shift_reg <= {dev_addr, 1'b0}; // Write
                    bit_cnt <= 7;
                    state <= SLA_W;
                end
                SLA_W: begin
                    scl <= 0;
                    sda_out <= shift_reg[bit_cnt];
                    bit_cnt <= bit_cnt - 1;
                    scl <= 1;
                    if (bit_cnt == 0) state <= REG;
                end
                REG: begin
                    scl <= 0;
                    shift_reg <= reg_addr;
                    bit_cnt <= 7;
                    state <= 12;
                end
                12: begin // enviar reg_addr
                    scl <= 0;
                    sda_out <= shift_reg[bit_cnt];
                    bit_cnt <= bit_cnt - 1;
                    scl <= 1;
                    if (bit_cnt == 0) state <= REP_START;
                end
                REP_START: begin
                    scl <= 1;
                    sda_out <= 1; // STOP momentáneo
                    sda_out <= 0; // START repetido
                    shift_reg <= {dev_addr, 1'b1}; // Read
                    bit_cnt <= 7;
                    state <= SLA_R;
                end
                SLA_R: begin
                    scl <= 0;
                    sda_out <= shift_reg[bit_cnt];
                    bit_cnt <= bit_cnt - 1;
                    scl <= 1;
                    if (bit_cnt == 0) state <= READ1;
                end
                READ1: begin
                    scl <= 0;
                    sda_oe <= 0;
                    bit_cnt <= 7;
                    state <= 13;
                end
                13: begin
                    scl <= 1;
                    byte1[bit_cnt] <= sda;
                    bit_cnt <= bit_cnt - 1;
                    if (bit_cnt == 0) state <= ACK1;
                end
                ACK1: begin
                    scl <= 0;
                    sda_oe <= 1;
                    sda_out <= 0; // ACK
                    scl <= 1;
                    bit_cnt <= 7;
                    state <= READ2;
                end
                READ2: begin
                    scl <= 0;
                    sda_oe <= 0;
                    state <= 14;
                end
                14: begin
                    scl <= 1;
                    byte2[bit_cnt] <= sda;
                    bit_cnt <= bit_cnt - 1;
                    if (bit_cnt == 0) state <= NACK;
                end
                NACK: begin
                    scl <= 0;
                    sda_oe <= 1;
                    sda_out <= 1; // NACK
                    scl <= 1;
                    state <= STOP;
                end
                STOP: begin
                    scl <= 1;
                    sda_out <= 0;
                    sda_out <= 1;
                    state <= DONE;
                end
                DONE: begin
                    data_out <= {byte2, byte1};
                    busy <= 0;
                    done <= 1;
                    if (!start) state <= IDLE;
                end
            endcase
        end
    end
endmodule
