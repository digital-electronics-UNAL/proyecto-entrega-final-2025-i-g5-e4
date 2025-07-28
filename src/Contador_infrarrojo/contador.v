module contador (
    input wire cuenta,        //Entrada que incrementa el contador en 1
    input wire rst_n,         // Reset asíncrono activo en bajo
    output reg [9:0] salida       // Salida del registro
);
//registro

reg [9:0] q,d;

initial begin
    q = 10'b0;
    d = 10'b0;
end


always @(posedge cuenta or negedge rst_n) begin
    if (rst_n==0)
        q <= 10'b0;            // Reset asíncrono: limpia el registro
    else
        q <= d;               // Si enable está activo, carga el dato
end
//Sumador
always @(*)begin

 d <= 1'b1 + q;
 salida <=q;
 
 end

endmodule
