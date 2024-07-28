module instrMem(
    input logic [7:0] pc,       // Program counter input
    output logic [8:0] data     // Instruction data output
);

    // Memory array to store instructions
    logic [8:0] Core[255:0];

    // Optional: Initialize the instruction memory from a file
	 // I'm not sure how getting machine code into instrMem works, experiment with this.
    //initial begin
    //    $readmemb("mach_code.txt", Core);
    //end

    // Combinational read logic
    always_comb begin
        data = Core[pc];
    end

endmodule
