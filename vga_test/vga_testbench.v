`timescale 1ns/100ps

module vga_testbench ();

reg     clock;
initial clock = 1'b1;

always
	#1 clock = ~ clock;

reg  reset    ;
wire vga_clock;
wire blank    ;

wire [23:0] rgb;

vga_test vga_test (
			.clk  (clock        ),
			.reset(reset        ),
			.hsync(             ),
			.vsync(             ),
			.blank(blank        ),
			.vga_clock(vga_clock),
			.rgb      (rgb      )
);

integer out_dsp;

reg [8 * 9 : 1] output_file;

initial begin

	$dumpfile("dump.vcd"); $dumpvars();

	output_file = {"frame.txt"}      ;
	out_dsp     = $fopen(output_file);

	    reset = 1'b0;
	#1; reset = 1'b1;

	#840_000;
	$fclose(out_dsp);

	$finish;

end

integer cnt = 3;

always @(posedge vga_clock) begin
	if(blank) begin
		$fwrite(out_dsp, "%d ", rgb);
		cnt = 0;
	end

	else begin
		if(cnt < 3) begin
			$fwrite(out_dsp, "\n");
			++cnt;
		end
	end
end



endmodule
