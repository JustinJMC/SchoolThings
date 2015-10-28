/*
* Sync_Arbiter_1Hot.v : A synchronous arbiter state machine
* Authors: Justin Mccarty & Bhagat Singh
* Rev_date: Oct 28, 2015
*
* Description:
* We are implementing this with a MOORE FSM implementation with 5 states
* Synchronous to the rising edge of the clock
* A active LOW reset
* 4 active HIGH data inputs, reg[3:0]
* 4 active HIGH outputs, grant[3:0] (reg 3 => grant 3, and so on.)
* Priority to MSB
*/

module Sync_Arbiter_1Hot (grant, req, reset, clk);
	//input and input data types
	input [3:0] req;
	input reset, clk;
	
	wire [3:0] req;
	wire reset, clk;
	//output and output data types
	output [3:0] grant;
	reg [3:0] grant;
	
	//state variables
	reg [4:0] state;
	reg [4:0] nextState;
	
	//internal Constants // defining the states
	parameter IDLE=5'b00001, S1=5'b00010,S2=5'b00100,S3=5'b01000,S4=5'b10000;
	
	//initial state
	initial
		state=IDLE;
	
	//Next State logic
	always @ (state or req)
	begin 
		nextState=IDLE;
		case(state)
			IDLE : 	
				if (req[3]==1'b1) begin
					nextState=S4;
				end else if (req[2]==1'b1) begin
					nextState=S3;
				end else if (req[1]==1'b1) begin
					nextState=S2;
				end else if (req[0]==1'b1) begin
					nextState=S1;
				end else begin 
					nextState=IDLE;
				end
			S1 : 	
				if (req[3]==1'b1) begin
					nextState=S4;
				end else if (req[2]==1'b1) begin
					nextState=S3;
				end else if (req[1]==1'b1) begin
					nextState=S2;
				end else if (req[0]==1'b1) begin
					nextState=S1;
				end else begin 
					nextState=IDLE;
				end		
			S2 : 	
				if (req[3]==1'b1) begin
					nextState=S4;
				end else if (req[2]==1'b1) begin
					nextState=S3;
				end else if (req[1]==1'b1) begin
					nextState=S2;
				end else if (req[0]==1'b1) begin
					nextState=S1;
				end else begin 
					nextState=IDLE;
				end		
			S3 : 	
				if (req[3]==1'b1) begin
					nextState=S4;
				end else if (req[2]==1'b1) begin
					nextState=S3;
				end else if (req[1]==1'b1) begin
					nextState=S2;
				end else if (req[0]==1'b1) begin
					nextState=S1;
				end else begin 
					nextState=IDLE;
				end	
			S4 : 	
				if (req[3]==1'b1) begin
					nextState=S4;
				end else if (req[2]==1'b1) begin
					nextState=S3;
				end else if (req[1]==1'b1) begin
					nextState=S2;
				end else if (req[0]==1'b1) begin
					nextState=S1;
				end else begin 
					nextState=IDLE;
				end		
			default : nextState=IDLE;
		endcase
	end
	//clock and reset logic 
	always @ (posedge clk)
	begin
		if (reset == 1'b0) 
			state <= IDLE;
		else 
			state <= nextState;
	end 
	
	//output logic
	always @ (state)
	begin
		case (state)
			IDLE: 
				begin
					grant<=4'b0000;
				end
			S1 	: 
				begin
					grant<=4'b0001;
				end 
			S2 	:  
				begin
					grant<=4'b0010;
				end 
			S3 	: 
				begin
					grant<=4'b0100;
				end 
			S4 	: 
				begin
					grant<=4'b1000;
				end 
			default : grant<=4'b0000;
		endcase
	end
endmodule

/* //for testing in ModelSim
force -repeat 320 reset 0 0, 1 160, 0 320
force -repeat 160 req 0000 0, 0001 10, 0010 20,0011 30,0100 40, 0101 50, 0110 60,0111 70,1000 80, 1001 90, 1010 100,1011 110,1100 120, 1101 130, 1110 140,1111 150,0000 160
force -repeat 10 clk 0 0, 1 5, 0 10
*/
