module freq_div2 (
	input  wire clk    ,
	input  wire reset  ,

	output reg new_freq
);

reg counter;

always @(posedge clk) begin
	if(reset)
		counter <= 1'b0;

	else begin

		if(counter == 1'b1)
			counter <= 1'b0;

		else
			counter <= counter + 1'b1;
	end
end

always @(posedge clk) begin
	if(reset)
		new_freq <= 1'b0;

	else
		if(counter == 1'b1)
			new_freq <= ~ new_freq;
end

endmodule
