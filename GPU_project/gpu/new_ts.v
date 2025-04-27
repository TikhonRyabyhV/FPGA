`include "sched_def.v"

module new_ts
#(
    parameter     DATA_DEPTH  = 1024,
    parameter   R0_DATA_SIZE  =  128,  
    parameter CTRL_DATA_SIZE  =   48,  
    parameter     INSTR_SIZE  =   16,
    parameter     FRAME_SIZE  =  256,
    parameter      FRAME_NUM  =   64,
    parameter       CORE_NUM  =   16,
    parameter    BUS_TO_CORE  =   16,
    parameter       R0_DEPTH  =    8,
    parameter     START_ADDR  =    0
)


(
    input  wire clk,
    input  wire reset,
    input  wire [15: 0] core_reading,
    input  wire [15: 0] data_input,
//    input  wire [DATA_DEPTH  - 1: 0][INSTR_SIZE - 1: 0] data_frames_in,
    input  wire [CORE_NUM    - 1: 0]   core_ready,  // may be better reverse it
    output  reg [BUS_TO_CORE - 1: 0] mess_to_core,  //

    output wire [19: 0] input_addr, 
    output reg          r0_loading,
    output reg   core_mask_loading,
    output reg     r0_mask_loading,
    output reg       instr_loading
//change for wires where possible
);

    assign input_addr = START_ADDR + {10'h0, mem_ptr, load_cnt} + prog_loading2;
    reg [5: 0] mem_ptr;  


    reg prog_loading;
    reg prog_loading2;
    reg [3: 0] load_cnt;

    always @(posedge clk) begin
        if (reset)
            prog_loading <= 1;
        else
            prog_loading <= (load_cnt == 4'hf)                                     ? 0 : 
            ((global_tp[3: 0] == 4'hf) | (wait_it & (last_mask & exec_mask != 0))) ? 1 :
                                                                           prog_loading;
    end

    always @(posedge clk) begin
        if (reset)
            load_cnt <= 0;
        else
            load_cnt <= ~(prog_loading & prog_loading2)  ? 0 :
                        (load_cnt == 4'hf) ? 0 : load_cnt + 1;
    end
    
    always @(posedge clk) begin
        if (reset)
            mem_ptr <= 0;
        else
            mem_ptr <= ~(prog_loading2 & (load_cnt == 4'hf)) ? 
                         mem_ptr : mem_ptr + 1;
    end

    
    always @(posedge clk) begin
        if (reset)
            prog_loading2 <= 0;
        else
            prog_loading2 <= prog_loading;
    end


    
    genvar l;
    generate
    for (l = 0; l < 16; l = l + 1) begin: gen_frames_block_1
        always @(posedge clk) begin
            if (reset)
                frame[l] <= 0;
            else
                frame[l] <= (l == load_cnt) & (prog_loading2 & prog_loading) ? data_input : frame[l];
        end
    end
    endgenerate





    reg  [INSTR_SIZE - 1: 0] data_frames [DATA_DEPTH - 1: 0];   // better change type of memory later
    wire [INSTR_SIZE - 1: 0]  cur_frame  [FRAME_SIZE - 1: 0];
    reg  [INSTR_SIZE - 1: 0]      frame  [16         - 1: 0];



    reg  [CORE_NUM   - 1: 0]                    init_r0_vect;    // only new  data, old not considered here
    reg  [CORE_NUM   - 1: 0]                       last_mask;  // cores used by the latest task//
    wire [CORE_NUM   - 1: 0]                       exec_mask;

    reg [ 5: 0]      if_num;
    reg [ 5: 0] next_if_num;
    reg [ 9: 0]   global_tp;   // [3:0] = tp, [9:4] = frame 
    reg [ 1: 0]       fence;   // barrier . will be deleted. Now needed only for easy testing (about wires)
    reg             wait_it;
    
    wire end_prog;
    assign end_prog = (global_tp == 10'h3ff);

    reg no_collision;
    reg rel_stop;
    reg wait_not;
    /// temporal regs for testing

    wire flag1;
    wire flag2;
    wire no_wait_cf;

    wire write_en;
    wire tmp;
    assign tmp      = ((core_reading & last_mask) == last_mask);
    assign write_en = !prog_loading & (((core_reading & last_mask) == last_mask) | last_mask == 0);

    integer k;
    integer j;
   
    genvar a;
    generate
        for (a = 0; a < 16; a = a + 1) begin: gen_frames_block_2
            assign cur_frame[a] = frame[a];
			end
    endgenerate


    wire [INSTR_SIZE - 1: 0] fr0;
    wire [INSTR_SIZE - 1: 0] fr1;
    wire [INSTR_SIZE - 1: 0] fr2;
    wire [INSTR_SIZE - 1: 0] fr3;
    wire [INSTR_SIZE - 1: 0] fr4;
    wire [INSTR_SIZE - 1: 0] fr5;
    wire [INSTR_SIZE - 1: 0] fr6;
    wire [INSTR_SIZE - 1: 0] fr7;
    wire [INSTR_SIZE - 1: 0] fr8;
    wire [INSTR_SIZE - 1: 0] fr9;
    wire [INSTR_SIZE - 1: 0] fra;
    wire [INSTR_SIZE - 1: 0] frb;
    wire [INSTR_SIZE - 1: 0] frc;
    wire [INSTR_SIZE - 1: 0] frd;
    wire [INSTR_SIZE - 1: 0] fre;
    wire [INSTR_SIZE - 1: 0] frf;
    assign fr0 = frame[0];
    assign fr1 = frame[1];
    assign fr2 = frame[2];
    assign fr3 = frame[3];
    assign fr4 = frame[4];
    assign fr5 = frame[5];
    assign fr6 = frame[6];
    assign fr7 = frame[7];
    assign fr8 = frame[8];
    assign fr9 = frame[9];
    assign fra = frame[10];
    assign frb = frame[11];
    assign frc = frame[12];
    assign frd = frame[13];
    assign fre = frame[14];
    assign frf = frame[15];









    wire [INSTR_SIZE - 1: 0]    last_mask_w;
    wire [             1: 0]        fence_w;
    
    assign last_mask_w    =    frame[1];
    assign fence_w        =   (frame[0]  & `SCHED_FENCE_MASK) >> 6;

    assign flag1 = (((last_mask_w & exec_mask) == 0) | (exec_mask == 0)); 
    assign flag2 =  !((fence_w == `SCHED_FENCE_REL) & exec_mask != 0 );

    assign no_wait_cf     =   flag1 & flag2;
    assign exec_mask      =     ~core_ready;
    


/// fence   reg  logic
    always @(posedge clk) begin
        if (reset)
           fence <= 0;

        else begin
            fence <= (!prog_loading & if_num == 0 & global_tp[3: 0] == 0) ?
            fence_w  :  fence;        
            `ifdef TR
                $display("fence  ");
            `endif
        end
    end


/// last_mask   reg  logic
    always @(posedge clk) begin
        if (reset)
           last_mask <= 0;

        else
            last_mask <= (!prog_loading & if_num == 0 & global_tp[3: 0] == 0) ?
            last_mask_w : last_mask;
    end



/// init_r0_vect   reg  logic
    always @(posedge clk) begin
        if (reset)
           init_r0_vect <= 0;

        else
            init_r0_vect <= (write_en & if_num == 0 & global_tp[3: 0] == 0) ?
            frame[2] : init_r0_vect;
    end


    // noramal analog with if else if in the end of code
/// mess_to_core    reg  logic
    always @(posedge clk) begin // mb better add if(r0_mask, but easier not too and seems pointless)
        if (reset)
            mess_to_core <= 0;

        else 
            mess_to_core <= !(write_en) | ((if_num == 0) & (global_tp[3: 0] == 0))                     ? 
            mess_to_core                                                                               :

            ((if_num == 0 & global_tp[3: 0] != 1 & global_tp[3: 0] != 2) | if_num != 0)                ?
            frame[global_tp[3: 0]]                                                                 :
            
            (if_num == 0 & global_tp[3: 0] == 1)                                                       ?
            last_mask                                                                                  : 
            init_r0_vect                                                                               ;
    end

    
    `ifdef REG_D
    always @(posedge clk) begin
        if (!prog_loading & global_tp != 10'h40 ) begin
            $display("******************************************************************** ");
            $display("fence        = %h , if_num    = %h ", fence, if_num);
            $display("last_mask    = %h , exec_mask = %h ", last_mask, exec_mask);
            $display("init_r0_vect = %h , global_tp = %h ", init_r0_vect, global_tp);
            $display("cur_frame[0] = %h ", cur_frame[0]);
            $display("******************************************************************** ");
        end
    end // must work as for r0 load as for instr mes
    `endif

    
    `ifdef CUR_FR_D
      
    always @(posedge clk) begin

        if (!prog_loading & (global_tp[3: 0] == 4'h0) & global_tp != 10'h40) begin

            $display("============================================================================ ");
            for (integer n = 0; n < 16; n = n + 1) begin
                $display("cur_frame[%d] = %h , must_be data_frames[%h]  %h", n, cur_frame[n], {global_tp[9: 4], 4'd0} + n, data_frames[{global_tp[9: 4], 4'd0} + n]);
                $display("global_tp[9: 4] = %h, %h, %d , data_frames[%d] = %h", global_tp[9: 4], 4'h0, n, global_tp + n, data_frames[global_tp + n]);
            end

            $display("============================================================================ ");
        end 
    `endif





//r0_loading flag reg logic
    
    always @(posedge clk) begin
        if (reset)
            r0_loading <= 0;
        else
            r0_loading <= (write_en &   if_num == 0 & 
                            global_tp[3: 0] != 0 & global_tp[3: 0] != 1 & 
                            global_tp[3: 0] != 2)                       ?
            1: 0;
    end    

    //instr_loading flag reg logic
    
    always @(posedge clk) begin
        if (reset)
            instr_loading <= 0;
        else
            instr_loading <= (write_en & if_num != 0) ?
            1: 0;
    end    

//r0_mask_loading flag reg logic
    
    always @(posedge clk) begin
        if (reset)
            r0_mask_loading <= 0;
        else
            r0_mask_loading <= (write_en & if_num == 0 & 
                                global_tp[3: 0] == 2)  ?
                                                   1: 0;
    end    
        
//core_mask_loading flag reg logic
    
    always @(posedge clk) begin
        if (reset)
            core_mask_loading <= 0;
        else
            core_mask_loading <= (write_en & if_num == 0 & 
                                  global_tp[3: 0] == 1)  ?
                                                     1: 0;
    end    
    

/// global_tp  reg  logic
    always @(posedge clk) begin
        if (reset)
           global_tp <= 0;
        
        else if ((write_en) & if_num == 0 & global_tp[3: 0] == 2)
            global_tp <= global_tp + 10'h6;  //step over empty space
        
        else if (~end_prog & write_en & (if_num != 0 | global_tp[3: 0] != 2)
                 & !(if_num == 1 & global_tp[3: 0] == 4'hf & wait_it & (last_mask & exec_mask != 0))
                 & ( if_num == 0 & global_tp[3: 0] == 0 & no_wait_cf | if_num != 0 | global_tp[3: 0] != 0 )) 
            global_tp <= global_tp + `SCHED_MSG_BUS_WIDTH; // step over 1 msg

        else 
            global_tp <= global_tp;
    end // must work as for r0 load as for instr mes


/// if_num  reg  logic
    always @(posedge clk) begin
        if (reset) begin
           if_num <= 0;

        end else if (!prog_loading & if_num != 0 
                      & global_tp[3: 0] == 4'b1111 
                      & (if_num != 1  | !(wait_it & (last_mask & exec_mask != 0)))) begin  // must be 0000, but not enough time then
            if_num <= if_num - 1;

        end else if (!prog_loading & if_num == 0 & global_tp[3: 0] == 4'b1111)
            if_num <= next_if_num;

        else
            if_num <= if_num;
    end



/// next_if_num  reg  logic
    always @(posedge clk) begin
        if (reset) 
           next_if_num <= 0;

        else
            next_if_num <= (!prog_loading & if_num == 0 & global_tp[3: 0] == 0) ?
            frame[0] & `SCHED_IFNUM_MASK                                    :
            next_if_num                                                         ;
    end



    /// wait_it   reg  logic
    always @(posedge clk) begin
        if (reset)        
           wait_it <= 0;
                    
        else if (!prog_loading & if_num == 0 & global_tp[3: 0] == 1 &
            (fence == `SCHED_FENCE_ACQ)) // may be better delete it
            wait_it <= 1;

        else if (if_num == 0 & global_tp[3:0] == 0)
            wait_it <= 0;
        else
            wait_it <= wait_it;
    end

/*
    /// data_frames   reg  logic
    always @(posedge clk) begin
        if (prog_loading) begin
            for (j = 0; j < DATA_DEPTH; j++) begin
                data_frames[j] <= data_frames_in[j];

            end
        end
    end
*/

            `ifdef DATA_IN

    always @( negedge prog_loading) begin
            for (integer p = 0; p < DATA_DEPTH; p++) begin
                $display("data_frames[%d]    = %h", p, data_frames[p]);
                $display("data_frames_in[%d] = %h", p, data_frames_in[p]);
            end
    end

                `endif 




    endmodule

