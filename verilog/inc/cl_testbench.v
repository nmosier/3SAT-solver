// cl_dut: must be defined as (input[CL_IN_WIDTH], output[CL_OUT_WIDTH])
// must have defined CL_DUT, CL_IN_WIDTH, CL_OUT_WIDTH
module testbench();

   reg clk, reset;
   reg [`CL_IN_WIDTH-1:0] inputs;
   reg [`CL_OUT_WIDTH-1:0] yexpected;
   wire [`CL_OUT_WIDTH-1:0] y;
   reg [31:0] vectornum, errors;
   reg [(`CL_IN_WIDTH+`CL_OUT_WIDTH-1):0] testvectors [10000:0];

	`CL_DUT dut(inputs, y);

   // generate clock
   always
	   begin
		   clk = 1; #5; clk = 0; #5;
	   end

   // at start of test, load vectors
   // and pulse reset
   initial
	   begin
		   $readmemb(`CL_TV, testvectors);
		   vectornum = 0; errors = 0;
		   reset = 1; #27; reset = 0;
		   {inputs, yexpected} = testvectors[vectornum];
	   end

   // apply test vectors at rising edge of clock
   always @ (posedge clk)
	   begin
		   #1; {inputs, yexpected} = testvectors[vectornum];
	   end

   // check results at falling edge of clock
   always @ (negedge clk)
	   if (~reset) begin
		   if (y !== yexpected) begin
			   $display ("Error: inputs = %b", inputs);
			   $display (" outputs = %b (%b expected)", y, yexpected);
			   errors = errors + 1;
		   end
		
		   vectornum = vectornum + 1;
		   if (testvectors[vectornum] === {(`CL_IN_WIDTH+`CL_OUT_WIDTH){1'bx}}) begin
			   $display ("%d tests completed with %d errors", vectornum, errors);
			   $finish;
		   end
	   end

endmodule