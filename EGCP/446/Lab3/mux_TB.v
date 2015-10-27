/*************************************************
* File: mux_TB.v
* Purpose: Testbench for the 8to1_mux.v file.
* Authors: Justin McCarty and Bhagat Singh
* Rev_date: 10/22/2015
*
*
**************************************************/

//`timescale 1 ns / 100 ps
`include "8to1_mux.v"



primitive mutli (mux, control1,control2,control3, in0,in1,in2,in3,in4,in5,in6,in7);
	output mux;
	input control1,control2,control3;
	input in0,in1,in2,in3,in4,in5,in6,in7;
	table
	//control 	in0	in1	in2	in3	in4	in5	in6	in7		mux
		0 0 0 	1	?	?	?	?	?	?	?	: 	1;
		0 0 0		0	?	?	?	?	?	?	?	: 	0;
		0 0 1		?	1	?	?	?	?	?	?	: 	1;
		0 0 1		?	0	?	?	?	?	?	?	: 	0;
		0 1 0		?	?	1	?	?	?	?	?	: 	1;
		0 1 0		?	?	0	?	?	?	?	?	: 	0;
		0 1 1		?	?	?	1	?	?	?	?	: 	1;
		0 1 1		?	?	?	0	?	?	?	?	: 	0;
		1 0 0		?	?	?	?	1	?	?	?	: 	1;
		1 0 0		?	?	?	?	0	?	?	?	: 	0;
		1 0 1		?	?	?	?	?	1	?	?	: 	1;
		1 0 1		?	?	?	?	?	0	?	?	: 	0;
		1 1 0		?	?	?	?	?	?	1	?	: 	1;
		1 1 0		?	?	?	?	?	?	0	?	: 	0;
		1 1 1 	?	?	?	?	?	?	?	1	: 	1;
		1 1 1		?	?	?	?	? 	?	?	0	: 	0;
	endtable
endprimitive

module mux_TB ();
	//inputs to DUT are reg type
	reg in0,in1,in2,in3,in4,in5,in6,in7;
	reg [2:0] select;
	reg clk;
	reg clk_flag;
	
	//outputs from DUT are wire type
	wire out;
	wire temp;
	
	//instantiate the DUT
	mux_8 DUT (
		.y	(out), 
		.I0	(in0), 
		.I1	(in1), 
		.I2	(in2), 
		.I3	(in3), 
		.I4	(in4), 
		.I5	(in5), 
		.I6	(in6), 
		.I7	(in7), 
		.control (select)
		);
	//instantiate the "cheater" 
	mutli cheaterTruthTable(
		temp, 
		select[0],select[1],select[2], 
		in0,in1,in2,in3,in4,in5,in6,in7
		);//end instantiate truthtable
	
	//generate a clock
	always
		#10 clk = ~clk; //invert every 10ns creates 20ns period clock
	
	//initial variables
	initial //set initial variables
		begin
		$display ($time, "<< Starting Simulation >>");
		in0 = $random; //random inputs
		in1 = $random;
		in2 = $random;
		in3 = $random;
		in4 = $random;
		in5 = $random;
		in6 = $random;
		in7 = $random;
		clk = 1'b0;
		select=3'b000;
		clk_flag=1'b0;
		$display ($time, "<<variables set>>");
		$display ("in0 = %b, in1 = %b, in2 = %b, in3 = %b, in4 = %b, in5 = %b, in6 = %b, in7 = %b",in0,in1,in2,in3,in4,in5,in6,in7);
		end//end initialize variables
	initial //set end time
		begin
			#320 $display ($time, "<<simulation end, no errors>>");
			$finish;
		end //end end time
	
	//always blocks
	always @ (posedge clk) 
		begin//will flip inputs, and inc select ever other. clk is 20ns
			in0=~in0; //flip all inputs
			in1=~in1;
			in2=~in2;
			in3=~in3;
			in4=~in4;
			in5=~in5;
			in6=~in6;
			in7=~in7;
			
			if (clk_flag==1)//every other clock increment select
				begin //flag is 1 and clk posedge, will flip in and inc select
					select=select+1;//will wrap around every 8*40ns=320ns
					$display ($time, "<<flipping inputs and incrementing select>>"); 
				end
			else
				$display ($time, "<<flipping inputs>>"); 
				
			clk_flag=~clk_flag;//flip flag always
		end//end clock block
	/*	 We haven't learned automated testing at this point in this class yet.
	task test;
		input out,temp;
		begin 
			if (out!=temp)
			begin //fatal error, end simulation
				$display ($time, "<<error at %b, with out value %b, for input value %b>>",select,out,temp);
				$finish;
			end
		end
	endtask//end test	
		
	always #15 @ (in0,in1,in2,in3,in4,in5,in6,in7);
		test(out,temp);
	*/
endmodule //end mux_TB
