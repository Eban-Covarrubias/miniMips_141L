module instrMem(
	input logic [7:0] pc,
	output logic [8:0] data
);

	logic[8:0] Core[256];
	
//	initial
//	$readmemb("mach_code.txt", Core);
	
	always_comb data = Core[pc];

endmodule