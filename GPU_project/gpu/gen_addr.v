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
		parameter V_RETRACE       =   2, // vertical retrace

		parameter H_END_AREA      = H_DISPLAY + H_L_BORDER,
		parameter V_END_AREA      = 448
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

		output reg  [11:0] addr     
	);
	
	localparam BAR__WIDTH    =  10 - 1;
	localparam BAR_HEIGHT    =   7 - 1;

	localparam END_V_DISPLAY = V_DISPLAY - 1; 
	
	
	reg [9:0] bar_scale_h;
	reg [9:0] bar_scale_v;

	reg [2:0] bar_count_h;
	
	wire bar_scale_v_pulse;
	wire bar_scale_h_pulse;

	wire bar_count_h_pulse;

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
			bar_count_h <= 0;
		end

		else begin
			if(y >= V_END_AREA) begin
				bar_count_h <= 0;
			end

			else begin
				bar_count_h <= ~vga_clock && bar_scale_h_pulse   ?
					(bar_count_h == 3 ? 0 : bar_count_h + 1) :
				 	bar_count_h;
			end
		end
	end

	always @(posedge clock) begin
		if(~ reset) begin
			bar_scale_h <= 0;
		end
				
		else begin
			if(y >= V_END_AREA) begin
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
	end
			
	always @(posedge clock) begin
		if(~ reset) begin
			bar_scale_v <= 0;
		end
				
		else begin
			if(y >= V_END_AREA) begin
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
	end
			
	assign bar_scale_h_pulse = (bar_scale_h == BAR__WIDTH)  ? 
				   1'b1 : 1'b0;

	assign bar_scale_v_pulse = (bar_scale_v == BAR_HEIGHT &&
		       		    y <= END_V_DISPLAY    &&	
			            hsync == 1 && hsync_r == 0) ?
			            1'b1 : 1'b0;
	
	assign bar_count_h_pulse = (bar_count_h == 3 && bar_scale_h == BAR__WIDTH) ?
				   1'b1 : 1'b0;

	assign reset_addr_pulse  = (y <= END_V_DISPLAY && hsync == 0 && hsync_r == 1) ? 1'b1 : 1'b0;

	always @(posedge clock) begin
		if(~ reset) begin
			addr <= 0;
		end

		else begin
			if(y < V_END_AREA) begin
				addr <= ~vga_clock ? 
					(bar_count_h_pulse ? addr + {3'b0  , 8'd64} : 
					(bar_scale_h_pulse ? addr + {3'b0  , 8'd64} :
				        (bar_scale_v_pulse ? addr + {3'b0  , 8'b01} :	
					addr ))) : addr;
			end

			else begin
				addr <= 0;
			end
		end
	end

endmodule

