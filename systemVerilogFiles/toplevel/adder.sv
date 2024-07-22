module adder(
input logic [7:0] a,
input logic [7:0] b,
output logic [7:0] sum,
output logic overflow
);
logic [8:0] temp_sum;

always_comb begin
temp_sum = a+b;
overflow = temp_sum[8];
sum = temp_sum[7:0];
end

endmodule
