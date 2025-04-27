module vga (
	input  wire        clock      ,
	input  wire        reset      ,

	input  wire [ 7:0] data       ,	

        output wire        hsync      ,
	output wire        vsync      ,
        output wire        blank_N    ,
        output wire        pixel_clk_N,

	output wire [11:0] addr       ,

	output wire [23:0] rgb
);
 
// Horizontal synchronization
localparam H_ACTIVE_VIDEO = 640;
localparam H_FRONT_PORCH  =  16;
localparam H_SYNC_PULSE   =  96;
localparam H_BACK_PORCH   =  48;
localparam H_BLANK_PIX    = H_FRONT_PORCH  + H_SYNC_PULSE + H_BACK_PORCH;
localparam H_TOTAL_PIX    = H_ACTIVE_VIDEO + H_BLANK_PIX                ;
 
// Vertical synchronization
localparam V_ACTIVE_VIDEO = 480;                            
localparam V_FRONT_PORCH  =  10;
localparam V_SYNC_PULSE   =   2;
localparam V_BACK_PORCH   =  33;
localparam V_BLANK_PIX    = V_FRONT_PORCH  + V_SYNC_PULSE + V_BACK_PORCH;
localparam V_TOTAL_PIX    = V_ACTIVE_VIDEO + V_BLANK_PIX                ;
 

wire [9:0] x_pos;
wire [9:0] y_pos;

assign x_pos = count_h >= H_BLANK_PIX ? count_h - H_BLANK_PIX : 640 - 1;
assign y_pos = count_v >= V_BLANK_PIX ? count_h - H_BLANK_PIX : 480 - 1;

freq_div2 pixel_clk_gen (
				.clk     (clock    ),
				.reset   (reset    ),
				.new_freq(pixel_clk)
);

rgb_gen rgb_gen (
			.clock(pixel_clk),
			.reset(reset    ),
			.data (data     ),
			.blank(blank_N  ),
			.x_pos(x_pos    ),
			.y_pos(y_pos    ),
			.addr (addr     ),
			.rgb  (rgb      )
);

// counters
reg [9:0] count_v;
reg [9:0] count_h;
 
assign pixel_clk_N = ~ pixel_clk;
assign blank_N = ~ ((count_v < V_BLANK_PIX) | (count_h < H_BLANK_PIX));
 
assign vsync =    (count_v >= V_FRONT_PORCH - 1) & (count_v <= V_FRONT_PORCH + V_SYNC_PULSE - 1);

assign hsync = ~ ((count_h >= H_FRONT_PORCH - 1) & (count_h <= H_FRONT_PORCH + H_SYNC_PULSE - 1));

always @(posedge pixel_clk) begin
	if( reset ) begin
		count_h <= 0;
		count_v <= 0;
	end

	else begin
		if (count_h < H_TOTAL_PIX)
        		count_h <= count_h + 1'b1;
		else begin
			count_h <= 0;
		
			if (count_v < V_TOTAL_PIX)
				count_v <= count_v + 1'b1;
			else
				count_v <= 0;
		end
	end
end
endmodule
