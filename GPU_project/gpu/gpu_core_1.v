module gpu_core_1(
	input wire clk,
	input wire reset,
	input wire val_ins,
	input wire val_mask_R0,
	input wire val_mask_ac,
	input wire val_R0,
	
	
	input wire val_data, // val data from memmory
	input wire[15:0] instruction, // ins_mem from TS
	output reg [11:0] addr_shared_memory, // addr to shared memory  //clean
	input wire[7:0] mem_dat, // data from sm
	output reg [7:0] mem_dat_st, // data to sm //clean
	input wire [3:0] core_id,
	
	output reg rtr, // Ready to recieve      // CLEANED
	output reg mem_req_ld, // Memory request // CLEANED
	output reg mem_req_st, // Memory request // CLEANED
	output reg ready // READY signal to TS   // CLEANED
	);
	parameter [3:0] RI = 0,F = 1, D = 2, E = 3, M = 4, M_W = 5, WB = 6, NA = 7;
	//reg [3:0] state = RI;
	reg [3:0] state;
	
	// Internal registers
	reg [7:0] RF [0:15]; // Register File  
	reg [3:0] PC; // Instruction Pointer  // CLEANED
	reg [3:0] PC_D; // no need to clean
	reg [3:0] PC_E; // no need but it is not reseted at all
	reg [15:0] ins_mem [0:15]; // clean but not reseted
	reg [15:0] IR_D; //clean
	reg [15:0] IR_E; // clean + no reset
	reg [15:0] IR_M; // clean + no rst
	reg [15:0] IR_WB; // CLEANED
	reg [7:0] A;  // clean (seems)
	reg [7:0] D_WB; // clean + no rst
	reg [7:0] data_to_store_E;// clean + no rst
	reg [7:0] data_to_store_M;// clean + no rst
	reg [7:0] B_E; // clean + no rst

	reg [7:0] B_M;  // clean + no rst
	reg [11:0] O_M; // clean + no rst

	reg [11:0] O_WB; // cleaned
	
	
	reg br_tkn; // CLEANED
	reg [3:0] br_target; /// CLEANED
	
	reg [4:0] i ; // CLEANED    (but without else if)
	reg [4:0] counter_ri; // beda

	integer c;
	//integer count = 0;
	//reg cos = 1;

    reg cos1; // CLEANED
    always @(posedge clk) begin
        if (reset)
            cos1 <= 1;
        else
            cos1 <= (state == RI) ? 1 :
                    (state == D)  ? 0 :
                                  cos1;
    end



    reg [7:0] RF_0;
    reg [7:0] RF_1;
    reg [7:0] RF_2;
    reg [7:0] RF_3;
    reg [7:0] RF_4;
    reg [7:0] RF_5;
    reg [7:0] RF_6;
    reg [7:0] RF_7;
    reg [7:0] RF_8;
    reg [7:0] RF_9;
    reg [7:0] RF_10;
    reg [7:0] RF_11;
    reg [7:0] RF_12;
    reg [7:0] RF_13;
    reg [7:0] RF_14;
    reg [7:0] RF_15;


    always @(posedge clk) 
        begin
          RF_0 <= RF[0];
          RF_1 <= RF[1];
          RF_2 <= RF[2];
          RF_3 <= RF[3];
          RF_4 <= RF[4];
          RF_5 <= RF[5];
          RF_6 <= RF[6];
          RF_7 <= RF[7];
          RF_8 <= RF[8];
          RF_9 <= RF[9];
          RF_10 <= RF[10];
          RF_11 <= RF[11];
          RF_12 <= RF[12];
          RF_13 <= RF[13];
          RF_14 <= RF[14];
          RF_15 <= RF[15];
        end
    
   

always @(posedge clk) begin
    if (reset)
        i <= 0;
    else if (state == RI) begin
            
        if (val_ins) 
            i <= i + 1;
        
        if ((i == 16)&&(counter_ri == 16)) //chang to "else if" 
            i <= 0;                        // rotates the resulting picture

    end else
        i <= 0;
end
//state logic
    always @(posedge clk) begin
        if (reset)
            state <= RI;
        else if (state == RI)
			if ((val_mask_ac) && (!(instruction[core_id])))
			    state <= NA;
            else if ((i == 16)&&(counter_ri == 16))  //else
                state <= F;
            else
                state <= state;
        else if (state == F)
			state <= D;	
        else if (state == D)
			state <= E;	
        else if (state == E)
			state <= M;
        else if (state == M) begin 
			if(IR_M[15:12]==11 | IR_M[15:12] == 13)
			    state <= M_W;
			else if(IR_M[15:12]!=11 && IR_M[15:12]!=13)
    			state <= WB;
            else
                state <= state;
        end 
        else if (state == M_W) begin 
            if((val_data)&&IR_M[15:12]==11)
                state <= WB;
            else if((val_data)&&(IR_M[15:12]==13))
                state <= WB;
            else
                state <= state;
        end
        else if (state == WB) begin 
            if((IR_M[15:12]<11) || (IR_M[15:12]==12))
                state <= F;
            else if(IR_M[15:12]==11)
                state <= F;
            
            else if((IR_M[15:12]==13)||(IR_M[15:12]==14)||(IR_M[15:12]==0))
                state <= F;
            else if ((IR_E[15:12]==15)||(PC_E==15 && (IR_WB[15:12] != 14))) 
                state <= RI;
        end
        else if ((val_mask_ac)&&(instruction[core_id]))
            state <= RI;
        else
            state <= state;
    end


//brtaken logic
    always @(posedge clk) begin 
		if (reset) 
			br_target <= 0;
        else if (state == E & (IR_E[15:12] == 4'b1110) & (A != 0))
			br_target<=IR_E[7:4];
        else 
            br_target <= br_target;
    end

// IR_WB logic
	always @(posedge clk) begin 
        if (state == M_W) begin
			if((val_data)&&IR_M[15:12]==11)
				IR_WB <= IR_M;
            else if((val_data)&&(IR_M[15:12]==13))
                IR_WB <= IR_M;
            else
                IR_WB <= IR_WB;
        end else if (state == M & (IR_M[15:12]!=11 && IR_M[15:12]!=13))
            IR_WB <= IR_M;
        else
            IR_WB <= IR_WB;

    end// IR_WB logic




//brtaken logic
    always @(posedge clk) begin 
		if (reset) 
			br_tkn <= 0;
        else if ((state == F) & br_tkn)
            br_tkn <= 0;
        else if (state == E & (IR_E[15:12] == 4'b1110) & (A != 0))
            br_tkn <= 1;
        else 
            br_tkn <= br_tkn;
    end

	always @(posedge clk) begin 
        if (reset)
            PC <= 0;
        else if (state == F) begin
            if (br_tkn)
                PC <= br_target;
            else if (cos1)
                PC <= 0;
            else
                PC <= PC+1;

        end // br_tkn
        else if ((state == WB) & ((IR_E[15:12]==15)||(PC_E==15 && (IR_WB[15:12] != 14))) )
            PC <= 0;
    end // PC_alw


    always @(posedge clk) 
		begin
			if (reset) begin
                ready <= 1;
			end else if (state == RI & val_ins)
                ready <= 0;
            else if ((state == WB) & ((IR_E[15:12]==15)||(PC_E==15 && (IR_WB[15:12] != 14)))) 
                ready <= 1;
            else
                ready <= ready;

		end	



    always @(posedge clk) begin
			if (reset) 
				rtr <= 1;
            else if (state == RI)
				rtr <= 1;
            else if ((i == 16)&&(counter_ri == 16))
                rtr <= 0;
	end	



	
	always @(posedge clk) begin
	    if (reset) 
	        counter_ri <= 0;
        else if (state == RI) begin
            if (val_R0)
	            counter_ri <= counter_ri + 2;
            
            else if (val_ins)
                counter_ri <= 16;
			
            else if ((i == 16) & (counter_ri == 16))
                counter_ri <= 0;
            else 
                counter_ri <= counter_ri;
        end else
            counter_ri <= counter_ri;
    end


	always @(posedge clk)
		begin 
			if (!(reset)&&(state==F)) 
				begin
					if (br_tkn)
						begin
							IR_D <= ins_mem[br_target];
							PC_D <= br_target;
						end
					else
						if (cos1)
							begin 
								PC_D <= PC;
								IR_D <= ins_mem[PC];
								
							end
						else
							begin 
								PC_D <= PC+1;
								IR_D <= ins_mem[PC+1];
							end
				end
		end	

	always @(posedge clk)  begin
        if (reset) begin
            for (c = 0; c < 16; c=c+1 )
                RF[c] <= 0;
        
        end else if (state==RI) begin
            
            if ((val_mask_R0)&&(instruction[core_id]))
                RF[0] <= 1;
            
            else 
                RF[0] <= RF[0];		
            
            if (val_R0) begin
                if(RF[0] && (counter_ri == core_id))
                        RF[0] <= instruction[15:8];

                if(RF[0] && (counter_ri == core_id-1))
                        RF[0] <= instruction[7:0];
            end
        end
        else if (state==WB) begin
            if((IR_M[15:12]<11) || (IR_M[15:12]==12))
                    RF[IR_WB[3:0]]<= O_WB; 
                
            if(IR_M[15:12]==11)
                RF[IR_WB[3:0]]<= D_WB;
        end
	end


    always @(posedge clk) begin
        if (~reset & (state == RI)) begin
            if (val_ins) 
                ins_mem[i] <= instruction;

            else 
                ins_mem[i] <= ins_mem[i];
        end
    end



	always @(posedge clk)
		begin 
			if (!(reset)&&(state==D)) 
				begin
					IR_E <= IR_D;
					PC_E <= PC_D;
					if(IR_D[15:12]==13)
						begin
							data_to_store_E <= RF[IR_D[3:0]];
						end
					A <= RF[IR_D[11:8]];
					B_E <= RF[IR_D[7:4]]; 
					
				end
		end	
	


	always @(posedge clk)
		begin 
			if (!(reset)&&(state==E)) 
				begin
					case (IR_E[15:12])
						4'b0000: ; // nop
						4'b0001: O_M[7:0] <= A + B_E; // add
						4'b0010: O_M[7:0] <= A - B_E; // sub
						4'b0011: O_M[7:0] <= A * B_E; // mul
						4'b0100: O_M[7:0] <= A / B_E; // div
						4'b0101: O_M[7:0] <= A >= B_E; // cmpge
						4'b0110: O_M[7:0] <= A >> B_E[3:0]; // rshift
						4'b0111: O_M[7:0] <= A << B_E[3:0]; // lshift 
						4'b1000: O_M[7:0] <= A & B_E; // and
						4'b1001: O_M[7:0] <= A | B_E; // or
						4'b1010: O_M[7:0] <= A ^ B_E; // xor
						4'b1011: O_M      <= {A[3:0],B_E};  // addr for ld 
						4'b1100:  
							begin
								if (IR_E[3] == 0)
									begin
										O_M <= {4'h0,core_id[3:0]};
									end
								else
									begin  
										O_M <= {IR_E[11:8],IR_E[7:4]};
									end
							end
						4'b1101: O_M      <= {A[3:0],B_E};  //addr for st
					endcase  
					
					B_M <= B_E;
					IR_M <= IR_E;
					data_to_store_M <= data_to_store_E;
				end
		end	


// mem_req_ld logic
	always @(posedge clk) begin
        if (reset)
            mem_req_ld <= 0;
        else if ((state == M)   & (IR_M[15:12]==11))
			mem_req_ld <= 1;
        else if ((state == M_W) & ((val_data)&&IR_M[15:12]==11))
			mem_req_ld <= 0;
        else 
			mem_req_ld <= mem_req_ld;
    end


// mem_req_ld   logic
	always @(posedge clk) begin
        if (reset)
            mem_req_st <= 0;
        else if ((state == M)   & (IR_M[15:12]==13))
			mem_req_st <= 1;
        else if ((state == M_W) & ((val_data)&&IR_M[15:12]==13))
			mem_req_st <= 0;
        else 
			mem_req_st <= mem_req_st;
    end



	always @(posedge clk)
		begin
			if (reset)
				begin
				mem_dat_st<=0;
				addr_shared_memory<=0;
				end
			if (!(reset)&&(state==M)) 
				begin
					if(IR_M[15:12]==11)
						begin
							addr_shared_memory <= O_M;
						end
					if(IR_M[15:12]==13)
						begin
							mem_dat_st <= data_to_store_M;
							
							addr_shared_memory <= O_M;
						end	
					
					if(IR_M[15:12]!=11 && IR_M[15:12]!=13)
						begin
							//O_WB[7:0] <= O_M;
						end
				end
		end	

	always @(posedge clk) begin 
        if (!(reset) & (state==M_W)) begin
            if((val_data) & IR_M[15:12]==11) begin
                    D_WB[7:0] <= mem_dat;
                    O_WB[7:0] <= O_M;
            end
        end	
        else if (!(reset) & (state==M)) begin
            if(IR_M[15:12]!=11 && IR_M[15:12]!=13)
                O_WB[7:0] <= O_M;
        end
	end
	
	
endmodule
