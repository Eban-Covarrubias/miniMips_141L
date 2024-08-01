module tb5_topLevel;
    // Declarations
    reg clk;
    reg start;
    wire done;
    
    // Internal signals for instruction memory and data memory
    reg [8:0] instruction_memory [0:255]; // Instruction memory (ROM)
    reg [8:0] data_memory [0:255];        // Data memory (RAM)
    
    // Instantiate the topLevel processor
    topLevel uut (
        .clk(clk),
        .start(start),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        start = 0;

        // Initialize instruction memory with some instructions
        // (You need to define the instructions according to your ISA)
        // Initialize instruction memory with some instructions from a file
        $readmemb("instructions.txt", uut.instrMem1.Core);

        // Transfer instruction memory to processor's instruction memory
        
        // Initialize data memory if needed
        // (You need to define the initial data values if required)
        // data_memory[0] = 9'h00;
        // data_memory[1] = 9'h01;
        // data_memory[2] = 9'h02;
        // data_memory[3] = 9'h03;

        // Start the processor
        #10 start = 1;
        #10 start = 0;

        // Wait for the processor to complete execution
        wait(done);

        // Check final results
        // (You need to check the values of registers or memory locations to verify correctness)
        $display("Test completed at time %t", $time);
        $stop;
    end
endmodule
