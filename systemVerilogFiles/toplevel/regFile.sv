module regFile(
    input logic clk,
    input logic [1:0] read_reg1,     // 1st read register number
    input logic [1:0] read_reg2,     // 2nd read register number
    input logic [1:0] write_reg1,    // 1st write register number
    input logic [1:0] write_reg2,    // 2nd write register number
    input logic [15:0] write_data,   // 16-bit data to be written
    input logic write_en1,           // Write enable for write register1
    input logic write_en2,           // Write enable for write register2
    output logic [7:0] read_data1,   // Data from 1st read register
    output logic [7:0] read_data2,   // Data from 2nd read register
    output logic [7:0] read_data3    // Data from 3rd read register
);

    // Define the register file storage
    logic [7:0] reg_array [3:0]; // Only 4 registers, 8 bits wide

    // Read operations
    always_comb begin
        read_data1 = reg_array[read_reg1];
        read_data2 = reg_array[read_reg2];
        read_data3 = reg_array[read_reg2];
    end

    // Write operations
    always_ff @(negedge clk) begin
			if (write_en1) begin
				 reg_array[write_reg1] <= write_data[15:8]; // MSB to write_reg1
			end
			if (write_en2) begin
				 reg_array[write_reg2] <= write_data[7:0];  // LSB to write_reg2
			end
    end

endmodule
