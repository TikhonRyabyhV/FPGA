module double_dabble 
#(
	parameter BIN_LEN = 8    ,
	parameter BCD_LEN = 3 * 4
)	
(
	input  wire [BIN_LEN - 1 : 0] bin,

	output wire [BCD_LEN - 1 : 0] bcd
);

wire [BCD_LEN + BIN_LEN - 1 : 0] tmp_bcd_with_bin [BIN_LEN - 1 : 0];

assign tmp_bcd_with_bin [0] = { { BCD_LEN {1'b0} }, bin } << 1;

genvar i;

generate
	for (i = 1; i < BIN_LEN; i = i + 1) begin: iter_gen
		dd_iter dd_iter_i (
					.bcd_with_bin_prev(tmp_bcd_with_bin [i - 1]),
					.bcd_with_bin_next(tmp_bcd_with_bin [i    ])		
	
		);

	end
endgenerate


assign bcd = tmp_bcd_with_bin [BIN_LEN - 1] [BCD_LEN + BIN_LEN - 1 : BIN_LEN];

endmodule

