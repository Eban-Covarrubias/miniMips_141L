module lut(
	input logic[8:0] data,
	output logic [1:0] AR1,
	output logic [1:0] AR2,
	output logic [1:0] AR3,
	output logic write_en,
	output logic [7:0] imm,
	output logic [2:0] alu_op,
	output logic mem_write,
	output logic mem_read,
	output logic use_alu_bypass,
	output logic alu_src,
	output logic car
);
//Remember that AR3 is the write_reg

 // Define an enumeration for the opcodes
 typedef enum logic [2:0] {
	  Str_op = 3'b000,
	  Ldr_op = 3'b001,
	  Mov_op = 3'b010,
	  Shift_op = 3'b011,
	  Saddto_op = 3'b100,
	  Blt_op = 3'b101,
	  Xor_op = 3'b110,
	  And_op = 3'b111
 } opcode_t;
 
 
 // Define an enumeration for the alu_op
 typedef enum logic [2:0] {
	  UnsignedAdd_type = 3'b000,
	  And_type = 3'b001,
	  Xor_type = 3'b010,
	  LeftShift_type = 3'b011,
	  RightShift_type = 3'b100,
	  SignedAdd_type = 3'b101,
	  LtFlag_type = 3'b110,
	  Set_type = 3'b111
 } opcode_y;

//internal wires
logic [2:0] op;
logic [3:0] temp_invert;

always_comb begin
	op = data[8:6];
	//default
	car = 0;
	temp_invert = 0;
	
	case(op)
		Str_op: begin
			//this is mem type
			AR1 = data[3:2];
			AR2 = 2'b00;//Not used
			AR3 = data[5:4];
			write_en = 0;
			imm = {6'b000000,data[1:0]};
			alu_op = UnsignedAdd_type; //we will be adding read d1 to the imm to compute addr
			mem_write = 1;
			mem_read = 0;
			use_alu_bypass = 0;
			alu_src = 1; //will be using imm value for offset
			
		end
		Ldr_op: begin
			AR1 = data[3:2];
			AR2 = 2'b00;//Not used
			AR3 = data[5:4];
			write_en = 0;
			imm = {6'b000000,data[1:0]};
			alu_op = UnsignedAdd_type; //we will be adding read d1 to the imm to compute addr
			mem_write = 0;
			mem_read = 1;
			use_alu_bypass = 0;
			alu_src = 1;
		
		end
		Blt_op: begin
			//branch type
			AR1 = data[3:2];
			AR2 = data[1:0];
			AR3 = data[5:4];
			write_en = 0;
			imm = 0;
			alu_op = LtFlag_type;
			mem_write = 0;
			mem_read = 0;
			use_alu_bypass = 0;
			alu_src = 0;
		end
		Xor_op: begin
			//R type
			AR1 = data[3:2];
			AR2 = data[1:0];
			AR3 = data[5:4];
			write_en = 1;
			imm = 0;
			alu_op = Xor_type;
			mem_write = 0;
			mem_read = 0;
			use_alu_bypass = 1;
			alu_src = 0;
		end
		And_op: begin
			//R type
			AR1 = data[3:2];
			AR2 = data[1:0];
			AR3 = data[5:4];
			write_en = 1;
			imm = 0;
			alu_op = And_type;
			mem_write = 0;
			mem_read = 0;
			use_alu_bypass = 1;
			alu_src = 0;
		end
		Mov_op: begin
			//data transfer type
			AR1 = 2'b00;
			AR2 = 2'b00;
			AR3 = data[5:4];
			write_en = 1;
			imm = {4'b0000, data[3:0]};
			alu_op = Set_type;
			mem_write = 0;
			mem_read = 0;
			use_alu_bypass = 1;
			alu_src = 1;
		end
		Shift_op: begin
			AR1 = 2'b00;
			AR2 = 2'b00;
			AR3 = data[5:4];
			write_en = 1;
			if(data[3]) begin
				//working with negative aka logic right shift
				temp_invert = ~(data[3:0]) + 1; //obtain absolute value for imm
				imm = {4'b0000, temp_invert};
				alu_op = RightShift_type;
			end
			else begin
				//working with positive, aka logical left shift
				imm = {4'b0000, data[3:0]};
				alu_op = LeftShift_type;
			end
			mem_write = 0;
			mem_read = 0;
			use_alu_bypass = 1;
			alu_src = 1;
			
		end
		Saddto_op: begin
			//Arithmetic type
			AR1 = data[3:2];
			AR2 = data[1:0];
			AR3 = data[3:2];
			write_en = 1;
			imm = 0;
			if(data[5]) begin
				//signed addition
				alu_op = UnsignedAdd_type;
			end
			else begin
				alu_op = SignedAdd_type;
			end
			mem_write = 0;
			mem_read = 0;
			use_alu_bypass = 1;
			alu_src = 0; //adding can only add 2 regs
			car = data[6];
		end
		
	endcase
	
end



endmodule