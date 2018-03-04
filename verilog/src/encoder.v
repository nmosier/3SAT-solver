// encoder
// assumes input contains a single 1, otherwise all 0's

module encoder #(parameter N=8) (input [N-1:0] in,
								 output [log2c(N)-1:0] out,
								 output none);
	
	`include "inc/math.v"
	
	localparam N_h = N-2**log2c(N-N/2);
	localparam N_l = 2**log2c(N-N/2);
	
	/*
	initial begin
		if (N > 2)
			$display ("N=%d, N_h=%d, N_l=%d", N, N_h, N_l);
	end
	*/
	
	generate
		if (N==1)
			begin
				assign out = 1'b0;
				assign none = ~in;
			end
		else if (N==2)
			begin
				assign out = in[1];
				assign none = ~|in;
			end
		else
			begin
				// divide N inputs as follows:
				//	high: N-log2(N/2**2)
				//  low: log2(N/2)**2 (smallest power of 2 greater than or equal to N/2)
				// (reason: when combining outputs of high/low encoders, can use OR gate, not adder)
				
				wire [N_h-1:0] in_h;
				wire [N_l-1:0] in_l;
				wire [log2c(N_h)-1:0] out_h;
				wire [log2c(N_l)-1:0] out_l;
				wire none_h, none_l;
				
				assign in_h = in[N-1:N_l];
				assign in_l = in[N_l-1:0];
				
				encoder #(N_h) encoder_h (in_h, out_h, none_h);
				encoder #(N_l) encoder_l (in_l, out_l, none_l);
				
				wire [log2c(N)-1:0] out_h_offset;
				assign out_h_offset[log2c(N)-1] = 1'b1;
				assign out_h_offset[log2c(N)-2:0] = 0;
				
				wire [log2c(N)-1:0] out_h_ext, out_l_ext;
				
				assign out_h_ext[log2c(N)-1] = 1'b1;
				if (log2c(N) - log2c(N_h) > 1)
					assign out_h_ext[log2c(N)-2:log2c(N_h)] = 0;
				if (log2c(N_h) > 0)
					assign out_h_ext[log2c(N_h)-1:0] = out_h;
				
				assign out_l_ext[log2c(N)-1:log2c(N_l)] = 0;
				assign out_l_ext[log2c(N_l)-1:0] = out_l;
				
				assign out = none_h? out_l_ext : out_h_ext;
				assign none = none_h & none_l;
			end
	
	endgenerate

endmodule

module encoder_wrapper #(parameter N=7) (input [N-1:0] in,
										 output [log2c(N):0] out);
										 
	`include "inc/math.v"

	
	encoder #(N) dut (in, out[log2c(N):1], out[0]);

endmodule