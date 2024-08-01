module instrMem(
    input logic [7:0] pc,       // Program counter input
    output logic [8:0] data     // Instruction data output
);

    // Memory array to store instructions
    logic [8:0] Core[1023:0];

    // Define the no-op instruction
    localparam [8:0] NO_OP = 9'b101100100;

    // Initialize the instruction memory
    initial begin
        integer i;
        // Set each memory location to the no-op instruction
        for (i = 0; i < 1023; i = i + 1) begin
            Core[i] = NO_OP;
        end
        // Optionally, load instructions from a file
        // $readmemb("mach_code.txt", Core);
    end

    // Combinational read logic
    always_comb begin
        data = Core[pc];
    end

endmodule
