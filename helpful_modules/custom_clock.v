module custom_clock
#(
	parameter FREQ   = 50_000_000, // Hz
	parameter PERIOD = 1           // sec
)
(
	input  wire clock       ,
	input  wire reset       ,

	output wire custom_clock
);

localparam MAX_COUNT = FREQ * PERIOD;
localparam COUNT_LEN = $clog2(MAX_COUNT);

reg [COUNT_LEN - 1:0] counter;

always @(posedge clock) begin
	if(~ reset)
		counter <= 'b0;

	else begin
		counter <= counter == MAX_COUNT - 1 ? 'b0 : counter + 'b1;
	end
end


assign custom_clock = counter == MAX_COUNT - 1 ? 1'b1 : 1'b0;


endmodule
