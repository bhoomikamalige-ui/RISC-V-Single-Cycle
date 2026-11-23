
module aludec(
    input  logic [1:0] ALUOp,
    input  logic [2:0] funct3,
    input  logic       op5,
    input  logic       funct7b5,
    output logic [2:0] ALUControl
);

    always_comb begin
        case (ALUOp)

            // Load and Store: ADD
            2'b00:
                ALUControl = 3'b000;

            // Branch: SUB
            2'b01:
                ALUControl = 3'b001;

            // R-type and I-type ALU instructions
            2'b10: begin
                case (funct3)
                    3'b000:
                        ALUControl = (op5 && funct7b5)
                                     ? 3'b001 : 3'b000;

                    3'b010: ALUControl = 3'b101; // SLT
                    3'b110: ALUControl = 3'b011; // OR
                    3'b111: ALUControl = 3'b010; // AND

                    default: ALUControl = 3'b000;
                endcase
            end

            default:
                ALUControl = 3'b000;

        endcase
    end

endmodule
