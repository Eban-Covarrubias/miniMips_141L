# miniMips_141L
Version control for our programs and processor architecture files

In order to use our processor, use the sv files stored in systemVerilog files. These will include all the sv files needed for modules, and also has several test benches. 

When simulating a test bench, be sure to include the appropriate machine code txt files in your folder as well as the test txt files. These are required for the test benches to run properly.

All of our programs and features on the microprocessor are functional. All three programs pass all tests. 
The biggest challenges we faced when implementing our design were debugging our assembly files, and creating hardware that was able to recognize a set of instructions using a limit of 9 bits per instruction. We managed to overcome this with a carefully selected instruction set, and several reductions to our design, such as reduced number of registers and excluding operations that our programs didn't need.