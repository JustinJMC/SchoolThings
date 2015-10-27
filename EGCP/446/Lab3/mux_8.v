/*************************************************
* File: mux_TB.v
* Purpose: Testbench for the 8to1_mux.v file.
* Authors: Justin McCarty and Bhagat Singh
* Rev_date: 10/22/2015
*
*
**************************************************/

`include "2to1_mux.v"				   //including 2 to 1 Mux file for mapping

module mux_8 (y, I0, I1, I2, I3 , I4, I5, I6, I7, control);

	input I0, I1, I2, I3 , I4, I5, I6, I7;	   //inputs for 8 to 1 Mux
	input [2:0] control;			   //defining Select
	output y;				   //output of 8 to 1 Mux
	wire w1, w2, w3, w4, w5, w6, sel1, sel2;   //declaring wires
	
	buf #5 	buffer1	(sel1,control[1]);  //introducing delays for S1 and S2
	buf #10 buffer2 (sel2,control[2]);

	//step 1 with Sel0 as input
	mux_2 m1(
	.p		(w1),      //portmapping inputs of 2 to 1 Mux
	.a		(I0),
	.b		(I1),
	.sel	(control[0])
	);
	mux_2 m2(
	.p		(w2),
	.a		(I2),
	.b		(I3),
	.sel	(control[0])
	);
	mux_2 m3(
	.p		(w3),
	.a		(I4),
	.b		(I5),
	.sel	(control[0])
	);
	mux_2 m4(
	.p		(w4),
	.a		(I6),
	.b		(I7),
	.sel	(control[0])
	);
	
	//step 2 with Sel 1 as input
	mux_2 m5(
	.p		(w5),
	.a		(w1),
	.b		(w2),
	.sel	(sel1)
	);
	mux_2 m6(
	.p		(w6),
	.a		(w3),
	.b		(w4),
	.sel	(sel1)
	);
	
	//step 3 with Sel2 as input
	mux_2 m7(
	.p		(y),
	.a		(w5),
	.b		(w6),
	.sel	(sel2)
	);
	
endmodule
