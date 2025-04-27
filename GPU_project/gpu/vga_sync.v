module vga_sync
	// VGA parameters
	#(
		parameter H_DISPLAY       = 640, // horizontal display area
		parameter H_L_BORDER      =  48, // horizontal left border
		parameter H_R_BORDER      =  16, // horizontal right border
		parameter H_RETRACE       =  96, // horizontal retrace

	
		parameter V_DISPLAY       = 480, // vertical display area
		parameter V_T_BORDER      =  10, // vertical top border
		parameter V_B_BORDER      =  33, // vertical bottom border
		parameter V_RETRACE       =   2 // vertical retrace
	)
	(
		input  wire clock     , 
		input  wire reset   ,
		
		output wire hsync   ,
		output wire vsync   ,
		
		output wire video_on,	
		output wire p_tick  ,
		
		output wire [9:0] x ,
		output wire [9:0] y 
	);
	
	// other VGA parameters
	localparam H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_RETRACE = H_DISPLAY + H_L_BORDER + H_R_BORDER;
	localparam END_H_RETRACE   = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_BLANK   = H_L_BORDER;
	localparam END_H_BLANK     = H_L_BORDER + H_DISPLAY - 1;

	
	localparam V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
	localparam START_V_RETRACE = V_DISPLAY + V_B_BORDER;
	localparam END_V_RETRACE   = V_DISPLAY + V_B_BORDER + V_RETRACE - 1;
	localparam START_V_BLANK   = 0;
	localparam END_V_BLANK     = V_DISPLAY - 1;
	
	reg vga_clock;
	
	always @(posedge clock) begin
		if(~ reset) begin
			vga_clock <= 1;
		end
		
		else begin
			vga_clock <= ~vga_clock;
		end
	end
	
	// registers to keep track of current pixel location
	reg [9:0] h_count_reg ;
	
	reg [9:0] v_count_reg ;
	
	// register to keep track of vsync and hsync signal states
	reg vsync_reg, hsync_reg;
 
	// infer registers
	always @(posedge clock) begin
		if(~ reset) begin
			h_count_reg <= 0;
			v_count_reg <= 0;
			
			hsync_reg   <= 0;
			vsync_reg   <= 0;
		end
		
		else begin
			h_count_reg <= ~vga_clock ?
			               (h_count_reg == H_MAX ? 0 : h_count_reg + 1)
				       : h_count_reg;

			v_count_reg <= ~vga_clock && h_count_reg == H_MAX ? 
				       (v_count_reg == V_MAX ? 0 : v_count_reg + 1)
				       : v_count_reg;
			
			hsync_reg   <= ~vga_clock ? 
				       (h_count_reg >= START_H_RETRACE && h_count_reg <= END_H_RETRACE) :
				       hsync_reg;

			vsync_reg   <= ~vga_clock ? 
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
        assign p_tick = vga_clock;
endmodule

