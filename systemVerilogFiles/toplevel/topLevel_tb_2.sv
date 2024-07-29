module tb2_topLevel;
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
        uut.instrMem1.Core[0] = 9'b010000101; // mov r0 0101
        uut.instrMem1.Core[1] = 9'b010010001; // mov r1 0001
        uut.instrMem1.Core[2] = 9'b100010001; // sub r0 r1 == r0 = 0100
        uut.instrMem1.Core[3] = 9'b100100100; // copy r1 r0 == r1 = 0100
        uut.instrMem1.Core[4] = 9'b100110100; // abs r1 r0 == r1 = 0100 && r0 = 0100 **died did not work
        uut.instrMem1.Core[5] = 9'b010100000; // mov r2 0000
        uut.instrMem1.Core[6] = 9'b101111010; // sub1 r2 == r2 = 1111 **does not create -1, the values within r2 stay 0
        uut.instrMem1.Core[7] = 9'b010110000; // mov r3 0000
        uut.instrMem1.Core[8] = 9'b101111011; // sub1 r3 == r3 = 1111 **same thing as the previous sub1
        uut.instrMem1.Core[9] = 9'b100111011; // abs r2 r3 == r2 = 0000_0000 && r3 = 0000_0001 **abs does not work

        
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
