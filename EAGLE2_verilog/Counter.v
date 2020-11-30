`timescale 1ns/1ps

module Counter (
	input wire clk,
	input wire nrst,
	output reg [11:0] value
	);
	always @(posedge clk or negedge nrst) begin
		if (~nrst)
			value <= 0;
		else begin
			value <= value + 1;
		end
	end

endmodule
