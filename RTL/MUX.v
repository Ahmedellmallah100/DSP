 module MUX (in,out,en,clk,rst);
    // Parameters
    parameter RSTTYPE = "SYNC";
    parameter sel     = 1;
    parameter size    = 18;

    // Ports
    input  [size-1:0] in;
    input   rst, clk, en;
    output [size-1:0] out;

    // Internal register
    reg [size-1:0] in_reg;

    // Registering logic
    generate
        if (RSTTYPE == "SYNC") begin
            // Synchronous reset
            always @(posedge clk) begin
                if (rst)
                    in_reg <= 0;
                else if (en)
                    in_reg <= in;
            end
        end else begin
            // Asynchronous reset
            always @(posedge clk or posedge rst) begin
                if (rst)
                    in_reg <= 0;
                else if (en)
                    in_reg <= in;
            end
        end
    endgenerate

    // Output selection (MUX)
    assign out =(sel)? in_reg:in;
endmodule // MUX
