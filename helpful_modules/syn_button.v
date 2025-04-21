module syn_button (
	input  wire clock,
	input  wire reset,

	input  wire button,

	output wire pressing
);

reg  syn_button;
reg  syn_button_prev;

always @(posedge clock) begin
	syn_button      <= reset ? button     : 1'b0;  
end

always @(posedge clock) begin
	syn_button_prev <= reset ? syn_button : 1'b0;
end

assign pressing = (~ syn_button) & syn_button_prev;

endmodule
