// log2(integer N): calculates CEILING of log_2(N)
function integer log2;
	input integer N;
	begin
		for (log2 = 0; N > 1; log2 = log2 + 1)
			N = N - N/2;
	end
endfunction