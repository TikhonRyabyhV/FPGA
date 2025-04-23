module vga_test
	(
		input wire clk, reset,
		
		output wire hsync, vsync,
		output wire blank,
		output wire vga_clock,
		output wire [23:0] rgb
	);

	localparam BAR__WIDTH    = 32  - 1;
	localparam BAR_HEIGHT    = 24  - 1 ;
	localparam END_V_DISPLAY = 480 - 1; 
	
	wire [9:0] x;
	wire [9:0] y;
	
	reg [9:0] bar_scale_h;
	reg [9:0] bar_scale_v;
	
	wire bar_scale_v_pulse;
	wire bar_scale_h_pulse;
	
	reg [23:0] rgb_reg;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

	reg hsync_r;

	always @(posedge clk) begin
		if(~ reset) begin
			hsync_r  <= 0;
		end

		else begin
			hsync_r  <= ~vga_clock ? hsync : hsync_r;
		end
	end

        // instantiate vga_sync
        vga_sync vga_sync_unit (.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
                             .video_on(video_on), .p_tick(vga_clock), .x(x), .y(y));
   
			always @(posedge clk) begin
				if(~ reset) begin
					bar_scale_h <= 0;
				end
				
				else begin
					bar_scale_h <=  ~vga_clock ? 
						       ((video_on) ?
						       (bar_scale_h < BAR__WIDTH ? bar_scale_h + 1 : 0) :
						       0) :
						       bar_scale_h;
				end
			end
			
			always @(posedge clk) begin
				if(~ reset) begin
					bar_scale_v <= 0;
				end
				
				else begin
					bar_scale_v <= ~vga_clock ?
						       ((y <= END_V_DISPLAY && hsync == 1 && hsync_r == 0) ?
						       (bar_scale_v < BAR_HEIGHT                 ? 
						       bar_scale_v + 1 : 0) : 
						       bar_scale_v        ) :
						       bar_scale_v;
				end
			end
			
		assign bar_scale_h_pulse = (bar_scale_h == BAR__WIDTH)  ? 
					   1'b1 : 1'b0;

		assign bar_scale_v_pulse = (bar_scale_v == BAR_HEIGHT &&
		       			   y <= END_V_DISPLAY    &&	
					   hsync == 1 && hsync_r == 0) ?
					   1'b1 : 1'b0;
			
        // rgb buffer
        always @(posedge clk) begin
				if (~ reset) begin
					rgb_reg <= 0;
				end
			
				else begin
					rgb_reg <= ~vga_clock ?  
						(bar_scale_h_pulse || bar_scale_v_pulse ? ~rgb_reg : rgb_reg) :
					       	rgb_reg;
				end
        end

        // output
        assign rgb   = (video_on) ? rgb_reg : 24'b0;
		  
	assign blank = video_on;
		  
endmodule
