module DSP_tb ();
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
    reg  [17:0] A, B, BCIN;
    reg  [47:0] C;
    wire CARRYOUT, CARRYOUTF;
    reg CARRYIN;
    reg  [17:0] D;
    wire [35:0] M;
    wire [47:0] P;
    reg clk;
    reg [7:0] OPMODE;
    reg CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE;
    reg CEP, RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
    wire [17:0] BCOUT;
    wire [47:0] PCOUT;
    reg [47:0] PCIN;

    // Instantiate the Unit Under Test (UUT)
    DSP #(
        .A0REG(A0REG),
        .A1REG(A1REG),
        .B0REG(B0REG),
        .B1REG(B1REG),
        .CREG(CREG),
        .DREG(DREG),
        .MREG(MREG),
        .PREG(PREG),
        .CARRTINREG(CARRTINREG),
        .CARRYOUTREG(CARRYOUTREG),
        .OPMODEREG(OPMODEREG),
        .CARRYINSEL(CARRYINSEL),
        .B_INPUT(B_INPUT),
        .RSTTYPE(RSTTYPE)
    ) Dut (.*);

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units   
    end

    // ++++++++++++++++++++++++++++++ RST TEST +++++++++++++++++++++++++++++
    initial begin
        // active reset
        RSTA = 1; RSTB = 1; RSTC = 1; RSTCARRYIN = 1; RSTD = 1; RSTM = 1; RSTOPMODE = 1; RSTP = 1;
        // Initialize control signals to 1 
        CEA = 1; CEB = 1; CEC = 1; CECARRYIN = 1; CED = 1; CEM = 1; CEOPMODE = 1; CEP = 1;
        // Initialize inputs to 1
        A = 1; B = 1; C = 1; BCIN = 1; CARRYIN = 1; D = 1; OPMODE = 1; PCIN = 1;

        @(negedge clk);
        // deactivate reset   
        RSTA = 0; RSTB = 0; RSTC = 0; RSTCARRYIN = 0; RSTD = 0; RSTM = 0; RSTOPMODE = 0; RSTP = 0;
        if (P !== 0 || M !== 0 || PCOUT !== 0 || BCOUT !== 0 || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test for RST Failed");
            $stop;
        end

        // +++++++++++++++++++++++++ opmode [0] test ++++++++++++++++++++++  
        OPMODE = 8'b00000001;
        A = 18'd6; B = 18'd14; C = 48'd43; BCIN = 18'd34; CARRYIN = 1; D = 18'd12;
        repeat (4) @(negedge clk);
        if (P !== (A*B) || M !== (A*B) || PCOUT !== (A*B) || BCOUT !== B || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for OPMODE[0] fail");
            $stop;
        end

        // ++++++++++++++++++++++++ opmode [1] test ++++++++++++++++++++++       
        OPMODE = 8'b00000010;
        repeat (4) @(negedge clk);
        if (P !== P || M !== (A*B) || PCOUT !== P || BCOUT !== B || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for OPMODE[1] fail");
            $stop;
        end

        // +++++++++++++++++++++++ opmode [2] test +++++++++++++++++++++++   
        OPMODE = 8'b00000100;
        repeat (4) @(negedge clk);
        if (P !== PCIN || M !== (A*B) || PCOUT !== PCIN || BCOUT !== B || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for OPMODE[2] fail");
            $stop;
        end

        // +++++++++++++++++++++++ opmode [3] test+++++++++++++++++++++++++   
        OPMODE = 8'b00001000;
        repeat (4) @(negedge clk);
        if (P !== P || M !== (A*B) || PCOUT !== P || BCOUT !== B || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for OPMODE[3] fail");
            $stop;
        end
         
        // ++++++++++++++++++++++ opmode [4] test +++++++++++++++++++++++++++   
        OPMODE = 8'b00010000;
        repeat (4) @(negedge clk);
        if (P !== 0 || M !== (B+D)*A || PCOUT !== 0 || BCOUT !== (B+D) || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for OPMODE[4] fail");
            $stop;
        end

        // ++++++++++++++++++++++ opmode [5] test +++++++++++++++++++++++++++   
        OPMODE = 8'b00100000;
        repeat (4) @(negedge clk);
        if (P !== 1 || M !== B*A || PCOUT !== 1 || BCOUT !== B || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for OPMODE[5] fail");
            $stop;
        end

        // ++++++++++++++++++++++ opmode [6] test +++++++++++++++++++++++++++   
        OPMODE = 8'b01000000;
        repeat (4) @(negedge clk);
        if (P !== 0 || M !== B*A || PCOUT !== 0 || BCOUT !== B || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for OPMODE[6] fail");
            $stop;
        end

        // ++++++++++++++++++++++ opmode [7] test +++++++++++++++++++++++++++   
        OPMODE = 8'b10000000;
        repeat (4) @(negedge clk);
        if (P !== 0 || M !== A*B || PCOUT !== 0 || BCOUT !== B || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for OPMODE[7] fail");
            $stop;
        end

        // ++++++++++++++++++++++ wrong opmode test ++++++++++++++++++++++++++
        OPMODE = 8'b00000000;
        repeat (4) @(negedge clk);
        if (P !== 0 || M !== A*B || PCOUT !== 0 || BCOUT !== B || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for wrong OPMODE fail");
            $stop;
        end

        // +++++++++++++++++++++++ random opmode test +++++++++++++++++++++++++
        OPMODE = 8'b01100101;
        A = 18'd6; B = 18'd5; C = 48'd3; D = 18'd8; BCIN = 18'd4; CARRYIN = 1'b1;
        repeat (4) @(negedge clk);
        if (P !== (PCIN + (A*B) + 1) || M !== (A*B) || PCOUT !== (PCIN + (A*B)) + 1 || BCOUT !== B || CARRYOUT !== 0 || CARRYOUTF !== 0) begin
            $display("Test Failed for random OPMODE fail: DUT");
            $stop;
        end
        
        $display("++++++++++++++++++++++");
        $display("All tests passed");
        $display("++++++++++++++++++++++");
        $stop;
    end

    initial begin
        $monitor("%0t : A=%0d, B=%0d, C=%0d, D=%0d, OPMODE=%0b, P=%0d, M=%0d, PCOUT=%0d, BCOUT=%0d, CARRYOUT=%0b, CARRYOUTF=%0b",
            $time, A, B, C, D, OPMODE, P, M, PCOUT, BCOUT, CARRYOUT, CARRYOUTF);
    end
endmodule
