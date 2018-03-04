
// rotator module: rotates input to the left or right
//	-parameters:
//		N: # of bits in input
//		DIR = 0: rotate left; DIR = 1: rotate right
//  -inputs:
//		[N-1:0] in: input to rotate
//		[log2(N)-1:0] rot: # of positions to rotate
//	-outputs:
//		[N-1:0] out: rotated output
module rotator #(parameter N = 8, DIR = 0) (input [N-1:0] in,
											input [log2c(N)-1:0] rot,
											output [N-1:0] out);
	`include "inc/math.v"
	
	wire [N-1:0] in_int[log2c(N):0];
	assign in_int[log2c(N)] = in;
	assign out = in_int[0];
	
	genvar rot_bit;
	generate
		for (rot_bit=log2c(N)-1; rot_bit >= 0; rot_bit=rot_bit-1)
			begin
				if (DIR==0)
					assign {in_int[rot_bit][N-1:2**rot_bit], in_int[rot_bit][2**rot_bit-1:0]} = 
						rot[rot_bit]? 
							{in_int[rot_bit+1][N-2**rot_bit-1:0], in_int[rot_bit+1][N-1:N-2**rot_bit]} 
							: 
							in_int[rot_bit+1];
				else
					assign {in_int[rot_bit][N-1:N-2**rot_bit], in_int[rot_bit][N-2**rot_bit-1:0]} = 
						rot[rot_bit]? 
							{in_int[rot_bit+1][2**rot_bit-1:0], in_int[rot_bit+1][N-1:2**rot_bit]} 
							: 
							in_int[rot_bit+1];
			end
	endgenerate
	
						
endmodule

module rotator_wrapper #(parameter N=6, DIR=1) (input[N+log2c(N)-1:0] in,
												output [N-1:0] out);
	`include "inc/math.v"
	rotator #(N, DIR) wrapped (in[N+log2c(N)-1:log2c(N)], in[log2c(N)-1:0], out);
	
endmodule