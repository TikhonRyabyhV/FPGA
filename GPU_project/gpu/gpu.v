`define FPGA_MODE

module gpu(


    `ifdef FPGA_MODE
    // sram for prog_loading
    input  wire [15: 0]data_input, // ASSIGN SRAM DQ_[15: 0]
    output wire [19: 0]input_addr, // ASSIGN SRAM_ADDR_[9: 0]
    
    output wire mem_oen, // ASSIGN SRAM_OE_N
    output wire mem_wen, // ASSIGN SRAM_WE_N
    output wire mem_cen, // ASSIGN SRAM_CE_N
    output wire mem_lbn, // ASSIGN SRAM_LB_N
    output wire mem_ubn, // ASSIGN SRAM_UB_N
    // ????
    output wire mem_cke, // ASSIGN DRAM_CKE
    
    `endif   //using sram


    `ifdef FPGA_MODE

    output wire        hsync , // ASSIGN VGA_HS
    output wire        vsync , // ASSIGN VGA_VS
    output wire        blank , // ASSIGN VGA_BLANK_N
    output wire        pixel_clk, // ASSIGN VGA_CLK
    output wire [7:0]  red      , // ASSIGN VGA_R_[7:0]
    output wire [7:0]  green    , // ASSIGN VGA_G_[7:0]
    output wire [7:0]  blue     , // ASSIGN VGA_B_[7:0]

    `endif

	input wire clk,  // ASSIGN CLOCK_50
 	input wire KEY0 // ASSIGN KEY_0

	//input  wire [1024  - 1: 0][15: 0] data_frames_in //// sdram
);
    wire [15 : 0] core_ready;
    wire [15 : 0] read;
    wire [15 : 0] write;
    wire [15 : 0] finish;
    wire [15 : 0] finish_array [15 : 0];

    wire [191:0] addr_in;
    wire [127:0] data_in;
    wire [127:0] data_out_to_core;

    wire [127:0] data_out_fr_bank [15:0];
    wire [127:0] data_out_res     [15:0];



    wire [15:0] gpu_core_reading;
    wire        final_core_reading;
    wire [15:0]       instruction;
    wire [ 3:0] masks;

    wire         r0_loading;
    wire  core_mask_loading;
    wire    r0_mask_loading;
    wire val_ins;
    
    wire  reset;

    `ifdef FPGA_MODE
    
    wire [ 11:0] addr_vga;
    wire [127:0] data_vga;

    wire [ 7:0] data_vga_mux [15:0];

    genvar j;

    assign data_vga_mux[0] = {8 {(addr_vga[11:8] == 8'b0)}} & data_vga[7:0];

    generate
	    for (j = 1; j < 16; j = j + 1) begin: data_vga_mux_gen
		    assign data_vga_mux[j] = ({8 {(addr_vga[11:8] == j)}} & data_vga[7 + 8 * j : 8 * j]) | data_vga_mux[j -1];
	    end
    endgenerate 

    `endif


    assign mem_oen = 1;
    assign mem_wen = 0;
    assign mem_cen = 1; /// ??????
    assign mem_lbn = 1;
    assign mem_ubn = 0;

    button 
    rst_but
           (
               .clk(clk),
               .KEY(KEY0),
               .skey(reset)
           );



assign finish = finish_array[ 0] |  
                finish_array[ 1] |  
                finish_array[ 2] | 
                finish_array[ 3] | 
                finish_array[ 4] | 
                finish_array[ 5] | 
                finish_array[ 6] | 
                finish_array[ 7] |
                finish_array[ 8] |  
                finish_array[ 9] |  
                finish_array[10] | 
                finish_array[11] | 
                finish_array[12] | 
                finish_array[13] | 
                finish_array[14] | 
                finish_array[15] ; 

genvar i;

assign data_out_res[0] = data_out_fr_bank[0];

generate
        for(i = 1; i < 16; i = i + 1) begin: gen_data_out_res
                assign data_out_res[i[3:0]] = data_out_res[i[3:0] - 1] | data_out_fr_bank[i[3:0]];
        end
endgenerate

assign data_out_to_core = data_out_res[15];


generate
	for(i = 0; i < 16; i = i + 1) begin: gen_cores
		gpu_core_1 gpu_core_i ( 
					.clk                (clk                                     ), 
					.reset              (reset                                   ), 
			      	.val_ins            (val_ins                                 ),
				    .val_mask_R0        (r0_mask_loading                         ),
					.val_mask_ac        (core_mask_loading                       ),   
				    .val_R0             (r0_loading                              ), 
				    .val_data           (finish[i]                               ), 
					.instruction        (instruction                             ),
				    .addr_shared_memory (addr_in[11 + 12 * i[3:0] : 12 * i[3:0]] ), 
					.mem_dat            (data_out_to_core[7 + 8 * i[3:0] : 8 *  i[3:0]]),  
                    .mem_dat_st         (data_in[7 + 8 * i : 8 * i]              ),
					.core_id            (i[3:0]                                  ),
				    .rtr                (gpu_core_reading[i[3:0]]                ),
				    .mem_req_ld         (read[i[3:0]]                            ), 
					.mem_req_st         (write[i[3:0]]                           ),
				    .ready              (core_ready[i[3:0]]                      )
		);
	end
endgenerate

generate
	for(i = 0; i < 16; i = i + 1) begin: gen_bank_arbiters
		bank_arbiter arbiter_i (
					.clock(clk                           ),
					.reset(reset                         ),
					.read(read                           ),
				    .write(write                         ),
                    .bank_n(i[3:0]                       ),
				    .addr_in(addr_in                     ),
					.data_in(data_in                     ),

					`ifdef FPGA_MODE
					.addr_vga(addr_vga[7:0]                        ),
					.data_vga(data_vga[7 + 8 * i[3:0] : 8 * i[3:0]]),
					`endif

                     .data_out(data_out_fr_bank[i]   ),
				     .finish(finish_array[i]             )
        	);

	end
endgenerate


`ifdef FPGA_MODE

vga vga (
		.clock      (clk               ),
		.reset      (reset             ),
		.data       (data_vga_mux[15]  ),
		.hsync      (hsync             ),
		.vsync      (vsync             ),
		.blank      (blank             ),
		.vga_clock  (pixel_clk         ),
		.addr       (addr_vga          ),
		.rgb        ({red, green, blue})


);

`endif


/*
new_ts gpu_scheduler 
                    ( .clk              (clk              ), 
                      .reset            (reset            ),
                      .instr_loading    (val_ins          ),
                      .r0_mask_loading  (r0_mask_loading  ),
                      .core_mask_loading(core_mask_loading),
                      .r0_loading       (r0_loading       ),
                      .core_reading     (gpu_core_reading ), 
                      .data_input       (data_input       ),
                      .input_addr       (input_addr       ),
                      .core_ready       (core_ready       ),
                      .mess_to_core     (instruction      )
                    );
*/

scheduler gpu_scheduler 
                    ( .clk              (clk              ), 
                      .reset            (reset            ),
                      .instr_loading    (val_ins          ),
                      .r0_mask_loading  (r0_mask_loading  ),
                      .core_mask_loading(core_mask_loading),
                      .r0_loading       (r0_loading       ),
                      .core_reading     (gpu_core_reading ), 
                      .core_ready       (core_ready       ),
                      .mess_to_core     (instruction      )
                    );
endmodule
