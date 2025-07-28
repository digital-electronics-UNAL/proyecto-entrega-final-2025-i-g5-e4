module antirrebote (
    input clk,
    input btn,
    output reg clean = 0
);
    reg [15:0] count = 0;
    reg btn_sync = 0;

    always @(posedge clk) begin
        btn_sync <= btn;
        if (btn_sync == clean) begin
            count <= 0;
        end else begin
            count <= count + 1;
            if (count == 4200)
                clean <= btn_sync;
        end
    end
endmodule