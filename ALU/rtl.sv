
module alu(
    input  logic [31:0] SrcA,
    input  logic [31:0] SrcB,
    input  logic [2:0]  ALUControl,
    output logic [31:0] ALUResult,
    output logic       Zero
);

    always_comb begin
        case (ALUControl)

            3'b000: ALUResult = SrcA + SrcB;
            3'b001: ALUResult = SrcA - SrcB;
            3'b010: ALUResult = SrcA & SrcB;
            3'b011: ALUResult = SrcA | SrcB;
            3'b100: ALUResult = SrcA ^ SrcB;
            3'b101: ALUResult = ($signed(SrcA) < $signed(SrcB))
                                ? 32'd1 : 32'd0;
            3'b110: ALUResult = SrcA << SrcB[4:0];
            3'b111: ALUResult = SrcA >> SrcB[4:0];

            default: ALUResult = 32'b0;

        endcase
    end

    assign Zero = (ALUResult == 32'b0);

endmodule
