// pseudorandom generator
// implemented using shift register
// see http://www.cs.miami.edu/home/burt/learning/Csc609.022/random_numbers.html theory behind it

// first implement with 33 bits, (32 to out)
// apply XOR computation to bits 12, 11 for cycle of length 8,589,934,591
module random_sreg #(parameter WIDTH = 32) (input clk, reset,
					output [WIDTH-1:0] out);

	reg [32:0] seed;
	
	assign out = seed[WIDTH-1:0];
	
	always @(*) begin
		if (reset)
			seed = 33'b1101110111011101110111011101110111011101;
	end
	
	always @(posedge clk) begin
		seed = seed << 1;
		seed[0] = seed[13] ^ seed[12];
	end

endmodule


module random_sreg_test();
	
	reg clk, reset;
	wire [31:0] n;
	random_sreg dut (clk, reset, n);
	
	integer i = 1000;
	initial begin
		clk = 0;
		reset = 1; #5;
		reset = 0; #5;
	end
	
	always begin
		clk = 1; #5;
		clk = 0; #5;
		$display("%d", n);
		i = i - 1;
		if (i <= 0)
			$finish;
	end
	
endmodule