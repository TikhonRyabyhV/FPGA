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

reg  [7:0] mem [15:0];
reg  [7:0] data      ;
wire [3:0] addr      ;

vga_from_mem vga_test (
			.clock(clock        ),
			.reset(reset        ),
			.data (data         ),
			.hsync(             ),
			.vsync(vsync        ),
			.blank(blank        ),
			.vga_clock(vga_clock),
			.addr     (addr     ),
			.rgb      (rgb      )
);

integer out_dsp;

reg [8 * 14 : 1] output_file;

integer i;

initial begin

	$dumpfile("dump.vcd"); $dumpvars();

	mem[0] = 8'b0;
	for(i = 1; i < 16; ++i) begin
		mem[i] = mem[i - 1] + 16;
	end

	output_file = {"frame.txt"}      ;
	out_dsp     = $fopen(output_file);

	    reset = 1'b0;
	#1; reset = 1'b1;

	#10_000_000;

end

always @(posedge clock) begin
	if(~ reset) begin
		data <= 0;
	end

	else begin
		data <= mem[addr];
	end
end

integer cnt_h = 0;
integer cnt_v = 0;

integer frame_num = 0;

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
			++frame_num;

			if(frame_num >= 2) begin
				$finish;
			end

			else begin
				output_file = {"frame_next.txt"} ;
				out_dsp     = $fopen(output_file);

				cnt_h = 0;
				cnt_v = 0;
			end
		end
	end
end



endmodule
