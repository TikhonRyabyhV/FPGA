module dd_iter 
#(
	parameter BIN_LEN = 8    ,
	parameter BCD_LEN = 3 * 4
)
(
	input  wire [BCD_LEN + BIN_LEN - 1 : 0] bcd_with_bin_prev,

	output wire [BCD_LEN + BIN_LEN - 1 : 0] bcd_with_bin_next

);

wire [BCD_LEN + BIN_LEN - 1 : 0] tmp_bcd_with_bin_next;

assign tmp_bcd_with_bin_next [BIN_LEN - 1 : 0] = bcd_with_bin_prev [BIN_LEN - 1 : 0];

genvar j;

generate
	for (j = 0; j < BCD_LEN / 4; j = j + 1) begin: digits_gen
		assign tmp_bcd_with_bin_next [BIN_LEN + 4 * j + 3 : BIN_LEN + 4 * j] = 
		           bcd_with_bin_prev [BIN_LEN + 4 * j + 3 : BIN_LEN + 4 * j] > 4'd4 ? 
			   bcd_with_bin_prev [BIN_LEN + 4 * j + 3 : BIN_LEN + 4 * j] + 4'd3 : 
			   bcd_with_bin_prev [BIN_LEN + 4 * j + 3 : BIN_LEN + 4 * j]        ;
	end
endgenerate


assign bcd_with_bin_next = tmp_bcd_with_bin_next << 1;

endmodule
