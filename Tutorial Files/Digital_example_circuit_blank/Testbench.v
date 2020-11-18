`timescale 1ns/1ps


module toplevel ();

	reg clk = 1'b1;
	reg nrst = 1'b1;
	reg enable = 1'b0;

	wire [7:0] value;

	// Clk gen (fclk = 100MHz)
	always
	#5 clk = ~clk;

	// Reset and enable
	initial begin
		#5 nrst = 1'b0;
		#15 nrst = 1'b1;
		#25 enable = 1'b1;
	end

		
	

endmodule
