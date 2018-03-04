// this will be the top-level module for implementing Schoening's Algorithm
// for solving 3SAT using randomized local search

`include "src/pla.v"
`include "src/random.v"

module schoening #(parameter N=32, M=4, FLIPS=8) (input clk, reset,
				 output reg done,
				 output reg [N-1:0] solution);
	
	`include "inc/math.v"	// log2 function

	// I. pick random assignment
	// II. Loop A times
	// 		2. check if all clauses satisfied
	//    		(a) if all satisfied, skip to IV.
	//    		(b) otherwise, find one unsatisfied clause.
	// 		3. flip value of one variable in clause
	// III. Jump to I
	// IV. Done
	
	wire [N-1:0] array [M-1:0][1:0];
	wire [N-1:0] array_eval [M-1:0][1:0];
	wire [N*M-1:0] array_orig, array_inv;
	assign array_orig = {4'b1000, 4'b0100, 4'b0010, 4'b0001};
	assign array_inv = {4'b0100, 4'b0010, 4'b0001, 4'b1000};
	
	reg [N-1:0] inputs;
	wire [M-1:0] clauses;
	reg [N-1:0] flip_mask;	// need to come up with logic for this
	wire value;
	
	wire [31:0] rand;
	wire [N-1:0] rand_inputs;
	wire [log2(M)-1:0] rand_clause;
	wire [log2(N)-1:0] rand_flip;
	assign rand_inputs = rand[N-1:0];
	assign rand_clause = rand[log2(M)-1:0];
	assign rand_flip = rand[log2(M)+log2(N)-1:log2(M)];
	
	genvar i;
	generate
		for (i=0; i<M; i=i+1)
			begin
				assign array[i][1] = array_orig[i*N+M-1:i*N];
				assign array[i][0] = array_inv[i*N+M-1:i*N];
				assign array_eval[i][1] = array[i][1] & inputs;
				assign array_eval[i][0] = array[i][0] & ~inputs;
				assign clauses[i] = (|array_eval[i][1]) | (|array_eval[i][0]);
			end
	endgenerate
	
	reg [log2(FLIPS)-1:0] flip_counter;
	
	assign value = &clauses;
	
	random_sreg #(32) rand_gen (clk, reset, rand);
	
	// flip logic
	// 1. Random clause
	
			
	always @(reset) begin
		if (reset) begin
			done = 0;
			flip_counter = FLIPS;
			inputs = rand_inputs;
		end
	end
	
	always @(posedge clk) begin
		if (value) begin
			done = 1;
			solution = inputs;
		end
		else if (~done) begin
			if (flip_counter == 0)
				begin
					flip_counter = FLIPS;
					inputs = rand_inputs;
				end
			else
				begin
					inputs = inputs ^ flip_mask;
					flip_counter = flip_counter - 1;
				end
		end
	end

endmodule

module schoening_test();

	reg clk, reset;
	wire done;
	wire [3:0] solution;
	
	schoening #(4, 4, 8) DUT (clk, reset, done, solution);
	
	initial begin
		clk = 0;
		reset = 1; #5;
		reset = 0; #5;
	end
	
	always begin
		clk = 1; #5;
		clk = 0; #5;
		$display("input=%b", solution);
	end
	
	always @(done) begin
		if (done) begin
			$display("solution=%b", solution);
			$finish;
		end
	end

endmodule