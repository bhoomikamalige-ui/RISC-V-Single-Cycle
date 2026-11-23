
module dmem(
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a,
    input  logic [31:0] wd,
    output logic [31:0] rd
);

    logic [31:0] mem [0:63];

    // Combinational read
    always_comb begin
        rd = mem[a[7:2]];
    end

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we)
            mem[a[7:2]] <= wd;
    end

endmodule
