/*************************************************
* File: 2to1_mux.v
* Purpose: Testbench for the 8to1_mux.v file.
* Authors: Justin McCarty and Bhagat Singh
* Rev_date: 10/19/2015
*
*
**************************************************/

module mux_2 (p, a, b, sel);

	input a, b, sel;  // defining inputs

	output p;

	// wire w1, w2;

	assign #5 p = (~sel & a) | (sel & b);  // AND & OR operation for 2 to 1 Mux

endmodule
