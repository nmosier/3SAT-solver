// PLA module for 3SAT Project
// 2-level logic: OR logic array followed by AND logic array

// PLA
// Parameters:
// -n: number of input variables
// -m: number of clauses


module PLA #(parameter N=3, M=4) (input [N-1:0] inputs,
								  output out);
	wire [M-1:0] clauses;
	
	AND_array #(N, M) and_array (inputs, clauses);
	OR_array #(M) or_array (clauses, out);
	

endmodule

module AND_array #(parameter N=3, M=4) (input [N-1:0] inputs,
									    output [M-1:0] clauses);
	
	wire [N-1:0] array_orig[M-1:0];
	wire [N-1:0] array_inv[M-1:0];
	
	// generate static AND arrays
	genvar n, m;
	generate
		for (m = 0; m < M; m = m + 1) begin
			assign array_orig[m] = inputs | ({{(N-1){1'b1}}, 1'b0} << m);
			assign array_inv[m] = {(N){1'b1}};
		end
		
		for (m = 0; m < M; m = m + 1) begin
			assign clauses[m] = (&array_orig[m]) & (&array_inv[m]);
		end
	endgenerate
	

endmodule


module OR_array #(parameter M=4) (input [M-1:0] clauses,
								   output val);
								   
		assign val = |clauses;
								   
endmodule



module test();
	
	reg [9:0] inputs;
	wire out;
	PLA #(10, 10) dut (inputs, out);
	
	initial begin
		inputs = 10'b01;
		#10;
		$display("Output: %b", out);
	end
	
endmodule