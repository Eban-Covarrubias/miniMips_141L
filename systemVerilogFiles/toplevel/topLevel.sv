module topLevel(
	input logic clk,
	input logic start,
	output logic done
);
	// Internal signals
    logic [7:0] pc;
	 logic [7:0] pc_next;
    logic [8:0] instruction;
    logic [1:0] read_reg1, read_reg2, read_reg3, write_reg1, write_reg2;
	 logic [7:0] read_data1, read_data2, read_data3;
	 logic write_en1, write_en2;
	 logic alu_src;
	 logic alu_bypass;
	 logic branch;
	 logic overflow_flag;
    logic [7:0] alu_result, memory_data, immediate_data, alu_input_b;
    logic [2:0] alu_op;
    logic mem_read, mem_write, c;
    logic [7:0] data_mem_out;
	 logic [7:0] jump_amount;
	 logic [15:0] write_data;
//    logic [8:0] instruction_memory [0:255]; // Instruction memory (ROM)
	 
	 
	 // Instantiate Register File
    regFile rf (
			.clk(clk),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
		  .read_reg3(read_reg3),
        .write_reg1(write_reg1),
		  .write_reg2(write_reg2),
		  .write_en1(write_en1),
		  .write_en2(write_en2),
		  .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2),
		  .read_data3(read_data3)
    );
	 
	 //instance of instr mem
	 instrMem instrMem1(
		.pc(pc),
		.data(instruction)
	 );
	 
	 //instance of adder
	 adder adr(
		.a(pc),
		.b(jump_amount),
		.sum(pc_next),
		.overflow(overflow)
	 );
	 
	 //instance of control block
	 lut controlBlock(
		.data(instruction),
		.AR1(read_reg1),
		.AR2(read_reg2),
		.AR3(write_reg),
		.write_en1(write_en1),
		.write_en2(write_en2),
		.imm(immediate_data),
		.alu_op(alu_op),
		.mem_write(mem_write),
		.mem_read(mem_read),
		.use_alu_bypass(alu_bypass),
		.alu_src(alu_src)
		);
	 //instance of alu
	 alu alu1(
	   .Clk(clk),
		.DatA(read_data1),
		.DatB(alu_input_b),
		.Alu_op(alu_op),
		.Rslt(alu_result),
		.branch(branch)
	 );
	 
	 //instance of data memory
	 dataMem dataMemory(
		.addr(alu_result),
		.write_data(read_data2),
		.mem_write(mem_write),
		.mem_read(mem_read),
		.data_out(data_mem_out)
	 );
	 
	 always_ff @(posedge clk) begin
		pc <= pc_next;
	 end
	 
	 //use this to create needed muxs
	 always_comb begin
		//alu src mux
		if(!alu_src) alu_input_b = read_data2;
		else alu_input_b = immediate_data;
		
		//regfile input mux
		if(alu_bypass) write_data = alu_result;
		else write_data = data_mem_out;
		
		//pc update amount mux
		if(!branch) jump_amount = 1;
		else jump_amount = read_data3;
	 end
	 

endmodule