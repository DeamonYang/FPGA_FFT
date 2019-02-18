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
	output [15:0]fft_res;	
	
	reg[7:0]current_state;
	reg[7:0]next_state;
	reg rad_data_en;//读取外部数据使能
	reg[6:0]rd_cnt;
	reg[6:0]ot_cnt;
	reg unsigned[6:0]rd_data_add;//RAM 从外部读取数据线
	reg r_wren;
	reg [3:0]lay_cnt;	//级数计数器 2^7 = 128 共7 级
	reg [6:0]r_lay_cnt;//级数计数器 2^7 = 128 共7 级 采用移位计数方式
	reg [6:0]bf_cnt;	//每级FFT 进行 蝶形变换的数目
	wire bf_done;		//一级蝶形变换计算完毕信号 单时钟周期
	reg unsigned [6:0]bstep;
	reg[5:0]rom_wn;
	reg[3:0]bf_clc_cnt;
	reg bf_go;
	wire[15:0]ram_out;
	wire[15:0]ram_data_in;
	wire[15:0]bf_data_out;
	wire[15:0]w_wnp;
	wire[15:0]fft_data_out;
	reg[6:0]ram_add_prv;
//	assign rd_data_add = 7'b{rd_cnt[0]},{rd_cnt[1]},{rd_cnt[2]},{rd_cnt[3]},{rd_cnt[4]},{rd_cnt[5]},{rd_cnt[6]};
	
	
	localparam[7:0]
		IDEL  = 8'b0000_0001,
		RADDAT= 8'b0000_0010,
		FBKSEQ= 8'b0000_0100,
//		FFTRDD= 8'b0000_1000;
		FFTCLC= 8'b0001_0000,
//		FFTSVD= 8'b0010_0000;
		FFTOUT= 8'b0100_0000;
	
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
		.data(ram_data_in),
		.wren(r_wren),
		.q(ram_out));
		
	/*旋转因子 ROM表 地址5:0 数据 15:0 代表 rel + i*img   分别为 bits 88*/
	wnp wnp_tab(
		.address(rom_wn),
		.clock(clk),
		.q(w_wnp));

		
	
	always@(posedge clk or negedge rst_n )
	if(!rst_n)
		lay_cnt <= 4'b0;
	else if((current_state == FFTCLC)&(bf_cnt == 7'd64)&(bf_clc_cnt == 4'd9))
		lay_cnt <= lay_cnt + 1'd1;
	
	/*级数 计数器 采用移位计数方式 L */
	always@(posedge clk or negedge rst_n )
	if(!rst_n)
		r_lay_cnt <= 1'b0;
	else 
		r_lay_cnt <= 1'b1 << lay_cnt;			
	
	
	/*每层蝶形变换计数器 */
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		bf_cnt <= 7'b0;
	else if((current_state == FFTCLC)&(bf_clc_cnt == 4'd0)&(r_wren == 1'b1))
		if(bf_cnt < 7'd64)
			bf_cnt <= bf_cnt + 1'd1;
		else
			bf_cnt <= 7'd1;
	
	/*每个蝶形的两个输入数据的步距*/
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		bstep <= 7'b0;
	else 
		bstep <= 7'b1<<(lay_cnt );
		
	/*蝶形变化计算 计数器*/
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		bf_clc_cnt <= 4'b0;
	else 
		if((current_state == FFTCLC)&(bf_clc_cnt < 4'd9))
			bf_clc_cnt <= bf_clc_cnt + 1'd1;
		else	
			bf_clc_cnt <= 4'd0;
		

		
	/*RAM 数据读写地址生成*/
	always@(posedge clk or negedge rst_n)
	if(!rst_n)begin
		rd_data_add <= 7'd0;
		r_wren <= 1'd0;
		bf_go <= 1'd0;
		ram_add_prv <='d0;
		rom_wn <= 6'd0;
	end 
	else case(current_state)
		RADDAT :begin
			r_wren <= 1'd1;
			rd_data_add <= {rd_cnt[0],rd_cnt[1],rd_cnt[2],rd_cnt[3],rd_cnt[4],rd_cnt[5],rd_cnt[6]};//rd_cnt[0:6];//输入数据倒序
		end
		
		/*计算蝶形变换 一次蝶形变换分为 读取RAN 和存储 RAM*/
		FFTCLC :
			case(bf_clc_cnt)
				0:begin
					bf_go <= 1'd1;//下一个时钟开始读取数据
					r_wren <= 1'd0;
					/*每次蝶形变换的RAM 数据读取的地址*/
					rd_data_add[0] <= (r_lay_cnt[6]|r_lay_cnt[5]|r_lay_cnt[4]|r_lay_cnt[3]|r_lay_cnt[2]|r_lay_cnt[1])&(bf_cnt[0]) ;
					rd_data_add[1] <= (r_lay_cnt[6]|r_lay_cnt[5]|r_lay_cnt[4]|r_lay_cnt[3]|r_lay_cnt[2])&(bf_cnt[1])|(r_lay_cnt[0])&bf_cnt[0];
					rd_data_add[2] <= (r_lay_cnt[6]|r_lay_cnt[5]|r_lay_cnt[4]|r_lay_cnt[3])&(bf_cnt[2])|(r_lay_cnt[1]|r_lay_cnt[0])&bf_cnt[1];
					rd_data_add[3] <= (r_lay_cnt[6]|r_lay_cnt[5]|r_lay_cnt[4])&(bf_cnt[3])|(r_lay_cnt[2]|r_lay_cnt[1]|r_lay_cnt[0])&bf_cnt[2];
					rd_data_add[4] <= (r_lay_cnt[6]|r_lay_cnt[5])&(bf_cnt[4])|(r_lay_cnt[3]|r_lay_cnt[2]|r_lay_cnt[1]|r_lay_cnt[0])&bf_cnt[3];
					rd_data_add[5] <= (r_lay_cnt[6])&(bf_cnt[5])|(r_lay_cnt[4]|r_lay_cnt[3]|r_lay_cnt[2]|r_lay_cnt[1]|r_lay_cnt[0])&bf_cnt[4];
					rd_data_add[6] <= (r_lay_cnt[5]|r_lay_cnt[4]|r_lay_cnt[3]|r_lay_cnt[2]|r_lay_cnt[1]|r_lay_cnt[0])&bf_cnt[5];
					
					/*每次蝶形变换的 旋转因子的地址*/
					rom_wn <={r_lay_cnt[6],r_lay_cnt[6],r_lay_cnt[6],r_lay_cnt[6],r_lay_cnt[6],r_lay_cnt[6]}&{bf_cnt[5],bf_cnt[4],bf_cnt[3],bf_cnt[2],bf_cnt[1],bf_cnt[0]}|
								{r_lay_cnt[5],r_lay_cnt[5],r_lay_cnt[5],r_lay_cnt[5],r_lay_cnt[5],r_lay_cnt[5]}&{bf_cnt[4],bf_cnt[3],bf_cnt[2],bf_cnt[1],bf_cnt[0],1'b0}|
								{r_lay_cnt[4],r_lay_cnt[4],r_lay_cnt[4],r_lay_cnt[4],r_lay_cnt[4],r_lay_cnt[4]}&{bf_cnt[3],bf_cnt[2],bf_cnt[1],bf_cnt[0],1'b0,1'b0}|
								{r_lay_cnt[3],r_lay_cnt[3],r_lay_cnt[3],r_lay_cnt[3],r_lay_cnt[3],r_lay_cnt[3]}&{bf_cnt[2],bf_cnt[1],bf_cnt[0],1'b0,1'b0,1'b0}|
								{r_lay_cnt[2],r_lay_cnt[2],r_lay_cnt[2],r_lay_cnt[2],r_lay_cnt[2],r_lay_cnt[2]}&{bf_cnt[1],bf_cnt[0],1'b0,1'b0,1'b0,1'b0}|
								{r_lay_cnt[1],r_lay_cnt[1],r_lay_cnt[1],r_lay_cnt[1],r_lay_cnt[1],r_lay_cnt[1]}&{bf_cnt[0],1'b0,1'b0,1'b0,1'b0,1'b0}|
								{r_lay_cnt[0],r_lay_cnt[0],r_lay_cnt[0],r_lay_cnt[0],r_lay_cnt[0],r_lay_cnt[0]}&{1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};					
				end
				
				1:begin
					bf_go <= 1'd0;
					ram_add_prv <= rd_data_add;
					rd_data_add <= rd_data_add + bstep; //蝶形变换第二组数据输入
				end
				
				8:begin
					r_wren <= 1'd1;
					rd_data_add <= ram_add_prv; //原位数据写入
				end
	
				9:begin
					rd_data_add <= rd_data_add + bstep;
				end
				
				default:;
				
			
			endcase	
		
		FFTOUT:begin
			rd_data_add <= ot_cnt;
		
		end
		
		
		default:begin
			r_wren <= 1'b0;
			
		
		end
		
	endcase

//	/*读取数据 计数器 */
//	always@(posedge clk or negedge rst_n )
//	if(!rst_n)
//		rd_cnt <= 1'b0;
//	else if(current_state == RADDAT)
//		rd_cnt <= rd_cnt + 1'd1;
		
	/*将外部数据读取到RAM*/
	always@(posedge clk or negedge rst_n )
	if(!rst_n)
		rd_cnt <= 1'b0;
	else if(current_state == RADDAT)
		rd_cnt <= rd_cnt + 1'd1;
	
	/*将RAM数据输出计数器*/
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		ot_cnt <= 7'd0;
	else if(current_state == FFTOUT)
		ot_cnt <= ot_cnt + 1'b1;
	else
		ot_cnt <= 7'd0;
								
	/*数据运算结束指示*/				
	always@(posedge clk or negedge rst_n )
	if(!rst_n)
		fft_done <= 1'b0;
	else if(current_state == FFTOUT)
		fft_done <= 1'd1;
	else
		fft_done <= 1'b0;
	
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
						if(rd_cnt == 7'b111_1111)
							next_state <= FFTCLC;
				end
		FFTCLC:begin
						if((lay_cnt == 4'd7) &(bf_cnt == 7'b100_0000 ))
							next_state <= FFTOUT;


				end
				
		FFTOUT:begin
					if(ot_cnt == 7'b111_1110)
						next_state <= IDEL;
				end
				
		endcase
		
		
		
	butterfly_ra2_seri bfcalc(
		.rst_n(rst_n),
		.clk(clk),
		.bf_go(bf_go),
		.bf_done(bf_done), //两组数据 持续一个时钟周期	
		.datax(ram_out[15:8]), //高位存储实部
		.datay(ram_out[7:0]),	//地位存储虚部
		.wx(w_wnp[15:8]),//第一个时钟周期读取旋转因子
		.wy(w_wnp[7:0]),
//		.wx(8'd120),//第一个时钟周期读取旋转因子
//		.wy(8'd35),
		.wren(),//写数据使能
		.bfx(bf_data_out[15:8]),
		.bfy(bf_data_out[7:0]));
		
	/*RAM  数据多路选择器*/
	
//	always@(*)begin
//		case(current_state)
//			FFTOUT:
//				ram_data_in = {data1,8'd0};
//			FFTCLC:
//				ram_data_in = bf_data_out;
//		endcase
//	end
	assign fft_res = (current_state == FFTOUT)?ram_out:16'd0;
	
//	assign ram_data_in = (current_state == FFTCLC)?bf_data_out:{data1,8'd0};
	assign ram_data_in = (current_state == FFTCLC)?bf_data_out:{(rd_cnt - 1'd1),8'd0};//测试使用
endmodule



























