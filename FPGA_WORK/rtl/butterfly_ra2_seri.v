 //将并行读写数据的蝶形变换转化为串行读写
 module butterfly_ra2_seri
 (
	rst_n,
	clk,
	bf_go,
	bf_done, //两组数据 持续一个时钟周期
	
	datax,
	datay,
	
	wx,//第一个时钟周期读取旋转因子
	wy,
	
	wren,//写数据使能
	bfx,
	bfy
 );

 
 	input rst_n;
	input clk;
	input bf_go;
	output reg bf_done;
	
	input[7:0]datax;
	input[7:0]datay;
	
	input[7:0]wx;//第一个时钟周期读取旋转因子
	input[7:0]wy;

	output reg[7:0]bfx;
	output reg[7:0]bfy;
	output reg wren;
//	output reg num;//读取第一个数为低读取第二个为高电平
	
	reg signed[7:0]r_wx;
	reg signed[7:0]r_wy;
	reg signed[7:0]x1;
	reg signed[7:0]y1;
	reg signed[7:0]x2;
	reg signed[7:0]y2;
	wire signed[8:0]bfx1;
	wire signed[8:0]bfy1;
	wire signed[8:0]bfx2;
	wire signed[8:0]bfy2;
	wire bbf_done;

//	reg signed[8:0]r_bfx1;
//	reg signed[8:0]r_bfy1;
//	reg signed[8:0]r_bfx2;
//	reg signed[8:0]r_bfy2;	
	
	reg r_bbf_go;
	
	
	reg[3:0]cnt;
	reg cnt_en;
	
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt_en <= 1'd0;
	else if(bf_go)
		cnt_en <= 1'b1;
	else if(cnt >= 4'd7)
		cnt_en <= 1'd0;
	
	
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt <= 'd0;
	else if(cnt_en)
		cnt <= cnt + 1'b1;
	else
		cnt <= 'd0;
		
	always@(posedge clk or negedge rst_n)
	if(!rst_n)begin
		r_bbf_go <= 1'b0;
		bf_done <= 1'b0;
		bfx <= 8'd0;
	   bfy <= 8'd0;
		wren <= 1'b0;
	end
	else //if(cnt_en)
		case(cnt)
			0:begin
				x1 <= datax;
				y1 <= datay;
				r_wx <= wx;
				r_wy <= wy;
				wren <= 1'b00;
				bf_done <= 1'b0;
			end
			
			1:begin
				x2 <= datax;
				y2 <= datay;
				r_bbf_go <= 1'd1;				
			end
			//开始计算
			2:begin
				r_bbf_go <= 1'd0;
			end
 
			
			
			6:begin
					
				bfx <= bfx1[8:1];
				bfy <= bfy1[8:1];
				wren <= 1'b1;
			end
			7:begin
				bfx <= bfx2[8:1];
				bfy <= bfy2[8:1];			
				wren <= 1'b1;
				bf_done <= 1'b1;
			end
			
			8:begin
				wren <= 1'b00;
				bf_done <= 1'b0;
			end
			
			default:;

		endcase
		
 
	butterfly_ra2 bflab1(
		.rst_n(rst_n),
		.clk(clk),
		.bf_go(r_bbf_go),
		.bf_done(bbf_done),
		.wx(r_wx),
		.wy(r_wy),
		.x1(x1),
		.y1(y1),
		.x2(x2),
		.y2(y2),
		.bfx1(bfx1),
		.bfy1(bfy1),
		.bfx2(bfx2),
		.bfy2(bfy2)
	 );

 
 endmodule
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 