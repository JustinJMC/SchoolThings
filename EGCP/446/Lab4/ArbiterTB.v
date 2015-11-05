/*
* ArbiterTB.v : A synchronous arbiter state machine TestBench
* Authors: Justin Mccarty & Bhagat Singh
* Rev_date: Nov 4, 2015
*
* Description:
* We are testing this MOORE FSM implementation with 5 states
* Synchronous to the rising edge of the clock
* A active LOW reset
* 4 active HIGH data inputs, reg[3:0]
* 4 active HIGH outputs, grant[3:0] (reg 3 => grant 3, and so on.)
* Priority to MSB
*/

//`timescale 1 ns / 100 ps
`include "Sync_Arbiter_1Hot.v"

module ArbiterTB ();
	//inputs to DUT are reg type
	reg reset, clk;
	reg [3:0] requests;
	
	//outputs from DUT are wire type
	wire [3:0] grantAccess;
	
	//instantiate the DUT
	Sync_Arbiter_1Hot DUT (
		.grant 	(grantAccess),
		.req 	(requests),
		.reset 	(reset), //while low
		.clk 	(clk)
		);
	
	//generate a clock
	initial
	begin
		clk = 1'b0;
		forever #5 clk = ~clk; //invert every 5ns creates 10ns period clock
	end
	
	//initial variables
	initial //set initial variables
	begin
		$display ($time, "<< Starting Simulation >>");
		reset=1'b1;
		requests=4'b0000;
		$display ($time, "<<variables set>>");
		$monitor ($time, "<<reset = %b, requests = %b, grantAccess = %b>>",reset,requests,grantAccess);
	end//end initialize variables
		
	initial //set end time
	begin
		#187 reset = ~reset;
		#50 $stop;
	end //end end time
	
	//always blocks
	always @(negedge clk)//to increment the requests 
	begin
		requests=requests+1;
	end
endmodule //end mux_TB
