
module dmem(
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a,
    input  logic [31:0] wd,
    output logic [31:0] rd
);

    logic [31:0] mem [0:63];
    integer i;

    // Initialize all 64 words
    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'b0;
    end

    // Combinational read
    assign rd = mem[a[7:2]];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we)
            mem[a[7:2]] <= wd;
    end

endmodule
