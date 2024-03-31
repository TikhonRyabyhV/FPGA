`timescale 1ns/100ps

module testbench();

	wire [3:0]res;
	reg [9:0]in;

	vec_add vec_add( .data(in), .sum(res) );

	initial begin
		#1; in = 10'b0001110111; #1; $display( "In: %d. Sum: %d\n", in, res );
		#1; in = 10'b1001110111; #1; $display( "In: %d. Sum: %d\n", in, res );
		#1; in = 10'b0001110000; #1; $display( "In: %d. Sum: %d\n", in, res );
	end

endmodule

