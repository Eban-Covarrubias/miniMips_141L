module adder(
input logic [9:0] a,
input logic [7:0] b,
output logic [9:0] sum,
output logic overflow
);
logic [10:0] temp_sum;

always_comb begin
    if(b[7]) temp_sum = a+{2'b11, b};
    else temp_sum = a+{2'b00, b};
    overflow = temp_sum[10];
    sum = temp_sum[9:0];
end

endmodule
