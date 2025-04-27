module vga
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

		input  wire [ 7:0] data     ,
		
		output wire        hsync    , 
		output wire        vsync    ,
		output wire        blank    ,
		output wire        vga_clock,

		output wire [11:0] addr     ,
		output wire [23:0] rgb
	);
	
	
	wire [9:0] x;
	wire [9:0] y;

	wire hsync_in;
	wire vsync_in;
	
	wire video_on_in ;
	wire vga_clock_in;
	
	wire [1:0] hsync_out;
	wire [1:0] vsync_out;
	
	wire [1:0] video_on_out ;
	wire [1:0] vga_clock_out;
	
	reg [23:0] rgb_reg;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

        // instantiate vga_sync
        vga_sync #(
		.H_DISPLAY (H_DISPLAY ),
		.H_L_BORDER(H_L_BORDER),
		.H_R_BORDER(H_R_BORDER),
		.H_RETRACE (H_RETRACE ),

		.V_DISPLAY (V_DISPLAY ),
		.V_T_BORDER(V_T_BORDER),
		.V_B_BORDER(V_B_BORDER),
		.V_RETRACE (V_RETRACE )
	) 
	vga_sync_unit (
			.clock   (clock       ),
		       	.reset   (reset       ),
		       	.hsync   (hsync_in    ),
		       	.vsync   (vsync_in    ),
                        .video_on(video_on_in ),
		       	.p_tick  (vga_clock_in),
		       	.x       (x           ),
		       	.y       (y           )
	);

	assign hsync_out = {2 {hsync_in}};
	assign vsync_out = {2 {vsync_in}};
	
	assign video_on_out  = {2 {video_on_in }};
	assign vga_clock_out = {2 {vga_clock_in}};

        gen_addr #(
		.H_DISPLAY (H_DISPLAY ),
		.H_L_BORDER(H_L_BORDER),
		.H_R_BORDER(H_R_BORDER),
		.H_RETRACE (H_RETRACE ),

		.V_DISPLAY (V_DISPLAY ),
		.V_T_BORDER(V_T_BORDER),
		.V_B_BORDER(V_B_BORDER),
		.V_RETRACE (V_RETRACE ),

		.H_END_AREA(H_END_AREA),
		.V_END_AREA(V_END_AREA)
	) 
	gen_addr_unit (
		.clock    (clock       ),
		.reset    (reset       ),

		.hsync    (hsync_out[0]),
		.vsync    (vsync_out[0]),

		.video_on (video_on_out [0]),
		.vga_clock(vga_clock_out[0]),

		.x        (x        ),
		.y        (y        ),

		.addr     (addr     )
	);
   
	
        // rgb buffer
        always @(posedge clock) begin
		if (~ reset) begin
			rgb_reg <= 0;
		end
			
		else begin
			rgb_reg <= ~vga_clock                        ? 
				   (x < H_END_AREA && y < V_END_AREA ? 
				   {3 {data}} :
				    3'b0)     :
				    rgb_reg;
		end
        end

        // output
        assign rgb   = (video_on) ? rgb_reg : 24'b0;
		  
	assign blank = video_on;

	assign hsync = hsync_out[1];
	assign vsync = vsync_out[1];

	assign video_on  = video_on_out [1];
	assign vga_clock = vga_clock_out[1];
		  
endmodule


