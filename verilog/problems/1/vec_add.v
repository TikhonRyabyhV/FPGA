module vec_add 
#(
	parameter DATA_W = 10,
	parameter POS_W = $clog2(10) )
(
	input wire [DATA_W - 1:0]data,
	output wire [POS_W - 1:0]sum
);

	wire [DATA_W - 1:0][POS_W - 1:0] inter_res; // intermediate results

	assign inter_res[0] = data[0];

	genvar i;
	generate 
		for(i = 1; i < DATA_W; i = i + 1) begin: newgen
			assign inter_res[i] = inter_res[i - 1] + data[i];
		end
	endgenerate

	assign sum = inter_res[DATA_W - 1]; // result is in last wire

endmodule

