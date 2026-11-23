
module datapath(
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  ResultSrc,
    input  logic        PCSrc,
    input  logic        ALUSrc,
    input  logic        RegWrite,
    input  logic [1:0]  ImmSrc,
    input  logic [2:0]  ALUControl,
    output logic        Zero,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData
);

    logic [31:0] PCNext;
    logic [31:0] PCPlus4;
    logic [31:0] PCTarget;
    logic [31:0] ImmExt;
    logic [31:0] SrcA;
    logic [31:0] SrcB;
    logic [31:0] Result;
    logic [31:0] RD1;
    logic [31:0] RD2;

    // Program Counter
    flopr #(.WIDTH(32)) pc_reg (
        .d(PCNext),
        .clk(clk),
        .reset(reset),
        .q(PC)
    );

    // PC + 4
    adder pc_adder (
        .a(PC),
        .b(32'd4),
        .y(PCPlus4)
    );

    // Immediate Generator
    extend imm_gen (
        .instr(Instr[31:7]),
        .immsrc(ImmSrc),
        .immext(ImmExt)
    );

    // Branch / Jump target = PC + (Immediate << 1)
    adder target_adder (
        .a(PC),
        .b(ImmExt << 1),
        .y(PCTarget)
    );

    // Next PC selection
    mux2 #(.WIDTH(32)) pc_mux (
        .d0(PCPlus4),
        .d1(PCTarget),
        .s(PCSrc),
        .y(PCNext)
    );

    // Register File
    regfile rf (
        .clk(clk),
        .we3(RegWrite),
        .a1(Instr[19:15]),
        .a2(Instr[24:20]),
        .a3(Instr[11:7]),
        .wd3(Result),
        .rd1(RD1),
        .rd2(RD2)
    );

    assign WriteData = RD2;

    // ALU input selection
    assign SrcA = RD1;

    mux2 #(.WIDTH(32)) srcb_mux (
        .d0(RD2),
        .d1(ImmExt),
        .s(ALUSrc),
        .y(SrcB)
    );

    // ALU
    alu alu_unit (
        .a(SrcA),
        .b(SrcB),
        .alucontrol(ALUControl),
        .result(ALUResult)
    );

    assign Zero = (ALUResult == 32'b0);

    // Write-back selection:
    // 00 = ALU result
    // 01 = Data memory
    // 10 = PC + 4
    mux3 #(.WIDTH(32)) result_mux (
        .d0(ALUResult),
        .d1(ReadData),
        .d2(PCPlus4),
        .s(ResultSrc),
        .y(Result)
    );

endmodule
