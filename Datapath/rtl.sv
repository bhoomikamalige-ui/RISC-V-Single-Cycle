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

    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] RD1, RD2;
    logic [31:0] ImmExt;
    logic [31:0] SrcB;
    logic [31:0] Result;

    // Program Counter
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'h80000000;
        else
            PC <= PCNext;
    end

    assign PCPlus4 = PC + 32'd4;

    // Register File
    regfile rf(
        .clk(clk),
        .we3(RegWrite),
        .a1(Instr[19:15]),
        .a2(Instr[24:20]),
        .a3(Instr[11:7]),
        .wd3(Result),
        .rd1(RD1),
        .rd2(RD2)
    );

    // Immediate Generator
    extend ext(
        .instr(Instr[31:7]),
        .immsrc(ImmSrc),
        .immext(ImmExt)
    );

    // ALU input selection
    assign SrcB = ALUSrc ? ImmExt : RD2;

    // ALU
    alu alu_unit(
        .SrcA(RD1),
        .SrcB(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    // Memory write data
    assign WriteData = RD2;

    // Branch / Jump target
    assign PCTarget = PC + (ImmExt << 1);

    // Write-back selection
    always_comb begin
        case (ResultSrc)
            2'b00: Result = ALUResult;
            2'b01: Result = ReadData;
            2'b10: Result = PCPlus4;
            default: Result = 32'b0;
        endcase
    end

    // Next PC selection
    assign PCNext = PCSrc ? PCTarget : PCPlus4;

endmodule
