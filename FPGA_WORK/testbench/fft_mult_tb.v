`timescale 1ns/1ps
module fft_mult_tb;


	reg rst_n;
	reg clk;
	reg[7:0]data1;
	reg[7:0]data2;
	wire [15:0]res;	
	
	
	fft fft_lab1(
			.rst_n(rst_n),
			.clk(clk),
			.data1(data1),
			.data2(data2),
			.res(res)
		);

	initial begin
		rst_n = 0;
		#100;
		rst_n = 1;
		
		
		#40000;
		$stop;
		
	end
	
	initial clk = 0;
	always #20 clk = ~clk;
	
	initial begin
		data1 = 0;
		data2 = 8'hff;
		
		forever begin
			data1 = data1 + 1'b1;
			data2 = data2 - 1'b1;
			#40;
		
		end
	
	end 



endmodule


