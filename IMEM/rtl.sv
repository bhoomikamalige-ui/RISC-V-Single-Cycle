
module imem(
    input  logic [31:0] a,
    output logic [31:0] rd
);

    logic [31:0] mem [0:63];

    initial begin
        $readmemh("IMEM/memfile.txt", mem);
    end

    always_comb begin
        if ((a[1:0] == 2'b00) && (a[31:8] == 0))
            rd = mem[a[7:2]];
        else
            rd = 32'b0;
    end

endmodule
