module gen_addr
	// main VGA parameters
	#(
		parameter H_DISPLAY       = 640, // horizontal display area
		parameter H_L_BORDER      =  48, // horizontal left border
		parameter H_R_BORDER      =  16, // horizontal right border
		parameter H_RETRACE       =  96, // horizontal retrace

	
		parameter V_DISPLAY       = 480, // vertical display area
		parameter V_T_BORDER      =  10, // vertical top border
		parameter V_B_BORDER      =  33, // vertical bottom border
		parameter V_RETRACE       =   2  // vertical retrace
	)
	(
		input  wire        clock    , 
		input  wire        reset    ,

		input  wire        hsync    ,
		input  wire        vsync    ,

		input  wire        video_on ,
		input  wire        vga_clock,

		input  wire [ 9:0] x        ,
		input  wire [ 9:0] y        ,

		output reg  [ 3:0] addr     
	);
	
	localparam BAR__WIDTH    = 160 - 1;
	localparam BAR_HEIGHT    = 120 - 1;
	localparam END_V_DISPLAY = 480 - 1; 
	
	
	reg [9:0] bar_scale_h;
	reg [9:0] bar_scale_v;
	
	wire bar_scale_v_pulse;
	wire bar_scale_h_pulse;

	wire reset_addr_pulse;

	reg hsync_r;

	always @(posedge clock) begin
		if(~ reset) begin
			hsync_r  <= 0;
		end

		else begin
			hsync_r  <= ~vga_clock ? hsync : hsync_r;
		end
	end

	always @(posedge clock) begin
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
			
	always @(posedge clock) begin
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

	assign reset_addr_pulse  = (y <= END_V_DISPLAY && hsync == 0 && hsync_r == 1) ? 1'b1 : 1'b0;

	always @(posedge clock) begin
		if(~ reset) begin
			addr <= 0;
		end

		else begin
			addr <= ~vga_clock ? 
				(bar_scale_h_pulse ? (video_on ? addr + 1 : addr) : 
				(bar_scale_v_pulse ? addr + 4 : 
				(reset_addr_pulse  ? addr - 4 : addr) ) ) : addr;
		end
	end

endmodule
