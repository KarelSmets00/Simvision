`timescale 1ns/1ps

module Heartbeat (
	input wire clk,
	input wire nrst,
	input wire swiptONHeartbeat,
	output wire swipt
	);

	//-----------------------------//
	// TA heartbeat implementation //
	// Experimental at this point  //
	// Update status after testing //
	//-----------------------------//
	reg [23:0] heartbeatCounter;
	// oldheartbeat should be zero on startup!
	reg oldheartbeat = 0;
	// swiptAlive should be zero on startup!
    reg swiptAlive = 0;
	wire heartbeatEdge;
	
	// Edge detection on the heartbeat signal
	assign heartbeatEdge = swiptONHeartbeat ^ oldheartbeat;
	
	always @(posedge clk) begin
	
	   // Keep track of the heartbeat value of the previous cycle for the edge detection	
	   oldheartbeat <= swiptONHeartbeat;
	
	   // Synchronous reset
	   if (~nrst) begin
	       heartbeatCounter <= 0;
	       swiptAlive <= 0;
	   end
	   // Actual heartbeat logic
	   else begin
	       // On a new heartbeatEdge, swipt is live and counter is reset
	       if(heartbeatEdge) begin
	           heartbeatCounter <= 0;
	           swiptAlive <= 1;	           
	       end
	       else begin
	           // If last heartbeat more than 1m cycles ago, swipt is dead. DO NOT COUNT TO AVOID OVERFLOW OF COUNTER
	           if(heartbeatCounter >= 1000000) begin
	               swiptAlive <= 0;	         
	           end
	           // Increment counter
	           else begin
	               heartbeatCounter <= heartbeatCounter + 1;
	           end
	       end
	   end
	end
	
	assign swipt = swiptAlive;

endmodule
