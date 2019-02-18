`timescale 1ns/1ps
module fft_tb;
	
	
	
	reg 	rst_n;
	reg 	clk;
	reg 	signed[7:0]data1;
	reg 	fft_go;
	wire 	fft_done;
	wire 	[7:0]fft_res_rel;	
	wire 	[7:0]fft_res_img;

	reg [6:0]test_ram_add;
	wire	[15:0] test_data;
	reg	  test_wren;
	wire [15:0]  test_q;

	fft fft_lab1(
		.rst_n(rst_n),
		.clk(clk),
		.data1(data1),
		.fft_go(fft_go),
		.fft_done(fft_done),
		.fft_res({fft_res_rel,fft_res_img})
	);
	
	assign test_data = {8'd0,test_ram_add};
	ram128 ram_test(
		.address(test_ram_add),
		.clock(clk),
		.data(test_data),
		.wren(test_wren),
		.q(test_q));
	
	initial begin
		test_ram_add = 0;
		test_wren = 1;
		#5120
		test_wren = 0;
	end
	
	always #40 test_ram_add = test_ram_add + 1;
	
	
	
	
	initial begin
		rst_n = 0;
		fft_go = 0;
		#1000;
		rst_n = 1;
		#100;
		fft_go = 1;
		#40;
		fft_go = 0;
		
		#240000;
		$stop;
	
	
	end
	
	initial clk = 0;
	always #20 clk = ~clk;
	
	
	initial begin
		data1 = 0;
		#1000;
		forever begin
		
			data1 = data1 + 1;
			#20;
		
		end
	
	
	
	end

endmodule




