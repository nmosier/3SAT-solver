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
	
	// assign array_orig = {6'b100000, 6'b111000, 6'b000000, 6'b000110, 6'b000001};
	// assign array_inv = {6'b000000, 6'b000000, 6'b100100, 6'b000000, 6'b000100};
	assign array_orig = {6'b100000, 6'b111000, 6'b000000, 6'b000110, 6'b000001};
	assign array_inv = {6'b000000, 6'b000000, 6'b100100, 6'b000000, 6'b000100};
	
	reg [N-1:0] inputs;
	wire [M-1:0] clauses;
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
				assign array[i][1] = array_orig[i*N+N-1:i*N];
				assign array[i][0] = array_inv[i*N+N-1:i*N];
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
	wire [log2c(M)-1:0] clauses_mask_encoded;
	wire clauses_inv_rotated_p_none;
	wire clauses_ignore;
	assign clauses_inv = ~clauses;
	rotator #(M, 0) clauses_rleft (clauses_inv, rand_clause, clauses_inv_rotated);
	priority_circuit #(M) clauses_priority (clauses_inv_rotated, 
		clauses_inv_rotated_p, clauses_inv_rotated_p_none);
	rotator #(M, 1) clauses_rright (clauses_inv_rotated_p, rand_clause, clauses_mask);
	encoder #(M) clauses_encoder (clauses_mask, clauses_mask_encoded, clauses_ignore); // clauses ignore should always be 0
	
	// 2. Random input within clause
	//    (a) fetch randomly selected clause def C, C_inv
	//    (b) compute C xor C_inv
	//    (b) rotate result left by rand_inputs
	//    (c) take priority
	//    (d) rotate right by rand_inputs
	wire [N-1:0] clause_selected_def, clause_selected_def_inv,
				 flippable_inputs, flippable_inputs_rotated, flippable_inputs_priority, flip_mask;
	wire flippable_ignore;
	assign clause_selected_def = array[clauses_mask_encoded][1];
	assign clause_selected_def_inv = array[clauses_mask_encoded][0];
	assign flippable_inputs = clause_selected_def ^ clause_selected_def_inv;
	rotator #(N, 0) shift_flippable_rleft (flippable_inputs, rand_flip, flippable_inputs_rotated);
	priority_circuit #(N) flip_priority (flippable_inputs_rotated, flippable_inputs_priority, flippable_ignore);
	rotator #(N, 1) shift_flippable_rright (flippable_inputs_priority, rand_flip, flip_mask);
		
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
					//$display("input=%b\tc_mask=%b\tf_mask=%b\tflip_in=%b", inputs, clauses_mask, flip_mask, array[3'b011][1]);
					inputs = inputs ^ flip_mask;
					flip_counter = flip_counter - 1;
				end
		end
	end

endmodule

module schoening_test();

	reg clk, reset;
	wire done;
	wire [5:0] solution;
	
	schoening #(6, 5, 8) DUT (clk, reset, done, solution);
	
	initial begin
		clk = 0;
		reset = 1; #5;
		reset = 0; #5;
	end
	
	always begin
		clk = 1; #5;
		clk = 0; #5;
	end
	
	always @(done) begin
		if (done) begin
			$display("solution=%b", solution);
			$finish;
		end
	end

endmodule