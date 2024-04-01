`timescale 1ns/100ps
module testbench_p2();
  
	wire [7:0] DATAOUT;
  	wire full, val;
  	reg reset, wn, rn;
  	reg [7:0] DATAIN;  
	
	reg clock = 1'b1;
	always begin
		#5 clock = ~clock;
	end

  	LIFO LIFO ( .dataout(DATAOUT), .full(full), .val(val), .datain(DATAIN), .clock(clock), .reset(reset), .write(wn), .read(rn) );
  
	initial begin 
		$dumpfile("dump.vcd"); $dumpvars;
	end
	
	initial begin
	       DATAIN = 8'h0;
	       reset = 1; #10;
	       reset = 0;
	       
	       $display("Start testing");
	       
	       wn = 1; rn = 0;
	       #20; DATAIN = 8'h5;

	       #10; wn = 1; rn = 1;
	       #20; DATAIN = 8'h8;
	       #10; DATAIN = 8'h10;
	       
	       reset = 1;
	       #10; DATAIN = 8'h40;
	       #10; DATAIN = 8'h70;
	       
	       reset = 0;
	       wn = 1; rn = 0;
	       #20; DATAIN = 8'h4;
	       #10; DATAIN = 8'h3;
	       #10; DATAIN = 8'h67;
	       
	       wn = 0; rn = 1;
	       #70; $finish;
       end

endmodule
