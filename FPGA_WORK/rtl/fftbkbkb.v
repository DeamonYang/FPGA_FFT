//128点FFT
module fft(
	rst_n,
	clk,
	data1,
	
	fft_go,
	fft_done,
	fft_res
);
	input rst_n;
	input clk;
	input signed[7:0]data1;
	input fft_go;
	output reg fft_done;
	output reg signed[815:0]fft_res;	
	
	reg[4:0]current_state;
	reg[4:0]next_state;
	reg rad_data_en;//读取外部数据使能
	reg[6:0]rd_cnt;
	reg[6:0]rd_data_add;//RAM 从外部读取数据线
	
//	assign rd_data_add = 7'b{rd_cnt[0]},{rd_cnt[1]},{rd_cnt[2]},{rd_cnt[3]},{rd_cnt[4]},{rd_cnt[5]},{rd_cnt[6]};
	
	
	localparam[4:0]
		IDEL  = 5'd0_0001,
		RADDAT= 5'd0_0010,
		FBKSEQ= 5'd0_0100,
		FFTCLC= 5'd0_1000,
		FFTOUT= 5'd1_0000;
	
//	/*读数据使能信号*/
//	always@(posedge clk or negedge rst_n )
//	if(!rst_n)
//		rad_data_en <= 1'b0;
//	else if(fft_go)
//		rad_data_en <= 1'd1;
//	else if(rd_cnt == 7'd111_1110)
//		rad_data_en <= 1'd0;


	ram128 ram_rel(
		.address(rd_data_add),
		.clock(clk),
		.data(data1),
		.wren(),
		.q());
		
		
	/*RAM 数据读取地址生成*/
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		rd_data_add <= 7'd0;
	else case()

	/*读取数据 计数器 */
	always@(posedge clk or negedge rst_n )
	if(!rst_n)
		rd_cnt <= 1'b0;
	else if(current_state == RADDAT)
		rd_cnt <= rd_cnt + 1'd1;
		
	/*将外部数据读取到RAM*/
	always@(posedge clk or negedge rst_n )
	if(!rst_n)
		rd_cnt <= 1'b0;
	else if(current_state == RADDAT)
		rd_cnt <= rd_cnt + 1'd1;
	
	
	
	/*状态机*/
	always@(posedge clk or negedge rst_n )
	if(!rst_n)
		current_state <= IDEL;
	else
		current_state <= next_state;
		
		
		
	always@(posedge clk or negedge rst_n )
	if(!rst_n)
		next_state <= IDEL;
	else case(current_state)
		IDEL	:begin
					if(fft_go)
						next_state <= RADDAT;
				end
				
		RADDAT:begin
						if(rd_cnt == 7'd111_1110)
							next_state <= FBKSEQ;
				end
		FBKSEQ:begin


				end
		
		
endmodule



























