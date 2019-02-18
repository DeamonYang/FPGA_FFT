`timescale 1ns/1ps


module butterfly_ra2_tb;



	reg rst_n;
	reg clk;
	reg bf_go;
	wire bf_done;
	reg signed[7:0]wx;
	reg signed[7:0]wy;
	reg signed[7:0]x1;
	reg signed[7:0]y1;
	reg signed[7:0]x2;
	reg signed[7:0]y2;
	wire signed[8:0]bfx1;
	wire signed[8:0]bfy1;
	wire signed[8:0]bfx2;
	wire signed[8:0]bfy2;



	butterfly_ra2 butterfly_ra2_lab1(
		rst_n,
		clk,
		bf_go,
		bf_done,
		wx,
		wy,
		x1,
		y1,
		x2,
		y2,
		bfx1,
		bfy1,
		bfx2,
		bfy2
	 );
	 
	 
	 initial begin
		rst_n = 0;

		#210;
		rst_n = 1;

		#40000;
		$stop;
	 end
	 
	 

	 
	 
	 initial clk = 0;
	 always #20 clk = ~clk;
	 
	 initial begin
		wx = 8'd1;
		wy = 8'd1;
		x1 = 8'd1;
		y1 = 8'd1;
		x2 = 8'd1;
		y2 = 8'd1;	
		bf_go = 0;
		#210;
		forever begin
			wx = wx + 10;
			wy = wy + 20;
			x1 = x1 + 30;
			y1 = y1 + 40;
			x2 = x2 + 50;
			y2 = y2 + 60;
			bf_go = 1;
			#40;
			bf_go = 0;
			#80;
		
		end
	 end
	 



endmodule
