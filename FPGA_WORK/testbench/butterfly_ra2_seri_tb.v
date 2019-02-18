`timescale 1ns/1ps
module butterfly_ra2_seri_tb;


	reg rst_n;
	reg clk;
	reg bf_go;
	wire bf_done;
	
	reg[7:0]datax;
	reg[7:0]datay;
	reg[7:0]wx;//第一个时钟周期读取旋转因子
	reg[7:0]wy;

	wire[7:0]bfx;
	wire[7:0]bfy;
	wire wren;
	
	butterfly_ra2_seri bs(
		rst_n,
		clk,
		bf_go,
		bf_done,
		
		datax,
		datay,
		
		wx,//第一个时钟周期读取旋转因子
		wy,
		
		wren,//写数据使能
		bfx,
		bfy);

		
	initial clk = 0;
	always #20 clk = ~clk;
	
	initial begin
		rst_n = 0;
		#1000;
		rst_n = 1;

		
		#4000;
		$stop;
	
	end
	
	
	
	
	initial begin
		datax = 128;
		datay = 100;
		wx = 20;
		wy = 35;
		forever begin
			datax = datax + 5;
			datay = datay - 5;
			bf_go = 1;
			#40;
			bf_go = 0;
			#320;
		end
	
	
	
	end



endmodule


