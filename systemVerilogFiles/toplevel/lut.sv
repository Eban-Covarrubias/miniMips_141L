module lut(
    input logic [8:0] data,
    output logic [1:0] R1,
    output logic [1:0] R2,
    output logic [1:0] W,
    output logic write_en,
    output logic [7:0] imm,
    output logic [4:0] alu_op,
    output logic mem_write,
    output logic mem_read,
    output logic use_alu_bypass,
    output logic alu_src
);

// Define an enumeration for the opcodes
typedef enum logic [2:0] {
    Str_op = 3'b000,
    Ldr_op = 3'b001,
    Mov_op = 3'b010,
    Shift_op = 3'b011,
    Saddto_op = 3'b100,
    Jump_op = 3'b101,
    Xor_op = 3'b110,
    And_op = 3'b111
} opcode_t;

// Define an enumeration for the ALU operations
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
} alu_t;

typedef enum logic [3:0] {
    Ble  = 4'b0100,  // Branch if less than equal to (7 bits: 1010100)
    Blt  = 4'b0101,  // Branch if less than (7 bits: 1010101)
    Beq  = 4'b0110,  // Branch if equal (7 bits: 1010110)
    Bne  = 4'b0111,  // Branch if not equal (7 bits: 1010111)
    Bge  = 4'b1000,  // Branch if greater than or equal to (7 bits: 1011000)
    Bgt  = 4'b1010,  // Branch if greater than (7 bits: 1011010)
    Br    = 4'b1011,  // Forced branch (7 bits: 1011011)
    Bof  = 4'b1111,  // Branch if overflow (7 bits: 1011111)
    Add1 = 4'b1100,  // Add 1 (7 bits: 1011100)
    Add2 = 4'b1101,  // Add 2 (7 bits: 1011101)
    Sub1 = 4'b1110   // Subtract 1 (7 bits: 1011110)
} alu_op_t;



// Internal signals
logic [2:0] op;
logic [7:0] temp_data;
logic [4:0] alu_op_reg;

always_comb begin
    // Default values
    R1 = 2'b00;
    R2 = 2'b00;
    W = 2'b00;
    write_en = 0;
    imm = 8'b0;
    alu_op = 5'b0;
    mem_write = 0;
    mem_read = 0;
    use_alu_bypass = 0;
    alu_src = 0;
    temp_data = data[7:0];

    op = data[8:6];

    case (op)
        Str_op: begin
            R1 = data[3:2]; //This is going into ALU
            R2 = data[5:4]; //This is going into dataMem
            imm = {6'b000000, data[1:0]};//This is going into alu
            alu_op = Add_type;
            mem_write = 1;
            mem_read = 0;
            use_alu_bypass = 0;
            alu_src = 1;
        end
        Ldr_op: begin
            R1 = data[3:2];
            W = data[5:4];
            write_en = 1;
            imm = {6'b000000, data[1:0]};
            alu_op = Add_type;
            mem_write = 0;
            mem_read = 1;
            use_alu_bypass = 0;
            alu_src = 1;
        end
        Mov_op: begin
            W = data[5:4];
            write_en = 1;
            imm = {4'b0000, data[3:0]};
            alu_op = Mov_type;
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 1;
        end
        Shift_op: begin
            R1 = data[5:4]; // Both read and write register
            W = data[5:4];
            write_en = 1;
            if (data[3] == 1'b1) begin // If the most significant bit (sign bit) is 1, it's negative
                alu_op = Leftshift_type; // Perform a left shift for negative values
                imm = {4'b0000, ~data[3:0] + 1'b1}; // Convert to positive value (2's complement)
            end else begin
                alu_op = Rightshift_type; // Perform a right shift for positive values
                imm = data[3:0]; // Use the value directly as it's positive
            end
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 1; // Uses imm as the shift amount
        end
        Saddto_op: begin
            case (data[5:4])
                0: begin // Add operation
                    R1 = data[3:2];
                    R2 = data[1:0];
                    W = data[3:2];
                    write_en = 1;
                    alu_op = Add_type;
                end
                1: begin // Sub operation
                    R1 = data[3:2];
                    R2 = data[1:0];
                    W = data[3:2];
                    write_en = 1;
                    alu_op = Sub_type;
                end
                2: begin // Copy operation
                    R1 = data[3:2];
                    R2 = data[1:0];
                    W = data[3:2];
                    write_en = 1;
                    alu_op = Copy_type;
                end
                3: begin // Abs operation
                    R1 = data[3:2];
                    R2 = data[1:0];
                    // W1 = data[3:2];
                    W = data[1:0];
                    write_en = 1;
                    alu_op = Abs_type;
                end
                default: begin
                    // Default case for Saddto_op
                end
            endcase
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 0;
        end
        Jump_op: begin
            // Branch type
            if (data[5:4] == 0) begin
                // Comparison
                R1 = data[3:2];
                R2 = data[1:0];
                write_en = 0;
                imm = 0;
                alu_op = Cmp_type;
                mem_write = 0;
                mem_read = 0;
                use_alu_bypass = 1;
                alu_src = 0;
            end else begin
                // Branching or simple A
                //R1 = data[3:2];
                R2 = data[1:0];
                W = data[1:0];
                write_en = 0;
                imm = 0;
                //alu_op = B_type;
                mem_write = 0;
                mem_read = 0;
                use_alu_bypass = 1;
                alu_src = 0;
                case (data[5:2])
                    Ble: alu_op = Ble_type;
                    Blt: alu_op = Blt_type;
                    Beq: alu_op = Beq_type;
                    Bne: alu_op = Bne_type;
                    Bge: alu_op = Bge_type;
                    Bgt: alu_op = Bgt_type;
                    Br: alu_op = B_type;
                    Add1: begin
                        alu_op = Add1_type;
                        write_en = 1;
                    end
                    Add2: begin 
                        alu_op = Add2_type;
                        write_en = 1;
                    end
                    Sub1: begin 
                        alu_op = Sub1_type;
                        write_en = 1;
                    end
                    Bof: alu_op = Bof_type;
                    default: alu_op = B_type;
                endcase
            end
        end
        Xor_op: begin
            R1 = data[3:2];
            R2 = data[1:0];
            W = data[5:4];
            write_en = 1;
            alu_op = Xor_type;
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 0;
        end
        And_op: begin
            R1 = data[3:2];
            R2 = data[1:0];
            W = data[5:4];
            write_en = 1;
            alu_op = And_type;
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 0;
        end
        default: begin
            // Default case
        end
    endcase
end

endmodule
