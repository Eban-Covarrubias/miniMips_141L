module alu(
    input logic Clk,
    input logic [7:0] DatA,
    input logic [7:0] DatB,
    input logic [4:0] Alu_op,
    output logic [7:0] Rslt,
    output logic branch
);

// Define an enumeration for the ALU operations
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
    Bof_type         = 5'b10100,  // Branch on overflow
    Add_no_of        = 5'b10101 //normal add, doesnt have overflow
} opcode_t;

logic less_than_flag_reg, equal_flag_reg, greater_than_flag_reg, overflow_flag_reg;

logic [7:0] Rslt_prev;
logic [8:0] Overflow_detect;

assign branch = (Alu_op == Ble_type && (less_than_flag_reg || equal_flag_reg)) ||
                (Alu_op == Blt_type && less_than_flag_reg) ||
                (Alu_op == Beq_type && equal_flag_reg) ||
                (Alu_op == Bne_type && !equal_flag_reg) ||
                (Alu_op == Bge_type && (greater_than_flag_reg || equal_flag_reg)) ||
                (Alu_op == Bgt_type && greater_than_flag_reg) ||
                (Alu_op == B_type) ||
                (Alu_op == Bof_type && overflow_flag_reg);

always_comb begin
    case (Alu_op)
        Add_no_of: begin
            Rslt = DatA + DatB;
        end
        Add_type: begin
            Rslt = DatA + DatB;
        end
        Sub_type: begin
            Rslt = DatA - DatB;
        end
        Abs_type: begin
            logic signed [15:0] signed_val;
            logic [15:0] negated_val;
            signed_val = {DatA, DatB}; // Concatenate DatA (MSB) and DatB (LSB)
            if (signed_val < 0) begin
                negated_val = ~signed_val + 1;
                Rslt = negated_val[7:0];
            end
            else begin
                Rslt = signed_val[7:0];
            end
        end
        Copy_type: begin
            if(DatA[7]) Rslt = ~DatA + overflow_flag_reg;
            else Rslt = DatA;
            
        end
        Add1_type: begin
            Rslt = DatB + 8'b00000001;
        end
        Add2_type: begin
            Rslt = DatB + 8'b00000010;
        end
        Sub1_type: begin
            Rslt = DatB - 8'b00000001;
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
            Rslt = 8'b0; // Compare does not produce a result
        end
        default: begin
            Rslt = 8'b0; // Default case for undefined operations
        end
    endcase
end

always_ff @(negedge Clk) begin
    case (Alu_op)
        Add_type: begin
            Overflow_detect = DatA + DatB;
            overflow_flag_reg <= Overflow_detect[8];
        end
        Add1_type: begin
            Overflow_detect = 1 + DatB;
            overflow_flag_reg  <= Overflow_detect[8];
        end
        Add2_type: begin
            Overflow_detect = 2 + DatB;
            overflow_flag_reg  <= Overflow_detect[8];
        end
        Sub_type: begin
            Rslt_prev = DatA - DatB;
            overflow_flag_reg <= (DatA[7] != DatB[7]) && (Rslt_prev[7] != DatA[7]);
        end
        Sub1_type: begin
            Rslt_prev = DatB - 1;
            overflow_flag_reg <= (DatA[7] != DatB[7]) && (Rslt_prev[7] != DatA[7]);
        end
        Abs_type: begin
            // Overflow check specifically for abs_type
            overflow_flag_reg <= (DatA[7])&(DatB == 0);
        end
        Cmp_type: begin
            less_than_flag_reg <= (DatA < DatB);
            equal_flag_reg <= (DatA == DatB);
            greater_than_flag_reg <= (DatA > DatB);
        end
        // No flag updates for other operations
    endcase
end

endmodule
