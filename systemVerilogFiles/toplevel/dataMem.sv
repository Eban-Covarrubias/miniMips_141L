module dataMem(
    input logic clk,
    input logic [7:0] addr,
    input logic [7:0] write_data,
    input logic mem_write,
    input logic mem_read,
    output logic [7:0] data_out
);

// Memory array
logic [7:0] Core[255:0];

// Register to hold the read data
logic [7:0] read_data;

// Write logic - synchronous on clock edge
always_ff @(posedge clk) begin
    if (mem_write) begin
        Core[addr] <= write_data;
    end
end

// Read logic - combinational
always_comb begin
    if (mem_read) begin
        read_data = Core[addr];
    end else begin
        read_data = 8'b0; // Output zero when not reading
    end
end

// Assign read data to output
assign data_out = read_data;

endmodule
