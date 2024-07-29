module tb_processor;

    // Clock and reset
    logic clk;
    logic reset;

    // Instantiate the processor
    processor uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test procedure
    initial begin
        // Reset the processor
        reset = 1;
        #10;
        reset = 0;

        // Load instructions into the instruction memory
        // Assuming instrMem has a way to be initialized via direct memory access in this testbench

        // Instructions to load
        // Example instructions in binary:
        // Instruction 1: 9'b000_000_001 (Opcode 000, src/dst 0, immediate 1)
        // Instruction 2: 9'b001_010_100 (Opcode 001, src 2, dst 4)
        // Instruction 3: 9'b010_111_011 (Opcode 010, src 7, dst 3)

        // Fill instruction memory with these example instructions
        uut.instrMem.mem_array[0] = 9'b000_000_001;
        uut.instrMem.mem_array[1] = 9'b001_010_100;
        uut.instrMem.mem_array[2] = 9'b010_111_011;
        uut.instrMem.mem_array[3] = 9'b011_101_110;

        // Step through the processor's execution cycles
        // Allow some cycles for instruction fetch, decode, execute, etc.
        #100;

        // Check the output or internal state of the processor for correctness
        // Example: Check values in the register file
        $display("Reg 0: %h", uut.regFile.reg_array[0]);
        $display("Reg 1: %h", uut.regFile.reg_array[1]);
        $display("Reg 2: %h", uut.regFile.reg_array[2]);
        $display("Reg 3: %h", uut.regFile.reg_array[3]);

        // Finish the simulation
        $finish;
    end

endmodule
