module tb3_topLevel;
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
        // uut.instrMem1.Core[0] = 9'b010000010; // mov r0 0010
        // uut.instrMem1.Core[1] = 9'b011000001; // shift r0 0001 == shift to right 1 = r0 = 0001
        // uut.instrMem1.Core[2] = 9'b010010001; // mov r1 1
        // uut.instrMem1.Core[3] = 9'b011011111; // shift r0 1111 == shift left 1 = r1 = 0010 
        uut.instrMem1.Core[0] = 9'b010100000; // mov r2 0
        uut.instrMem1.Core[1] = 9'b000101000; // str r2 r2 00 == store r0 value into memory location that is stored in r2 **doesnt call opcode in alu
        uut.instrMem1.Core[2] = 9'b001111000; // ldr r3 r2 00 == loads the r2 memory location and puts the value into r3 **doesnt call opcode in alu
        uut.instrMem1.Core[3] = 9'b010000000; // mov r0 0000
        uut.instrMem1.Core[4] = 9'b101110000; // add1 r0 == 0001 **opcode gets recognized but datA does not get increamented
        uut.instrMem1.Core[5] = 9'b101110100; // add2 r0 == 0011 **opcode is correct but datA doesnt get increamented by 2
        
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
