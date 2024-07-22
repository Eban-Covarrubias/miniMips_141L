module alu(
	input logic [7:0] DatA,
	input logic [7:0] DatB,
	input logic [2:0] Alu_op,
	input logic CarryIn,
	output logic [7:0] Rslt,
	output logic Lt_flag,
	output logic Overflow
);

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
 } opcode_t;

//internal wires
 logic signed [7:0] signed_A, signed_B; // Signed versions of inputs
 logic [8:0] temp_result;               // Temporary result storage
 logic signed [8:0] temp_signed_result; // Temporary signed result with extra bit for overflow
 
 
 
always_comb begin
	  // Default assignments
	  Rslt = 8'b0;
	  Overflow = 1'b0;
	  Lt_flag = 0;
	  temp_signed_result = 0;
	  temp_result = 0;

	  // Handle signed/unsigned operation
	  signed_A = DatA;
	  signed_B = DatB;
	
	case(Alu_op)
		3'b000: begin 
			temp_result = DatA + DatB + CarryIn;   // unsigned addition
			Rslt = temp_result[7:0];
			Overflow = temp_result[8];
		end
		3'b001: Rslt = DatA & DatB;   // bitwise AND
		3'b010: Rslt = DatA ^ DatB;   // bitwise XOR
		3'b011: begin
			Rslt = DatA << DatB;    // left shift
		end
		3'b100: begin
			Rslt = DatA >> DatB; 	//right shift
		end
		3'b101: begin
			temp_signed_result = signed_A + signed_B + CarryIn; // signed addition
			Rslt = temp_signed_result[7:0];
			Overflow = (DatA[7] == DatB[7]) && (Rslt[7] != DatA[7]);
		end
		3'b110: begin
			if(DatA < DatB) Lt_flag = 1;	//Branch if LT comparison flag set
		end
		3'b111: begin
			Rslt = DatB; //this is used for the mov operation
		end
	endcase
end
endmodule