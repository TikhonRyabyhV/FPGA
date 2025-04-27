`define OPCODE_NOP          4'h0   // No operation
`define OPCODE_ADD          4'h1   // RF[dst] <- RF[src_0] + RF[src_1]
`define OPCODE_SUB          4'h2   // RF[dst] <- RF[src_0] - RF[src_1]
`define OPCODE_MUL          4'h3   // {RF[dst+1], RF[dst]} <- RF[src_0] * RF[src_1]
`define OPCODE_DIV          4'h4   // RF[dst] <- RF[src_0] / RF[src_1]
`define OPCODE_CMPGE        4'h5   // RF[dst] <- RF[src_0] >= RF[src_1]
`define OPCODE_RSHFT        4'h6   // RF[dst] <- RF[src_0] >> src_1[2:0]
`define OPCODE_LSHFT        4'h7   // RF[dst] <- RF[src_0] << src_1[2:0]
`define OPCODE_AND          4'h8   // RF[dst] <- RF[src_0] & RF[src_1]
`define OPCODE_OR           4'h9   // RF[dst] <- RF[src_0] | RF[src_1]
`define OPCODE_XOR          4'hA   // RF[dst] <- RF[src_0] ^ RF[src_1]
`define OPCODE_LD           4'hB   // RF[dst] <- MEM[ADDR][11:0], ADDR[11:0] = {RF[src_1][3:0]; RF[src_0][7:0]}
`define OPCODE_LD_SYNC      4'hB   // аналогично операции ld, с аппаратной блокировкой
`define OPCODE_SET_CONST     4'hC   // Если(dst[3] = 0) RF[dst] <- {4'h0, core_id[3:0]} или RF[dst] <- {const_[7:4], const[3:0]}
`define OPCODE_ST            4'hD   // MEM[ADDR[11:0]] <- RF[src_2], ADDR[11:0]={RF[src_1][3:0]; RF[src_0][7:0]}
`define OPCODE_ST_SYNC       4'hD   // аналогично операции st, с аппаратной разблокировкой
`define OPCODE_BNZ           4'hE   // if(src0 != 0) IP ← target[3:0] * instr_size else IP ← IP + instr_size
`define OPCODE_READY         4'hF   // IP<-0; конец работы ядра (выдача сигнала READY в Task Scheduler)





`define R0 4'h0
`define R1 4'h1
`define R2 4'h2
`define R3 4'h3
`define R4 4'h4
`define R5 4'h5
`define R6 4'h6
`define R7 4'h7
`define R8 4'h8
`define R9 4'h9
`define R10 4'hA
`define R11 4'hB
`define R12 4'hC
`define R13 4'hD
`define R14 4'hE
`define R15 4'hF  

/*
module psv;	 
	
	reg [15:0] tm_line;
initial
	begin
		
		
		//1st frame
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R0};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R1};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R2};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R3};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R4};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R5};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R6};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R7};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R8};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R9};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R10};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R11};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R12};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R13};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R14};
		//
		//
		//
		tm_line = {`OPCODE_SET_CONST,4'h0,4'h0,`R15};
		//
		//
		//
		
		
		
		
		//2nd frame
		tm_line = {`OPCODE_ADD,R0,R1,R2};
		//
		//
		//
		tm_line = {`OPCODE_ADD,R0,R1,R8};
		//
		//
		//
		tm_line = {`OPCODE_MUL,R8,R8,R9};
		//
		//
		//
		tm_line = {`OPCODE_DIV,R9,R2,R12};
		//
		//
		//
		tm_line = {`OPCODE_SUB,R2,R1,R13};
		//
		//
		//
		tm_line = {`OPCODE_CMPGE,R9,R2,R15};
		//
		//
		//
		tm_line = {`OPCODE_RSHFT,R9,R0,R14};
		//
		//
		//
		tm_line = {`OPCODE_LSHFT,R9,R0,R14};
		//
		//
		//
		tm_line = {`OPCODE_AND,R0,R2,R7};
		//
		//
		//
		tm_line = {`OPCODE_OR,R0,R2,R7};
		//
		//
		//
		tm_line = {`OPCODE_XOR,R1,R0,R7};
		//
		//
		//
		tm_line = {`OPCODE_LD,R0,R0,R0};
		//
		//
		//
		tm_line = {`OPCODE_ST,R0,R0,R0};
		//
		//
		//
		tm_line = {`OPCODE_SUB,R0,R3,R0};
		//
		//
		//
		tm_line = {`OPCODE_BNZ,R0,R13,R13};
		//
		//
		//
		tm_line = {`OPCODE_READY,R0,R0,R0};
		//
		//
		//
	end
endmodule	

*/
