module vga_sync

	(
		input  wire clk     , 
		input  wire reset   ,
		
		output wire hsync   ,
		output wire vsync   ,
		
		output wire video_on,	
		output wire p_tick  ,
		
		output wire [9:0] x ,
		output wire [9:0] y 
	);
	
	// constant declarations for VGA sync parameters
	localparam H_DISPLAY       = 640; // horizontal display area
	localparam H_L_BORDER      =  48; // horizontal left border
	localparam H_R_BORDER      =  16; // horizontal right border
	localparam H_RETRACE       =  96; // horizontal retrace
	localparam H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_RETRACE = H_DISPLAY + H_L_BORDER + H_R_BORDER;
	localparam END_H_RETRACE   = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_BLANK   = H_L_BORDER;
	localparam END_H_BLANK     = H_L_BORDER + H_DISPLAY - 1;

	
	localparam V_DISPLAY       = 480; // vertical display area
	localparam V_T_BORDER      =  10; // vertical top border
	localparam V_B_BORDER      =  33; // vertical bottom border
	localparam V_RETRACE       =   2; // vertical retrace
	localparam V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
	localparam START_V_RETRACE = V_DISPLAY + V_B_BORDER;
	localparam END_V_RETRACE   = V_DISPLAY + V_B_BORDER + V_RETRACE - 1;
	localparam START_V_BLANK   = 0;
	localparam END_V_BLANK     = V_DISPLAY - 1;
	
	// mod-2 counter to generate 25 MHz pixel tick
	reg pixel_reg;
	wire pixel_next, pixel_tick;
	
	always @(posedge clk) begin
		if(~ reset) begin
			pixel_reg <= 0;
		end
		
		else begin
			pixel_reg <= pixel_next;
		end
	end
	
	assign pixel_next = ~pixel_reg; // next state is complement of current
	
	assign pixel_tick = (pixel_reg == 0); // assert tick half of the time
	
	// registers to keep track of current pixel location
	reg [9:0] h_count_reg ;
	
	reg [9:0] v_count_reg ;
	
	// register to keep track of vsync and hsync signal states
	reg vsync_reg, hsync_reg;
 
	// infer registers
	always @(posedge clk) begin
		if(~ reset) begin
			h_count_reg <= 0;
			v_count_reg <= 0;
			
			hsync_reg   <= 0;
			vsync_reg   <= 0;
		end
		
		else begin
			h_count_reg <= ~pixel_tick ?
			               (h_count_reg == H_MAX ? 0 : h_count_reg + 1)
				       : h_count_reg;

			v_count_reg <= ~pixel_tick && h_count_reg == H_MAX ? 
				       (v_count_reg == V_MAX ? 0 : v_count_reg + 1)
				       : v_count_reg;
			
			hsync_reg   <= ~pixel_tick ? 
				       (h_count_reg >= START_H_RETRACE && h_count_reg <= END_H_RETRACE) :
				       hsync_reg;

			vsync_reg   <= ~pixel_tick ? 
				       (v_count_reg >= START_V_RETRACE && v_count_reg <= END_V_RETRACE) :
				       vsync_reg;
		end
	end

        // video only on when pixels are in both horizontal and vertical display region
        assign video_on = (h_count_reg >= START_H_BLANK && h_count_reg <= END_H_BLANK) &&
                          (v_count_reg >= START_V_BLANK && v_count_reg <= END_V_BLANK)   ;

        // output signals
        assign hsync  = hsync_reg;
        assign vsync  = vsync_reg;
        assign x      = h_count_reg;
        assign y      = v_count_reg;
        assign p_tick = pixel_tick;
endmodule
