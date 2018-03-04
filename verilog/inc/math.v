// log2c(integer N): calculates ceiling of log_2(N)
function integer log2c;
	input integer N;
	begin
		for (log2c = 0; N > 1; log2c = log2c + 1)
			N = N - N/2;
	end
endfunction

// log2f(integer N): calculates floor of log_2(N)
function integer log2f;
	input integer N;
	begin
		for (log2f = 0; N > 1; log2f = log2f + 1)
			N = N/2;
	end
endfunction