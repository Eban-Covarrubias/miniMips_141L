module lut(
    input logic [8:0] data,
    output logic [1:0] AR1,
    output logic [1:0] AR2,
    output logic [1:0] AR3,
    output logic write_en1,
    output logic write_en2,
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

typedef enum logic [3:0] {
    Ble = 4'b0100,
    Blt = 4'b0101,
    Beq = 4'b0110,
    Bne = 4'b0111,
    Bge = 4'b1000,
    Bgt = 4'b1010,
    Br  = 4'b1011,
    Add1 = 4'b1100,
    Add2 = 4'b1101,
    Sub1 = 4'b1110,
    Bof = 4'b1111
} opcode_branch_or_simA;

typedef enum logic [1:0] {
    Cmp = 2'b00
} opcode_cmp;

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
} opcode_y;

// Internal wires
logic [2:0] op;
logic [3:0] temp_invert;
logic [3:0] b_or_simA;
logic [1:0] math_sel;

always_comb begin
    op = data[8:6];
    // Default values
    math_sel = 0;
    AR1 = 2'b00;
    AR2 = 2'b00;
    AR3 = 2'b00;
    write_en1 = 0;
    write_en2 = 0;
    imm = 8'b0;
    alu_op = Add_type;
    mem_write = 0;
    mem_read = 0;
    use_alu_bypass = 0;
    alu_src = 0;
    temp_invert = 4'b0;
    b_or_simA = 4'b0;

    case(op)
        Str_op: begin
            AR1 = data[3:2];
            AR2 = 2'b00; // Not used
            AR3 = data[5:4];
            write_en1 = 0;
            write_en2 = 0;
            imm = {6'b000000, data[1:0]};
            alu_op = Add_type; // Adding read d1 to the imm to compute addr
            mem_write = 1;
            mem_read = 0;
            use_alu_bypass = 0;
            alu_src = 1; // Using imm value for offset
        end
        Ldr_op: begin
            AR1 = data[3:2];
            AR2 = 2'b00; // Not used
            AR3 = data[5:4];
            write_en1 = 1; // Load operation writes to register
            write_en2 = 0;
            imm = {6'b000000, data[1:0]};
            alu_op = Add_type; // Adding read d1 to the imm to compute addr
            mem_write = 0;
            mem_read = 1;
            use_alu_bypass = 0;
            alu_src = 1;
        end
        Mov_op: begin
            AR1 = 2'b00;
            AR2 = 2'b00;
            AR3 = data[5:4];
            write_en1 = 1;
            write_en2 = 0;
            imm = {4'b0000, data[3:0]};
            alu_op = Mov_type;
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 1;
        end
        Shift_op: begin
            AR1 = 2'b00;
            AR2 = 2'b00;
            AR3 = data[5:4];
            write_en1 = 1;
            write_en2 = 0;
            if(data[3]) begin
                // Working with negative aka logical right shift
                temp_invert = ~(data[3:0]) + 1; // Obtain absolute value for imm
                imm = {4'b0000, temp_invert};
                alu_op = Rightshift_type;
            end else begin
                // Working with positive, aka logical left shift
                imm = {4'b0000, data[3:0]};
                alu_op = Leftshift_type;
            end
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 1;
        end
        Saddto_op: begin
            math_sel = data[5:4];
            AR1 = data[3:2];
            AR2 = data[1:0];
            write_en1 = 1;
            write_en2 = 0;
            imm = 0;
            case(math_sel)
                0: alu_op = Add_type;
                1: alu_op = Sub_type;
                2: alu_op = Abs_type;
                3: alu_op = Copy_type;
            endcase
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 0; // Adding can only add 2 regs
        end
        Jump_op: begin
            // Branch type
            if(data[5:4] == Cmp) begin
                // Comparison
                AR1 = data[3:2];
                AR2 = data[1:0];
                AR3 = 2'b00;
                write_en1 = 0;
                write_en2 = 0;
                imm = 0;
                alu_op = Cmp_type;
                mem_write = 0;
                mem_read = 0;
                use_alu_bypass = 1;
                alu_src = 0;
            end else begin
                // Branching or simple A
                b_or_simA = data[5:2];
                AR1 = data[3:2];
                AR2 = data[1:0];
                AR3 = 2'b00;
                write_en1 = 0;
                write_en2 = 0;
                imm = 0;
                alu_op = B_type;
                mem_write = 0;
                mem_read = 0;
                use_alu_bypass = 1;
                alu_src = 0;
                case(b_or_simA)
                    Ble: alu_op = Ble_type;
                    Blt: alu_op = Blt_type;
                    Beq: alu_op = Beq_type;
                    Bne: alu_op = Bne_type;
                    Bge: alu_op = Bge_type;
                    Bgt: alu_op = Bgt_type;
                    Br: alu_op = B_type;
                    Add1: alu_op = Add1_type;
                    Add2: alu_op = Add2_type;
                    Sub1: alu_op = Sub1_type;
                    Bof: alu_op = Bof_type;
                    default: alu_op = B_type;
                endcase
            end
        end
        Xor_op: begin
            AR1 = data[3:2];
            AR2 = data[1:0];
            AR3 = 2'b00;
            write_en1 = 1;
            write_en2 = 0;
            imm = 0;
            alu_op = Xor_type;
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 0;
        end
        And_op: begin
            AR1 = data[3:2];
            AR2 = data[1:0];
            AR3 = 2'b00;
            write_en1 = 1;
            write_en2 = 0;
            imm = 0;
            alu_op = And_type;
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 1;
            alu_src = 0;
        end
        default: begin
            AR1 = 2'b00;
            AR2 = 2'b00;
            AR3 = 2'b00;
            write_en1 = 0;
            write_en2 = 0;
            imm = 0;
            alu_op = Add_type;
            mem_write = 0;
            mem_read = 0;
            use_alu_bypass = 0;
            alu_src = 0;
        end
    endcase
end

endmodule
