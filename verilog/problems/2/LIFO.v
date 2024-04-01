module LIFO 
#(
	parameter DATA_W             = 8,
	parameter LIFO_SIZE          = 8,
	parameter STACK_POINTER_SIZE = $clog2(LIFO_SIZE) + 1 )
(
	output reg [DATA_W - 1:0] dataout,
	output                    full,
	output                    val,
	input      [DATA_W - 1:0] datain,
	input                     clock,
	input                     reset,
	input                     write,
	input                     read	
);
  
  reg [STACK_POINTER_SIZE - 1:0] stack_pointer;
  reg [LIFO_SIZE - 1:0] stack [DATA_W - 1:0];
  

  assign full = (stack_pointer >= LIFO_SIZE) ? 1 : 0;
  assign val  = (stack_pointer <=     0    ) ? 0 : 1;
  
  always @(posedge clock)
  begin
    if (reset) begin
        dataout       <= 0; 
	stack_pointer <= 0; // buffer reset
    end

    else if (read & write) begin
	    dataout <= datain; // in case of simultaneous reading and writing
    end

    else if (read & val) begin
	    dataout       <= stack[stack_pointer - 1];
	    stack_pointer <= stack_pointer - 1; // only reading from buffer with some data
    end

    else if (write & !full) begin
	    stack_pointer            <= stack_pointer + 1;
	    stack[stack_pointer - 1] <= datain; // only writing in buffer with some free place
    end
  end
endmodule
