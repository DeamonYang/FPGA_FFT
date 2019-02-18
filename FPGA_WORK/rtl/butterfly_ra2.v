 //基2 蝶形变换
 module butterfly_ra2
 (
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
 
	input rst_n;
	input clk;
	input bf_go;
	output reg bf_done;
	input signed[7:0]wx;
	input signed[7:0]wy;
	input signed[7:0]x1;
	input signed[7:0]y1;
	input signed[7:0]x2;
	input signed[7:0]y2;
	output reg signed[8:0]bfx1;
	output reg signed[8:0]bfy1;
	output reg signed[8:0]bfx2;
	output reg signed[8:0]bfy2;
	reg [1:0]cnt;
	reg clc_en;
	reg signed [15:0]a;
	reg signed [15:0]b;
	reg signed [15:0]c;
	reg signed [15:0]d;

	reg signed[7:0]r_x1;
	reg signed[7:0]r_y1;

	
	reg signed[15:0]rel;
	reg signed[15:0]img;
	
	
	/*计算使能*/
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		clc_en <= 1'd0;
	else if(bf_go)
		clc_en <= 1'd1;
	else if(cnt == 2'b11)
		clc_en <= 1'd0;
	
	/*寄存初始值防止计算过程中数据发生变化*/
	always@(posedge clk or negedge rst_n)
	if(!rst_n)begin

		r_x1 = 8'd0;
		r_y1 = 8'd0;

	end
	else if(bf_go)begin

		r_x1 <= x1;
		r_y1 <= y1;
		end
	
	
	/*分3步完成计算*/
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt <= 2'd0;
	else if(bf_go)
		cnt <= 2'd1;
	else if(clc_en)
		cnt <= cnt + 1'b1;
		
	always@(posedge clk or negedge rst_n)
	if(!rst_n)begin
		bfx1 <= 9'd0;
		bfy1 <= 9'd0;
	   bfx2 <= 9'd0;
      bfy2 <= 9'd0;
		rel <=15'd0;
		img <=15'd0;
	end else if(bf_go | clc_en )
		case(cnt)
			1: 
				begin 
					a <= x2*wx;
					b <= y2*wy;
					c <= y2*wx;
					d <= x2*wy;
				end
			2:
				begin
					rel <= (a - b);
					img <= (c + d);	
				end
			3:
				begin
					bfx1 <= {r_x1[7],r_x1} + {rel[15],rel[15:8]};
					bfy1 <= {r_y1[7],r_y1} + {img[15],img[15:8]};
					bfx2 <= {r_x1[7],r_x1} - {rel[15],rel[15:8]};
					bfy2 <= {r_y1[7],r_y1} - {img[15],img[15:8]};
				end
			default:;
				
		endcase
		
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		bf_done <= 1'b0;
	else if(cnt == 2'd3)
		bf_done <= 1'b1;
	else
		bf_done <= 1'b0;
		
		
 
 endmodule
 
 

 
 
 
 
 