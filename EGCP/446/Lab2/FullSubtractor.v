/*
* Verilog program to model a 1bit Full Subtractor
* Justin Mccarty & Bhagat Singh
* Rev_date: Oct 15, 2015
*
* Description:
* We are implementing a Full Subtractor at the structural gate level. There are several 
* design specifications that we must follow:
* 	NOT, 2-input AND, 3-input OR and 3-input XOR
*/
`define NOT #1 //The propagation delay for each NOT gate is 1 ns
`define OR #2  //The propagation delay for each OR  gate is 2 ns
`define AND #2 //The propagation delay for each AND gate is 2 ns
`define XOR #3 //The propagation delay for each XOR gate is 3 ns

module FullSub (diff, bout, x, y, bin);
	//input/output
	output diff, bout;
	input x,y,bin;
	//internal wires
	wire xNot, w1,w2,w3;
	//internal structure
	
	//step 1 
	assign `NOT xNot = !x;
	//step2
	assign `XOR diff= x ^ y ^ bin;
	assign `AND w1 = xNot & y;
	assign `AND w2 = xNot & bin;
	assign `AND w3 = bin & y;
	//step 3
	assign `OR bout = w1 | w2 | w3;
	
endmodule

/* //for testing in ModelSim
force -repeat 80 x 0 0, 1 40, 0 80
force -repeat 40 y 0 0, 1 20, 0 40
force -repeat 20 bin 0 0, 1 10, 0 20
*/
