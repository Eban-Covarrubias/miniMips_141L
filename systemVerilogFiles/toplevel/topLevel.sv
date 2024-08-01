module topLevel(
	input logic clk,
	input logic start,
	output logic done
);
	// Internal signals
    logic [9:0] pc;
	 logic [9:0] pc_next;
    logic [8:0] instruction;
    logic [1:0] read_reg1, read_reg2, write_reg;
	 logic [7:0] read_data1, read_data2, read_data3;
	 logic write_en1, write_en2;
	 logic alu_src;
	 logic alu_bypass;
	 logic branch;
	 logic overflow_flag;
    logic [7:0] memory_data, immediate_data, alu_input_b, alu_input_a;
    logic [4:0] alu_op;
    logic mem_read, mem_write, c;
    logic [7:0] data_mem_out;
	 logic [7:0] jump_amount;
	 logic [7:0] write_data, alu_result;
//    logic [8:0] instruction_memory [0:255]; // Instruction memory (ROM)
	 
	 
	 // Instantiate Register File
    regFile rf (
			.clk(clk),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
		  .write_reg(write_reg),
		  .write_en(write_en),
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
		.R1(read_reg1),
		.R2(read_reg2),
		.W(write_reg),
		.write_en(write_en),
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
		.DatA(alu_input_a),
		.DatB(alu_input_b),
		.Alu_op(alu_op),
		.Rslt(alu_result),
		.branch(branch)
	 );
	 
	 //instance of data memory
	 dataMem dataMemory(
		.clk(clk),
		.addr(alu_result),
		.write_data(read_data2),
		.mem_write(mem_write),
		.mem_read(mem_read),
		.data_out(data_mem_out)
	 );


	 always_ff @(posedge clk) begin
		if(start) pc = 0;
		else pc <= pc_next;
	 end
	 
	 //use this to create needed muxs
	 always_comb begin
		//default case
		alu_input_a = 0;
		alu_input_b = 0;
		write_data = 0;
		if(instruction == 9'b101100100) begin
			done = 1;
			jump_amount = 1;
		end
		else  begin 
			done = 0;
			//alu src mux
			if(!alu_src) alu_input_b = read_data2;
			else alu_input_b = immediate_data;
			
			alu_input_a = read_data1;

			//regfile input mux
			if(alu_bypass) write_data = alu_result;
			else write_data = data_mem_out;
			
			//pc update amount mux
			if(!branch) jump_amount = 1;
			else jump_amount = read_data3;
		end
	 end
	 

endmodule