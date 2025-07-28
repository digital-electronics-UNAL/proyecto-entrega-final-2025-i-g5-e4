module antirrebote#(parameter COUNT=5000) (
    input clk,
    input btn,
    output reg clean = 0
);
    reg [$clog2(COUNT)-1:0] count = 0;
    reg btn_sync = 0;

    always @(posedge clk) begin
        btn_sync <= btn;
        if (btn_sync == clean) begin
            count <= 0;
        end else begin
            count <= count + 1;
            if (count == COUNT)
                clean <= btn_sync;
        end
    end
endmodule