
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

    logic [31:0] pc_next, pc_plus4, pc_target;
    logic [31:0] rd1, rd2, srcB;
    logic [31:0] ImmExt, Result;
    logic [31:0] regs [0:31];

    integer i;

    // Program Counter
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'h80000000;
        else
            PC <= pc_next;
    end

    assign pc_plus4 = PC + 32'd4;
    assign pc_target = PC + (ImmExt << 1);
    assign pc_next = PCSrc ? pc_target : pc_plus4;

    // Register File
    assign rd1 = (Instr[19:15] == 0) ? 32'd0 : regs[Instr[19:15]];
    assign rd2 = (Instr[24:20] == 0) ? 32'd0 : regs[Instr[24:20]];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end
        else if (RegWrite && (Instr[11:7] != 0)) begin
            regs[Instr[11:7]] <= Result;
        end
    end

    assign WriteData = rd2;

    // Immediate Generator
    always_comb begin
        case (ImmSrc)
            2'b00: ImmExt = {{20{Instr[31]}}, Instr[31:20]};
            2'b01: ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};
            2'b10: ImmExt = {{19{Instr[31]}}, Instr[31], Instr[7],
                              Instr[30:25], Instr[11:8]};
            2'b11: ImmExt = {{11{Instr[31]}}, Instr[31], Instr[19:12],
                              Instr[20], Instr[30:21]};
            default: ImmExt = 32'd0;
        endcase
    end

    // ALU
    assign srcB = ALUSrc ? ImmExt : rd2;

    always_comb begin
        case (ALUControl)
            3'b000: ALUResult = rd1 + srcB;
            3'b001: ALUResult = rd1 - srcB;
            3'b010: ALUResult = rd1 & srcB;
            3'b011: ALUResult = rd1 | srcB;
            3'b100: ALUResult = rd1 ^ srcB;
            3'b101: ALUResult = ($signed(rd1) < $signed(srcB)) ? 32'd1 : 32'd0;
            3'b110: ALUResult = rd1 << srcB[4:0];
            3'b111: ALUResult = rd1 >> srcB[4:0];
            default: ALUResult = 32'd0;
        endcase
    end

    assign Zero = (ALUResult == 32'd0);

    // Write-back Result Multiplexer
    always_comb begin
        case (ResultSrc)
            2'b00: Result = ALUResult;
            2'b01: Result = ReadData;
            2'b10: Result = pc_plus4;
            default: Result = 32'd0;
        endcase
    end

endmodule
