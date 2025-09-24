module DSP (
    A, B, C, BCIN,
    CARRYOUT, CARRYOUTF, CARRYIN,
    D, M, P,
    clk, OPMODE,
    CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP,
    RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP,
    BCOUT, PCIN, PCOUT
);

// Parameters   
parameter A0REG = 0;
parameter A1REG = 1;
parameter B0REG = 0;
parameter B1REG = 1;
parameter CREG = 1, DREG = 1, MREG = 1, PREG = 1, CARRTINREG = 1, CARRYOUTREG = 1, OPMODEREG = 1;
parameter CARRYINSEL = "OPMODE5";
parameter B_INPUT = "DIRECT";
parameter RSTTYPE = "SYNC";

// Ports
input  [17:0] A, B, BCIN;
input  [47:0] C;
output CARRYOUT, CARRYOUTF;
input CARRYIN;
input  [17:0] D;
output [35:0] M;
output [47:0] P;
input clk;
input [7:0] OPMODE;
input CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE;
input CEP, RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
output [17:0] BCOUT;
input  [47:0] PCIN;
output [47:0]  PCOUT;

// internal signals
wire [7:0] OPMODE_REG;
wire [17:0] B_cascade;
wire [17:0] a0_reg, b0_reg;
wire [47:0] c_reg;
wire [17:0] d_reg;
wire [17:0] a1_reg, b1_reg;
wire [17:0] pre_adder_sub;
wire [17:0] mux1;
wire [35:0] mul_out;
wire [35:0] mul_reg;
wire carry_cascade;
wire carryin_reg;
reg [47:0] x_reg, z_reg;
wire [47:0] post_add_sub;

// Registers instantiation


MUX #(.RSTTYPE(RSTTYPE), .sel(OPMODEREG), .size(8)) opmode_reg (.in(OPMODE), .out(OPMODE_REG), .en(CEOPMODE), .clk(clk), .rst(RSTOPMODE)); 
assign B_cascade = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 17'b0; 

MUX #(.RSTTYPE(RSTTYPE), .sel(A0REG), .size(18)) A0_REG (.in(A), .out(a0_reg), .en(CEA), .clk(clk), .rst(RSTA)); 
MUX #(.RSTTYPE(RSTTYPE), .sel(B0REG), .size(18)) B0_REG (.in(B_cascade), .out(b0_reg), .en(CEB), .clk(clk), .rst(RSTB)); 
MUX #(.RSTTYPE(RSTTYPE), .sel(CREG),  .size(48)) C_REG  (.in(C), .out(c_reg), .en(CEC), .clk(clk), .rst(RSTC)); 
MUX #(.RSTTYPE(RSTTYPE), .sel(DREG),  .size(18)) D_REG  (.in(D), .out(d_reg), .en(CED), .clk(clk), .rst(RSTD)); 

MUX #(.RSTTYPE(RSTTYPE), .sel(A1REG), .size(18)) A1_REG (.in(a0_reg), .out(a1_reg), .en(CEA), .clk(clk), .rst(RSTA)); 

// Pre-adder logic
assign pre_adder_sub = (OPMODE_REG[6] == 1'b0) ? b0_reg + d_reg : b0_reg - d_reg;
assign mux1 = (OPMODE_REG[4] == 1'b0) ? b0_reg : pre_adder_sub;

// B1 register
MUX #(.RSTTYPE(RSTTYPE), .sel(B1REG), .size(18)) B1_REG (.in(mux1), .out(b1_reg), .en(CEB), .clk(clk), .rst(RSTB)); 
assign BCOUT = b1_reg; 

// Multiplier logic
assign mul_out = a1_reg * b1_reg;
MUX #(.RSTTYPE(RSTTYPE), .sel(MREG), .size(36)) Mul_reg (.in(mul_out), .out(mul_reg), .en(CEM), .clk(clk), .rst(RSTM)); 
assign M = mul_reg; 

// Carryin logic
assign carry_cascade = (CARRYINSEL == "OPMODE5") ? OPMODE[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 1'b0; 
MUX #(.RSTTYPE(RSTTYPE), .sel(CARRTINREG), .size(1)) CARRYIN_REG (.in(carry_cascade), .out(carryin_reg), .en(CECARRYIN), .clk(clk), .rst(RSTCARRYIN)); 

// X mux
always @(*) begin
    case (OPMODE_REG[1:0])
        2'b00: x_reg = 48'b0;
        2'b01: x_reg = {12'b0, mul_reg};
        2'b10: x_reg = P;
        2'b11: x_reg = {d_reg[11:0], a1_reg, b1_reg};
        default: x_reg = 48'b0;
    endcase
end

// Z mux
always @(*) begin
    case (OPMODE_REG[3:2])
        2'b00: z_reg = 48'b0;
        2'b01: z_reg = PCIN;
        2'b10: z_reg = P;
        2'b11: z_reg = c_reg;
        default: z_reg = 48'b0;
    endcase
end

// Add/Sub logic
assign {carryout_in, post_add_sub} = (OPMODE_REG[7] == 1'b0) ? z_reg + x_reg + carryin_reg : z_reg - (x_reg + carryin_reg);

// Carryout logic
MUX #(.RSTTYPE(RSTTYPE), .sel(CARRYOUTREG), .size(1)) CARRYOUT_REG (.in(carryout_in), .out(CARRYOUT), .en(CECARRYIN), .clk(clk), .rst(RSTCARRYIN)); 
assign CARRYOUTF = CARRYOUT; 

// P register
MUX #(.RSTTYPE(RSTTYPE), .sel(PREG), .size(48)) P_REG (.in(post_add_sub), .out(P), .en(CEP), .clk(clk), .rst(RSTP)); 
assign PCOUT = P; 




endmodule // DSP
