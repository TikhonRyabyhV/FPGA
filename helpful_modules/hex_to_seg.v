module hex_to_seg (
	input  wire [3:0] hex,
	
	output wire [6:0] s_seg
);

wire [127:0] seg_mask        ;
wire [  7:0] s_seg_tmp [15:0];

assign seg_mask = {~ 8'b0_0111111,
		   ~ 8'b0_0000110,
		   ~ 8'b0_1011011,
		   ~ 8'b0_1001111,	
		   ~ 8'b0_1100110,	
		   ~ 8'b0_1101101,	
		   ~ 8'b0_1111101,	
		   ~ 8'b0_0000111,	
		   ~ 8'b0_1111111,	
		   ~ 8'b0_1101111,	
		   ~ 8'b0_1110111,	
		   ~ 8'b0_1111100,	
		   ~ 8'b0_0111001,	
		   ~ 8'b0_1011110,	
		   ~ 8'b0_1111001,
		   ~ 8'b0_1110001};

assign s_seg_tmp [0] = {8 {(hex == 4'b0)}} & seg_mask [127:120];

genvar i;

generate
	for (i = 1; i < 16; i = i + 1) begin: parall_mux_gen
		assign s_seg_tmp [i] = ( {8 {(hex == i[3:0])}} & seg_mask[127 - i * 8 : 120 - i * 8] ) | s_seg_tmp [i - 1];

	end
endgenerate

assign s_seg = s_seg_tmp [15] [6:0];

endmodule


