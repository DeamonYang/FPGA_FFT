module address_gererate_tb;

	reg[6:0]rd_data_add;
	reg[6:0]r_lay_cnt;
	reg[5:0]bf_cnt;
	reg[2:0]lay_cnt;
	reg[5:0]rom_wn;
	reg clk;
	
	initial clk = 0;
	always #20 clk = ~clk;
	
	initial begin 
		r_lay_cnt = 1;
		forever begin
			#2560;
			r_lay_cnt = 6'd1 << lay_cnt + 1;
		end
	end
	
	
	initial begin
		lay_cnt = 0;
		forever begin
		
			#2560;
				lay_cnt = lay_cnt + 1;
			
			end
	end
	
	
	

	initial bf_cnt = 0;
	always #40 bf_cnt = bf_cnt + 1;
	
	
	initial begin
		#40000;
		$stop;
	
	end
	
	initial 
		forever begin
			
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
			
			#40;
		end

endmodule































