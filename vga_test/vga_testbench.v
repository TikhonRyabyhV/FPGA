`timescale 1ns/100ps

module vga_testbench ();

reg     clock;
initial clock = 1'b1;

always
	#1 clock = ~ clock;

reg  reset    ;
wire vga_clock;
wire blank    ;
wire vsync    ;

wire [23:0] rgb;

vga_test vga_test (
			.clk  (clock        ),
			.reset(reset        ),
			.hsync(             ),
			.vsync(vsync        ),
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

	#5000_000;

end

integer cnt_h = 0;
integer cnt_v = 0;

always @(posedge clock) begin
	if((~vga_clock) && blank && cnt_h < 640) begin
		$fwrite(out_dsp, "%d ", rgb);
		++cnt_h;
	end

	else begin
		if((~vga_clock) && cnt_h >= 640) begin
			$fwrite(out_dsp, "\n");
			cnt_h = 0;
			++cnt_v;
		end

		if((~vga_clock) && cnt_v >= 480) begin
			$fclose(out_dsp);

			$finish;
		end
	end
end



endmodule
