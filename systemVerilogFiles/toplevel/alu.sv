module alu(
    input logic Clk,
    input logic reset,
    input logic [7:0] DatA,
    input logic [7:0] DatB,
    input logic [4:0] Alu_op,
    output logic [15:0] Rslt,
    output logic branch
);

// Define an enumeration for the alu_op
typedef enum logic [4:0] {
    Add_type         = 5'b00000, // Addition
    Sub_type         = 5'b00001, // Subtraction
    Abs_type         = 5'b00010, // Absolute value
    Copy_type        = 5'b00011, // Copy value
    Add1_type        = 5'b00100, // Add 1
    Add2_type        = 5'b00101, // Add 2
    Sub1_type        = 5'b00110, // Subtract 1
    Mov_type         = 5'b00111, // Move value
    And_type         = 5'b01000, // Logical AND
    Xor_type         = 5'b01001, // Logical XOR
    Leftshift_type   = 5'b01010, // Logical left shift
    Rightshift_type  = 5'b01011, // Logical right shift
    Cmp_type         = 5'b01100, // Compare
    Ble_type         = 5'b01101, // Branch if less or equal
    Blt_type         = 5'b01110, // Branch if less than
    Beq_type         = 5'b01111, // Branch if equal
    Bne_type         = 5'b10000, // Branch if not equal
    Bge_type         = 5'b10001, // Branch if greater or equal
    Bgt_type         = 5'b10010, // Branch if greater than
    B_type           = 5'b10011, // Branch
    Bof_type         = 5'b10100  // Branch on overflow
} opcode_t;

// Internal registers to hold flags
logic less_than_flag_reg;
logic equal_flag_reg;
logic greater_than_flag_reg;
logic overflow_flag_reg;

// Assign internal flags to outputs
assign branch = (Alu_op == Ble_type && (less_than_flag_reg || equal_flag_reg)) ||
                (Alu_op == Blt_type && less_than_flag_reg) ||
                (Alu_op == Beq_type && equal_flag_reg) ||
                (Alu_op == Bne_type && !equal_flag_reg) ||
                (Alu_op == Bge_type && (greater_than_flag_reg || equal_flag_reg)) ||
                (Alu_op == Bgt_type && greater_than_flag_reg) ||
                (Alu_op == B_type) ||
                (Alu_op == Bof_type && overflow_flag_reg);

always_ff @(posedge Clk or posedge reset) begin
    if (reset) begin
        less_than_flag_reg <= 1'b0;
        equal_flag_reg <= 1'b0;
        greater_than_flag_reg <= 1'b0;
        overflow_flag_reg <= 1'b0;
    end else begin
        case (Alu_op)
            Add_type: begin
                Rslt = DatA + DatB;
                overflow_flag_reg <= (DatA[7] == DatB[7]) && (Rslt[7] != DatA[7]);
            end
            Sub_type: begin
                Rslt = DatA - DatB;
                overflow_flag_reg <= (DatA[7] != DatB[7]) && (Rslt[7] != DatA[7]);
            end
            Abs_type: begin
					 // Combine DatA and DatB to form a 16-bit signed number
					 logic signed [15:0] signed_val;
					 signed_val = {DatA, DatB}; // Concatenate DatA (MSB) and DatB (LSB)

					 // Compute the absolute value
					 Rslt = (signed_val < 0) ? -signed_val : signed_val;
				end
            Copy_type: begin
                Rslt = DatB;
            end
            Add1_type: begin
                Rslt = DatA + 8'b00000001;
            end
            Add2_type: begin
                Rslt = DatA + 8'b00000010;
            end
            Sub1_type: begin
                Rslt = DatA - 8'b00000001;
            end
            Mov_type: begin
                Rslt = DatB;
            end
            And_type: begin
                Rslt = DatA & DatB;
            end
            Xor_type: begin
                Rslt = DatA ^ DatB;
            end
            Leftshift_type: begin
                Rslt = DatA << DatB;
            end
            Rightshift_type: begin
                Rslt = DatA >> DatB;
            end
            Cmp_type: begin
                Rslt = 16'b0; // CMP doesn't produce a result
                less_than_flag_reg <= (DatA < DatB);
                equal_flag_reg <= (DatA == DatB);
                greater_than_flag_reg <= (DatA > DatB);
            end
            Ble_type: begin
                Rslt = 16'b0; // Branch instructions typically don't produce a result
                less_than_flag_reg <= (DatA <= DatB);
            end
            Blt_type: begin
                Rslt = 16'b0;
                less_than_flag_reg <= (DatA < DatB);
            end
            Beq_type: begin
                Rslt = 16'b0;
                equal_flag_reg <= (DatA == DatB);
            end
            Bne_type: begin
                Rslt = 16'b0;
                equal_flag_reg <= (DatA != DatB);
            end
            Bge_type: begin
                Rslt = 16'b0;
                greater_than_flag_reg <= (DatA >= DatB);
            end
            Bgt_type: begin
                Rslt = 16'b0;
                greater_than_flag_reg <= (DatA > DatB);
            end
            B_type: begin
                Rslt = 16'b0;
                // Unconditional branch, flags might not be set
            end
            Bof_type: begin
                Rslt = 16'b0;
                // Handle overflow condition if necessary
            end
            default: begin
                Rslt = 16'b0;
            end
        endcase
    end
end

endmodule

