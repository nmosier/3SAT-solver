
// shift register: used for storing clause data

module shiftreg #(parameter N = 8)
				(input clk, reset, load, sin,
				output reg [N-1:0] q,
				output sout);
		
		assign sout = q[0];
		
		always @ (posedge clk or posedge reset)
			if (reset)
				q <= 0;
			else if (load)
				q <= {sin, q[N-1:1]};
				
endmodule

module shiftreg_wrapper (input [3:0] in,
						output [8:0] out);

	shiftreg #(8) dut (in[3], in[2], in[1], in[0], out[8:1], out[0]);

endmodule

/*
`define CL_DUT shiftreg_wrapper
`define CL_TV "tst/shiftreg.tv"
`define CL_IN_WIDTH 4
`define CL_OUT_WIDTH 9

`include "inc/cl_testbench.v"
*/