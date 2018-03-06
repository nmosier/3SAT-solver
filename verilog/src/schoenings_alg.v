// this will be the top-level module for implementing Schoening's Algorithm
// for solving 3SAT using randomized local search

`include "src/pla.v"
`include "src/random.v"
`include "src/rotator.v"
`include "src/priority.v"
`include "src/encoder.v"

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
	//wire [N-1:0] array_orig[M-1:0], array_inv[M-1:0];
	assign array_orig = {4'b1000, 4'b1000, 4'b0010, 4'b0001};	// the Mth N-bit constant specifies which inputs considered in Mth clause
	assign array_inv = {4'b0000, 4'b0000, 4'b0000, 4'b0000};	// the Mth N-bit constant specifies which inverted inputs considered in Mth clause
	
	reg [N-1:0] inputs;
	wire [M-1:0] clauses;
	reg [N-1:0] flip_mask;	// need to come up with logic for this
	wire value;
	
	wire [31:0] rand;
	wire [N-1:0] rand_inputs;
	wire [log2c(M)-1:0] rand_clause;
	wire [log2c(N)-1:0] rand_flip;
	assign rand_inputs = rand[N-1:0];
	assign rand_clause = rand[log2c(M)-1:0];
	assign rand_flip = rand[log2c(M)+log2c(N)-1:log2c(M)];
	
	// logic for evaluating clauses
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
	
	
	reg [log2f(FLIPS):0] flip_counter;
	
	assign value = &clauses;
	
	random_sreg #(32) rand_gen (clk, reset, rand);
	
	// flip logic
	// 1. Random clause
	//    (a) invert clauses
	// 	  (b) rotate left by rand_clause
	//    (c) take priority bit
	//    (d) rotate right by rand_clause
	wire [M-1:0] clauses_reg, clauses_inv, clauses_inv_rotated, clauses_inv_rotated_p, clauses_mask;
	wire clauses_inv_rotated_p_none;
	assign clauses_inv = ~clauses;
	rotator #(M, 0) clauses_rleft (clauses_inv, rand_clause, clauses_inv_rotated);
	priority_circuit #(M) clauses_priority (clauses_inv_rotated, 
		clauses_inv_rotated_p, clauses_inv_rotated_p_none);
	rotator #(M, 1) clauses_rright (clauses_inv_rotated_p, rand_clause, clauses_mask);
	
	// 2. Random input within clause
	//     (don't encode random clause--unnecessary extra hardware)
	//    (a) AND 
			
	always @(reset) begin
		if (reset) begin
			done = 0;
			flip_counter = 1;
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
					// flip logic
					// 1. Random clause
					//    (a) invert clauses
					// 	  (b) rotate left by rand_clause
					//    (c) take priority bit
					//    (d) rotate right by rand_clause
					// 2. Random clause member
					//	  (a) encode clause
					//    (b) lookup corresponding clause
					//    (b) rotate left by rand_flip
					//inputs = inputs ^ flip_mask;
					//$display("clauses_mask=%b", clauses_mask);
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