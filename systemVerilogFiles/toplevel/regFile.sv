module regFile(
		input logic clk,
	  input logic [1:0] read_reg1,
	  input logic [1:0] read_reg2,
	  input logic [1:0] write_reg,
	  input logic write_en,
	  input logic [7:0] write_data,
	  output logic [7:0] read_data1,
	  output logic [7:0] read_data2,
	  output logic [7:0] read_data3
);
//fill in guts
	logic [7:0] regfile [3:0];

    // Write operation
    always_ff @(posedge clk) begin
        if (write_en) begin
            regfile[write_reg] <= write_data;
        end
    end

    // Read operations
    assign read_data1 = regfile[read_reg1];
    assign read_data2 = regfile[read_reg2];
    assign read_data3 = regfile[write_reg];



endmodule