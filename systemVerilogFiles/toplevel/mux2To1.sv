module mux2To1(
	input logic s,
	input logic [7:0] a,
	input logic [7:0] b,
	output logic [7:0] out
);

always_comb begin
	if(!s) out = a;
	else out = b;
end
endmodule