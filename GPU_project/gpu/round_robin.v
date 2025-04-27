module round_robin (
	input wire clock,
	input wire reset,

	input wire        core_serv,
	input wire [15:0] core_val,

	output reg [ 3:0] core_cnt  // core counter counting from 0 to 15 in a circle skipping not active cores
);

wire [3:0] next_core_cnt [15:0];

// define next value of core_cnt
always @(posedge clock) begin
	if(reset)
		core_cnt <= 4'b0;
	else if(core_serv)
		core_cnt <= core_cnt;
	else if(core_cnt == 4'b1111)
		core_cnt <= 4'b0;
	else
		core_cnt <= next_core_cnt[0]; 
end

// next_core_cnt multiplexer
assign next_core_cnt[15] = 4'b1111;

genvar i;

generate
	for(i = 14; i >= 0; i = i - 1) begin: gen_next_core_mux

		assign next_core_cnt[i[3:0]] = ((core_cnt < i[3:0]) & (core_val[i[3:0]])) ? i[3:0] : next_core_cnt[i[3:0] + 1];

	end
endgenerate


endmodule