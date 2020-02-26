module Cube_Snak_Top(

	input		sys_clk ,
	input		sys_rst_n ,
	input  [5:0] key ,
	output  [35:0] rgb_led	
);

reg [23:0] state_rgb_led [5:0] [5:0] [5:0] ;  //灯带的状态

reg [2:0] x_aim_snak ;
reg [2:0] y_aim_snak ;
reg [2:0] z_aim_snak ;

reg snak_state [5:0] [5:0] [5:0] ;  //判断每个点是否为蛇身

reg [7:0] snak_body [255:0]   ;//蛇身数据

reg [7:0] seat_header_snak ; //蛇头代号
reg [7:0] seat_tail_snak ; //蛇尾代号

wire [7:0] now_header   ;  //蛇头
wire [7:0] now_tail  ; //蛇尾
assign now_header = snak_body[seat_header_snak] ;
assign now_tail = snak_body[seat_tail_snak] ;

wire [2:0] x_now_header , y_now_header , z_now_header ;
assign  x_now_header = now_header / 6'd36 ;
assign  y_now_header = (now_header -  x_now_header * 6'd36 ) / 3'd6 ;
assign  z_now_header = now_header - x_now_header * 6'd36 - y_now_header * 3'd6 ;

wire [2:0] x_now_tail , y_now_tail ,z_now_tail ;
assign  x_now_tail = now_tail / 6'd36 ;
assign  y_now_tail = (now_tail -  x_now_tail * 6'd36 ) / 5'd6 ;
assign  z_now_tail = now_tail - x_now_tail * 6'd36 - y_now_tail * 3'd6 ;

reg [2:0] x_next_header , y_next_header , z_next_header ;
wire [7:0] next_header  ;  //下个蛇头
assign	next_header = x_next_header * 6'd36 + y_next_header * 3'd6 + z_next_header ;

parameter  	green 	 	=   24'h000088 	; //
parameter  	bule  	 	= 	24'h880000 	; //开场特性颜色
parameter  	red      	=   24'h008800 	; //		
parameter  	purple      =   24'h888800 	; //开场特性颜色
parameter  	yellow      =   24'h008888 	; //
parameter  	baby_bule   =   24'h880088 	; //开场特性颜色	
parameter	white    	=   24'h888888 	;
parameter	nocolor  	= 	24'h000000 	;
		
reg	[26:0] counter_2hz  ;

always @(posedge sys_clk or negedge sys_rst_n) begin   //counter_2hz定时
    if (!sys_rst_n)  begin
        counter_2hz <= 27'd0;  end
    else if (counter_2hz < 27'd50_000_000)
        counter_2hz <= counter_2hz + 1'b1;
    else
        counter_2hz <= 27'd0;
end

reg [3:0]  flag_rgb_change_state ; //状态变量字
reg [3:0]  begin_show_time ;  //开场秀
reg [3:0]  which_derection_rogo ;

reg [2:0] fangxaing ;
wire [5:0] flag ;  //key
wire [5:0] value ;  //key

always @(posedge sys_clk or negedge sys_rst_n) begin  //方向控制
	if (!sys_rst_n)  begin
		x_next_header <= 3'd0 ;
		y_next_header <= 3'd1 ;
		z_next_header <= 3'd0 ;
		fangxaing <= 3'd0 ;
	end
	else begin
		if(value[0] && (~flag[0]))  //判断按键是否有效按下
			if(fangxaing!=2)    //下
			fangxaing <= 3'd0;  //上
			else fangxaing <= fangxaing ;
		else if(value[1] && (~flag[1]))  //判断按键是否有效按下
			if(fangxaing!=3)   //右
			fangxaing <= 3'd1;  //左
			else fangxaing <= fangxaing ;
		else if(value[2] && (~flag[2]))  //判断按键是否有效按下
		if(fangxaing!=0) //上
			fangxaing <= 3'd2; //下
			else fangxaing <= fangxaing ;
		else if(value[3] && (~flag[3]))  //判断按键是否有效按下
			if(fangxaing!=1)  //左
			fangxaing <= 3'd3; //右
			else fangxaing <= fangxaing ;
		else if(value[4] && (~flag[4]))  //判断按键是否有效按下
			if(fangxaing!=5)  //前
			fangxaing <= 3'd4; //后
			else fangxaing <= fangxaing ;
		else if(value[5] && (~flag[5]))  //判断按键是否有效按下
			if(fangxaing!=4) //后
			fangxaing <= 3'd5; //前
			else fangxaing <= fangxaing ;
		else fangxaing <= fangxaing ;
		
		if (fangxaing== 0)  begin  //上
			x_next_header <= x_now_header ;
			y_next_header <= y_now_header ;
			if(z_now_header==3'd5)
				z_next_header <= 3'd0 ;
			else z_next_header <= z_now_header + 1'd1 ;		
		end
		
		else if (fangxaing == 1)  begin //左
			if(x_now_header==3'd0)
				x_next_header <= 3'd5 ;
			else x_next_header <= x_now_header - 1'd1;		
			y_next_header <= y_now_header ;
			z_next_header <= z_now_header ;
		end
		
		else if (fangxaing == 2)  begin //下
			x_next_header <= x_now_header ;
			y_next_header <= y_now_header ;
			if(z_now_header==3'd0)
				z_next_header <= 3'd5 ;
			else z_next_header <= z_now_header - 1'd1;	
		end
		
		else if (fangxaing == 3)  begin  //右
			if(x_now_header==3'd5)
				x_next_header <= 3'd0 ;
			else x_next_header <= x_now_header + 1'd1;	
			y_next_header <= y_now_header ;
			z_next_header <= z_now_header ;
		end
		
		else if (fangxaing == 4)  begin //后
			x_next_header <= x_now_header ;
			if(y_now_header==3'd5)
				y_next_header <= 3'd0 ;
			else y_next_header <= y_now_header + 1'd1;	
			z_next_header <= z_now_header ;
		end
		
		else begin //前
			x_next_header <= x_now_header ;
			if(y_now_header==3'd0)
				y_next_header <= 3'd5 ;
			else y_next_header <= y_now_header - 1'd1;	
			z_next_header <= z_now_header ;
		end		
	end
end


always @(posedge sys_clk or negedge sys_rst_n) begin  //状态字控制
	if (!sys_rst_n)  begin
		flag_rgb_change_state <= 4'd0 ;
		begin_show_time <= 4'd5 ;
	end
	else if (begin_show_time > 0) begin	 //开始阶段操作	
		if(begin_show_time == 4'd4)
			flag_rgb_change_state = 4'd1 ; // 1 -> 2 			
		else if (begin_show_time == 4'd3)
			flag_rgb_change_state = 4'd2 ; // 2 -> 3
		else if (begin_show_time == 4'd2) 
			flag_rgb_change_state = 4'd3 ; // 3 -> 4
		else flag_rgb_change_state = 4'd4 ;
		if(counter_2hz == 27'd49_999_980) 
			begin_show_time = begin_show_time - 1'd1 ;
		else begin_show_time = begin_show_time ;				
	end
	
	else begin  //运动阶操作
		if( (counter_2hz == 27'd00_000_010) &&  (flag_rgb_change_state == 4'd4) )
			flag_rgb_change_state <= 4'd5 ;
		else  begin
			if( snak_state[x_next_header][y_next_header][z_next_header] == 1'd1 ) begin
				if( (x_next_header == x_aim_snak)&&(y_next_header == y_aim_snak)&&(z_next_header == z_aim_snak) )
					flag_rgb_change_state <= 4'd6  ; //吃目标
				else 
					flag_rgb_change_state <= 4'd7 ; //吃尾巴
			end			
			else
				flag_rgb_change_state <= 4'd5 ;	//走空位	
		end		
	end			
end

always @(posedge sys_clk or negedge sys_rst_n) begin  //灯状态控制
	if (!sys_rst_n)  begin
		seat_tail_snak = 8'd0 ;
		seat_header_snak = 8'd0 ;
		x_aim_snak <= 3'd4 ;
		y_aim_snak <= 3'd3 ;
		z_aim_snak <= 3'd2 ;
		snak_state[0][0][0] <= 1'd0 ; 
 		snak_state[0][0][1] <= 1'd0 ; 
 		snak_state[0][0][2] <= 1'd0 ; 
 		snak_state[0][0][3] <= 1'd0 ; 
 		snak_state[0][0][4] <= 1'd0 ; 
 		snak_state[0][0][5] <= 1'd0 ; 
 		snak_state[0][1][0] <= 1'd0 ; 
 		snak_state[0][1][1] <= 1'd0 ; 
 		snak_state[0][1][2] <= 1'd0 ; 
 		snak_state[0][1][3] <= 1'd0 ; 
 		snak_state[0][1][4] <= 1'd0 ; 
 		snak_state[0][1][5] <= 1'd0 ; 
 		snak_state[0][2][0] <= 1'd0 ; 
 		snak_state[0][2][1] <= 1'd0 ; 
 		snak_state[0][2][2] <= 1'd0 ; 
 		snak_state[0][2][3] <= 1'd0 ; 
 		snak_state[0][2][4] <= 1'd0 ; 
 		snak_state[0][2][5] <= 1'd0 ; 
 		snak_state[0][3][0] <= 1'd0 ; 
 		snak_state[0][3][1] <= 1'd0 ; 
 		snak_state[0][3][2] <= 1'd0 ; 
 		snak_state[0][3][3] <= 1'd0 ; 
 		snak_state[0][3][4] <= 1'd0 ; 
 		snak_state[0][3][5] <= 1'd0 ; 
 		snak_state[0][4][0] <= 1'd0 ; 
 		snak_state[0][4][1] <= 1'd0 ; 
 		snak_state[0][4][2] <= 1'd0 ; 
 		snak_state[0][4][3] <= 1'd0 ; 
 		snak_state[0][4][4] <= 1'd0 ; 
 		snak_state[0][4][5] <= 1'd0 ; 
 		snak_state[0][5][0] <= 1'd0 ; 
 		snak_state[0][5][1] <= 1'd0 ; 
 		snak_state[0][5][2] <= 1'd0 ; 
 		snak_state[0][5][3] <= 1'd0 ; 
 		snak_state[0][5][4] <= 1'd0 ; 
 		snak_state[0][5][5] <= 1'd0 ; 
 		snak_state[1][0][0] <= 1'd0 ; 
 		snak_state[1][0][1] <= 1'd0 ; 
 		snak_state[1][0][2] <= 1'd0 ; 
 		snak_state[1][0][3] <= 1'd0 ; 
 		snak_state[1][0][4] <= 1'd0 ; 
 		snak_state[1][0][5] <= 1'd0 ; 
 		snak_state[1][1][0] <= 1'd0 ; 
 		snak_state[1][1][1] <= 1'd0 ; 
 		snak_state[1][1][2] <= 1'd0 ; 
 		snak_state[1][1][3] <= 1'd0 ; 
 		snak_state[1][1][4] <= 1'd0 ; 
 		snak_state[1][1][5] <= 1'd0 ; 
 		snak_state[1][2][0] <= 1'd0 ; 
 		snak_state[1][2][1] <= 1'd0 ; 
 		snak_state[1][2][2] <= 1'd0 ; 
 		snak_state[1][2][3] <= 1'd0 ; 
 		snak_state[1][2][4] <= 1'd0 ; 
 		snak_state[1][2][5] <= 1'd0 ; 
 		snak_state[1][3][0] <= 1'd0 ; 
 		snak_state[1][3][1] <= 1'd0 ; 
 		snak_state[1][3][2] <= 1'd0 ; 
 		snak_state[1][3][3] <= 1'd0 ; 
 		snak_state[1][3][4] <= 1'd0 ; 
 		snak_state[1][3][5] <= 1'd0 ; 
 		snak_state[1][4][0] <= 1'd0 ; 
 		snak_state[1][4][1] <= 1'd0 ; 
 		snak_state[1][4][2] <= 1'd0 ; 
 		snak_state[1][4][3] <= 1'd0 ; 
 		snak_state[1][4][4] <= 1'd0 ; 
 		snak_state[1][4][5] <= 1'd0 ; 
 		snak_state[1][5][0] <= 1'd0 ; 
 		snak_state[1][5][1] <= 1'd0 ; 
 		snak_state[1][5][2] <= 1'd0 ; 
 		snak_state[1][5][3] <= 1'd0 ; 
 		snak_state[1][5][4] <= 1'd0 ; 
 		snak_state[1][5][5] <= 1'd0 ; 
 		snak_state[2][0][0] <= 1'd0 ; 
 		snak_state[2][0][1] <= 1'd0 ; 
 		snak_state[2][0][2] <= 1'd0 ; 
 		snak_state[2][0][3] <= 1'd0 ; 
 		snak_state[2][0][4] <= 1'd0 ; 
 		snak_state[2][0][5] <= 1'd0 ; 
 		snak_state[2][1][0] <= 1'd0 ; 
 		snak_state[2][1][1] <= 1'd0 ; 
 		snak_state[2][1][2] <= 1'd0 ; 
 		snak_state[2][1][3] <= 1'd0 ; 
 		snak_state[2][1][4] <= 1'd0 ; 
 		snak_state[2][1][5] <= 1'd0 ; 
 		snak_state[2][2][0] <= 1'd0 ; 
 		snak_state[2][2][1] <= 1'd0 ; 
 		snak_state[2][2][2] <= 1'd0 ; 
 		snak_state[2][2][3] <= 1'd0 ; 
 		snak_state[2][2][4] <= 1'd0 ; 
 		snak_state[2][2][5] <= 1'd0 ; 
 		snak_state[2][3][0] <= 1'd0 ; 
 		snak_state[2][3][1] <= 1'd0 ; 
 		snak_state[2][3][2] <= 1'd0 ; 
 		snak_state[2][3][3] <= 1'd0 ; 
 		snak_state[2][3][4] <= 1'd0 ; 
 		snak_state[2][3][5] <= 1'd0 ; 
 		snak_state[2][4][0] <= 1'd0 ; 
 		snak_state[2][4][1] <= 1'd0 ; 
 		snak_state[2][4][2] <= 1'd0 ; 
 		snak_state[2][4][3] <= 1'd0 ; 
 		snak_state[2][4][4] <= 1'd0 ; 
 		snak_state[2][4][5] <= 1'd0 ; 
 		snak_state[2][5][0] <= 1'd0 ; 
 		snak_state[2][5][1] <= 1'd0 ; 
 		snak_state[2][5][2] <= 1'd0 ; 
 		snak_state[2][5][3] <= 1'd0 ; 
 		snak_state[2][5][4] <= 1'd0 ; 
 		snak_state[2][5][5] <= 1'd0 ; 
 		snak_state[3][0][0] <= 1'd0 ; 
 		snak_state[3][0][1] <= 1'd0 ; 
 		snak_state[3][0][2] <= 1'd0 ; 
 		snak_state[3][0][3] <= 1'd0 ; 
 		snak_state[3][0][4] <= 1'd0 ; 
 		snak_state[3][0][5] <= 1'd0 ; 
 		snak_state[3][1][0] <= 1'd0 ; 
 		snak_state[3][1][1] <= 1'd0 ; 
 		snak_state[3][1][2] <= 1'd0 ; 
 		snak_state[3][1][3] <= 1'd0 ; 
 		snak_state[3][1][4] <= 1'd0 ; 
 		snak_state[3][1][5] <= 1'd0 ; 
 		snak_state[3][2][0] <= 1'd0 ; 
 		snak_state[3][2][1] <= 1'd0 ; 
 		snak_state[3][2][2] <= 1'd0 ; 
 		snak_state[3][2][3] <= 1'd0 ; 
 		snak_state[3][2][4] <= 1'd0 ; 
 		snak_state[3][2][5] <= 1'd0 ; 
 		snak_state[3][3][0] <= 1'd0 ; 
 		snak_state[3][3][1] <= 1'd0 ; 
 		snak_state[3][3][2] <= 1'd0 ; 
 		snak_state[3][3][3] <= 1'd0 ; 
 		snak_state[3][3][4] <= 1'd0 ; 
 		snak_state[3][3][5] <= 1'd0 ; 
 		snak_state[3][4][0] <= 1'd0 ; 
 		snak_state[3][4][1] <= 1'd0 ; 
 		snak_state[3][4][2] <= 1'd0 ; 
 		snak_state[3][4][3] <= 1'd0 ; 
 		snak_state[3][4][4] <= 1'd0 ; 
 		snak_state[3][4][5] <= 1'd0 ; 
 		snak_state[3][5][0] <= 1'd0 ; 
 		snak_state[3][5][1] <= 1'd0 ; 
 		snak_state[3][5][2] <= 1'd0 ; 
 		snak_state[3][5][3] <= 1'd0 ; 
 		snak_state[3][5][4] <= 1'd0 ; 
 		snak_state[3][5][5] <= 1'd0 ; 
 		snak_state[4][0][0] <= 1'd0 ; 
 		snak_state[4][0][1] <= 1'd0 ; 
 		snak_state[4][0][2] <= 1'd0 ; 
 		snak_state[4][0][3] <= 1'd0 ; 
 		snak_state[4][0][4] <= 1'd0 ; 
 		snak_state[4][0][5] <= 1'd0 ; 
 		snak_state[4][1][0] <= 1'd0 ; 
 		snak_state[4][1][1] <= 1'd0 ; 
 		snak_state[4][1][2] <= 1'd0 ; 
 		snak_state[4][1][3] <= 1'd0 ; 
 		snak_state[4][1][4] <= 1'd0 ; 
 		snak_state[4][1][5] <= 1'd0 ; 
 		snak_state[4][2][0] <= 1'd0 ; 
 		snak_state[4][2][1] <= 1'd0 ; 
 		snak_state[4][2][2] <= 1'd0 ; 
 		snak_state[4][2][3] <= 1'd0 ; 
 		snak_state[4][2][4] <= 1'd0 ; 
 		snak_state[4][2][5] <= 1'd0 ; 
 		snak_state[4][3][0] <= 1'd0 ; 
 		snak_state[4][3][1] <= 1'd0 ; 
 		snak_state[4][3][2] <= 1'd0 ; 
 		snak_state[4][3][3] <= 1'd0 ; 
 		snak_state[4][3][4] <= 1'd0 ; 
 		snak_state[4][3][5] <= 1'd0 ; 
 		snak_state[4][4][0] <= 1'd0 ; 
 		snak_state[4][4][1] <= 1'd0 ; 
 		snak_state[4][4][2] <= 1'd0 ; 
 		snak_state[4][4][3] <= 1'd0 ; 
 		snak_state[4][4][4] <= 1'd0 ; 
 		snak_state[4][4][5] <= 1'd0 ; 
 		snak_state[4][5][0] <= 1'd0 ; 
 		snak_state[4][5][1] <= 1'd0 ; 
 		snak_state[4][5][2] <= 1'd0 ; 
 		snak_state[4][5][3] <= 1'd0 ; 
 		snak_state[4][5][4] <= 1'd0 ; 
 		snak_state[4][5][5] <= 1'd0 ; 
 		snak_state[5][0][0] <= 1'd0 ; 
 		snak_state[5][0][1] <= 1'd0 ; 
 		snak_state[5][0][2] <= 1'd0 ; 
 		snak_state[5][0][3] <= 1'd0 ; 
 		snak_state[5][0][4] <= 1'd0 ; 
 		snak_state[5][0][5] <= 1'd0 ; 
 		snak_state[5][1][0] <= 1'd0 ; 
 		snak_state[5][1][1] <= 1'd0 ; 
 		snak_state[5][1][2] <= 1'd0 ; 
 		snak_state[5][1][3] <= 1'd0 ; 
 		snak_state[5][1][4] <= 1'd0 ; 
 		snak_state[5][1][5] <= 1'd0 ; 
 		snak_state[5][2][0] <= 1'd0 ; 
 		snak_state[5][2][1] <= 1'd0 ; 
 		snak_state[5][2][2] <= 1'd0 ; 
 		snak_state[5][2][3] <= 1'd0 ; 
 		snak_state[5][2][4] <= 1'd0 ; 
 		snak_state[5][2][5] <= 1'd0 ; 
 		snak_state[5][3][0] <= 1'd0 ; 
 		snak_state[5][3][1] <= 1'd0 ; 
 		snak_state[5][3][2] <= 1'd0 ; 
 		snak_state[5][3][3] <= 1'd0 ; 
 		snak_state[5][3][4] <= 1'd0 ; 
 		snak_state[5][3][5] <= 1'd0 ; 
 		snak_state[5][4][0] <= 1'd0 ; 
 		snak_state[5][4][1] <= 1'd0 ; 
 		snak_state[5][4][2] <= 1'd0 ; 
 		snak_state[5][4][3] <= 1'd0 ; 
 		snak_state[5][4][4] <= 1'd0 ; 
 		snak_state[5][4][5] <= 1'd0 ; 
 		snak_state[5][5][0] <= 1'd0 ; 
 		snak_state[5][5][1] <= 1'd0 ; 
 		snak_state[5][5][2] <= 1'd0 ; 
 		snak_state[5][5][3] <= 1'd0 ; 
 		snak_state[5][5][4] <= 1'd0 ; 
 		snak_state[5][5][5] <= 1'd0 ; 
		state_rgb_led[0][0][0] <= nocolor ; 
 		state_rgb_led[0][0][1] <= nocolor ; 
 		state_rgb_led[0][0][2] <= nocolor ; 
 		state_rgb_led[0][0][3] <= nocolor ; 
 		state_rgb_led[0][0][4] <= nocolor ; 
 		state_rgb_led[0][0][5] <= nocolor ; 
 		state_rgb_led[0][1][0] <= nocolor ; 
 		state_rgb_led[0][1][1] <= nocolor ; 
 		state_rgb_led[0][1][2] <= nocolor ; 
 		state_rgb_led[0][1][3] <= nocolor ; 
 		state_rgb_led[0][1][4] <= nocolor ; 
 		state_rgb_led[0][1][5] <= nocolor ; 
 		state_rgb_led[0][2][0] <= nocolor ; 
 		state_rgb_led[0][2][1] <= nocolor ; 
 		state_rgb_led[0][2][2] <= nocolor ; 
 		state_rgb_led[0][2][3] <= nocolor ; 
 		state_rgb_led[0][2][4] <= nocolor ; 
 		state_rgb_led[0][2][5] <= nocolor ; 
 		state_rgb_led[0][3][0] <= nocolor ; 
 		state_rgb_led[0][3][1] <= nocolor ; 
 		state_rgb_led[0][3][2] <= nocolor ; 
 		state_rgb_led[0][3][3] <= nocolor ; 
 		state_rgb_led[0][3][4] <= nocolor ; 
 		state_rgb_led[0][3][5] <= nocolor ; 
 		state_rgb_led[0][4][0] <= nocolor ; 
 		state_rgb_led[0][4][1] <= nocolor ; 
 		state_rgb_led[0][4][2] <= nocolor ; 
 		state_rgb_led[0][4][3] <= nocolor ; 
 		state_rgb_led[0][4][4] <= nocolor ; 
 		state_rgb_led[0][4][5] <= nocolor ; 
 		state_rgb_led[0][5][0] <= nocolor ; 
 		state_rgb_led[0][5][1] <= nocolor ; 
 		state_rgb_led[0][5][2] <= nocolor ; 
 		state_rgb_led[0][5][3] <= nocolor ; 
 		state_rgb_led[0][5][4] <= nocolor ; 
 		state_rgb_led[0][5][5] <= nocolor ; 
 		state_rgb_led[1][0][0] <= nocolor ; 
 		state_rgb_led[1][0][1] <= nocolor ; 
 		state_rgb_led[1][0][2] <= nocolor ; 
 		state_rgb_led[1][0][3] <= nocolor ; 
 		state_rgb_led[1][0][4] <= nocolor ; 
 		state_rgb_led[1][0][5] <= nocolor ; 
 		state_rgb_led[1][1][0] <= nocolor ; 
 		state_rgb_led[1][1][1] <= nocolor ; 
 		state_rgb_led[1][1][2] <= nocolor ; 
 		state_rgb_led[1][1][3] <= nocolor ; 
 		state_rgb_led[1][1][4] <= nocolor ; 
 		state_rgb_led[1][1][5] <= nocolor ; 
 		state_rgb_led[1][2][0] <= nocolor ; 
 		state_rgb_led[1][2][1] <= nocolor ; 
 		state_rgb_led[1][2][2] <= nocolor ; 
 		state_rgb_led[1][2][3] <= nocolor ; 
 		state_rgb_led[1][2][4] <= nocolor ; 
 		state_rgb_led[1][2][5] <= nocolor ; 
 		state_rgb_led[1][3][0] <= nocolor ; 
 		state_rgb_led[1][3][1] <= nocolor ; 
 		state_rgb_led[1][3][2] <= nocolor ; 
 		state_rgb_led[1][3][3] <= nocolor ; 
 		state_rgb_led[1][3][4] <= nocolor ; 
 		state_rgb_led[1][3][5] <= nocolor ; 
 		state_rgb_led[1][4][0] <= nocolor ; 
 		state_rgb_led[1][4][1] <= nocolor ; 
 		state_rgb_led[1][4][2] <= nocolor ; 
 		state_rgb_led[1][4][3] <= nocolor ; 
 		state_rgb_led[1][4][4] <= nocolor ; 
 		state_rgb_led[1][4][5] <= nocolor ; 
 		state_rgb_led[1][5][0] <= nocolor ; 
 		state_rgb_led[1][5][1] <= nocolor ; 
 		state_rgb_led[1][5][2] <= nocolor ; 
 		state_rgb_led[1][5][3] <= nocolor ; 
 		state_rgb_led[1][5][4] <= nocolor ; 
 		state_rgb_led[1][5][5] <= nocolor ; 
 		state_rgb_led[2][0][0] <= nocolor ; 
 		state_rgb_led[2][0][1] <= nocolor ; 
 		state_rgb_led[2][0][2] <= nocolor ; 
 		state_rgb_led[2][0][3] <= nocolor ; 
 		state_rgb_led[2][0][4] <= nocolor ; 
 		state_rgb_led[2][0][5] <= nocolor ; 
 		state_rgb_led[2][1][0] <= nocolor ; 
 		state_rgb_led[2][1][1] <= nocolor ; 
 		state_rgb_led[2][1][2] <= nocolor ; 
 		state_rgb_led[2][1][3] <= nocolor ; 
 		state_rgb_led[2][1][4] <= nocolor ; 
 		state_rgb_led[2][1][5] <= nocolor ; 
 		state_rgb_led[2][2][0] <= nocolor ; 
 		state_rgb_led[2][2][1] <= nocolor ; 
 		state_rgb_led[2][2][2] <= nocolor ; 
 		state_rgb_led[2][2][3] <= nocolor ; 
 		state_rgb_led[2][2][4] <= nocolor ; 
 		state_rgb_led[2][2][5] <= nocolor ; 
 		state_rgb_led[2][3][0] <= nocolor ; 
 		state_rgb_led[2][3][1] <= nocolor ; 
 		state_rgb_led[2][3][2] <= nocolor ; 
 		state_rgb_led[2][3][3] <= nocolor ; 
 		state_rgb_led[2][3][4] <= nocolor ; 
 		state_rgb_led[2][3][5] <= nocolor ; 
 		state_rgb_led[2][4][0] <= nocolor ; 
 		state_rgb_led[2][4][1] <= nocolor ; 
 		state_rgb_led[2][4][2] <= nocolor ; 
 		state_rgb_led[2][4][3] <= nocolor ; 
 		state_rgb_led[2][4][4] <= nocolor ; 
 		state_rgb_led[2][4][5] <= nocolor ; 
 		state_rgb_led[2][5][0] <= nocolor ; 
 		state_rgb_led[2][5][1] <= nocolor ; 
 		state_rgb_led[2][5][2] <= nocolor ; 
 		state_rgb_led[2][5][3] <= nocolor ; 
 		state_rgb_led[2][5][4] <= nocolor ; 
 		state_rgb_led[2][5][5] <= nocolor ; 
 		state_rgb_led[3][0][0] <= nocolor ; 
 		state_rgb_led[3][0][1] <= nocolor ; 
 		state_rgb_led[3][0][2] <= nocolor ; 
 		state_rgb_led[3][0][3] <= nocolor ; 
 		state_rgb_led[3][0][4] <= nocolor ; 
 		state_rgb_led[3][0][5] <= nocolor ; 
 		state_rgb_led[3][1][0] <= nocolor ; 
 		state_rgb_led[3][1][1] <= nocolor ; 
 		state_rgb_led[3][1][2] <= nocolor ; 
 		state_rgb_led[3][1][3] <= nocolor ; 
 		state_rgb_led[3][1][4] <= nocolor ; 
 		state_rgb_led[3][1][5] <= nocolor ; 
 		state_rgb_led[3][2][0] <= nocolor ; 
 		state_rgb_led[3][2][1] <= nocolor ; 
 		state_rgb_led[3][2][2] <= nocolor ; 
 		state_rgb_led[3][2][3] <= nocolor ; 
 		state_rgb_led[3][2][4] <= nocolor ; 
 		state_rgb_led[3][2][5] <= nocolor ; 
 		state_rgb_led[3][3][0] <= nocolor ; 
 		state_rgb_led[3][3][1] <= nocolor ; 
 		state_rgb_led[3][3][2] <= nocolor ; 
 		state_rgb_led[3][3][3] <= nocolor ; 
 		state_rgb_led[3][3][4] <= nocolor ; 
 		state_rgb_led[3][3][5] <= nocolor ; 
 		state_rgb_led[3][4][0] <= nocolor ; 
 		state_rgb_led[3][4][1] <= nocolor ; 
 		state_rgb_led[3][4][2] <= nocolor ; 
 		state_rgb_led[3][4][3] <= nocolor ; 
 		state_rgb_led[3][4][4] <= nocolor ; 
 		state_rgb_led[3][4][5] <= nocolor ; 
 		state_rgb_led[3][5][0] <= nocolor ; 
 		state_rgb_led[3][5][1] <= nocolor ; 
 		state_rgb_led[3][5][2] <= nocolor ; 
 		state_rgb_led[3][5][3] <= nocolor ; 
 		state_rgb_led[3][5][4] <= nocolor ; 
 		state_rgb_led[3][5][5] <= nocolor ; 
 		state_rgb_led[4][0][0] <= nocolor ; 
 		state_rgb_led[4][0][1] <= nocolor ; 
 		state_rgb_led[4][0][2] <= nocolor ; 
 		state_rgb_led[4][0][3] <= nocolor ; 
 		state_rgb_led[4][0][4] <= nocolor ; 
 		state_rgb_led[4][0][5] <= nocolor ; 
 		state_rgb_led[4][1][0] <= nocolor ; 
 		state_rgb_led[4][1][1] <= nocolor ; 
 		state_rgb_led[4][1][2] <= nocolor ; 
 		state_rgb_led[4][1][3] <= nocolor ; 
 		state_rgb_led[4][1][4] <= nocolor ; 
 		state_rgb_led[4][1][5] <= nocolor ; 
 		state_rgb_led[4][2][0] <= nocolor ; 
 		state_rgb_led[4][2][1] <= nocolor ; 
 		state_rgb_led[4][2][2] <= nocolor ; 
 		state_rgb_led[4][2][3] <= nocolor ; 
 		state_rgb_led[4][2][4] <= nocolor ; 
 		state_rgb_led[4][2][5] <= nocolor ; 
 		state_rgb_led[4][3][0] <= nocolor ; 
 		state_rgb_led[4][3][1] <= nocolor ; 
 		state_rgb_led[4][3][2] <= nocolor ; 
 		state_rgb_led[4][3][3] <= nocolor ; 
 		state_rgb_led[4][3][4] <= nocolor ; 
 		state_rgb_led[4][3][5] <= nocolor ; 
 		state_rgb_led[4][4][0] <= nocolor ; 
 		state_rgb_led[4][4][1] <= nocolor ; 
 		state_rgb_led[4][4][2] <= nocolor ; 
 		state_rgb_led[4][4][3] <= nocolor ; 
 		state_rgb_led[4][4][4] <= nocolor ; 
 		state_rgb_led[4][4][5] <= nocolor ; 
 		state_rgb_led[4][5][0] <= nocolor ; 
 		state_rgb_led[4][5][1] <= nocolor ; 
 		state_rgb_led[4][5][2] <= nocolor ; 
 		state_rgb_led[4][5][3] <= nocolor ; 
 		state_rgb_led[4][5][4] <= nocolor ; 
 		state_rgb_led[4][5][5] <= nocolor ; 
 		state_rgb_led[5][0][0] <= nocolor ; 
 		state_rgb_led[5][0][1] <= nocolor ; 
 		state_rgb_led[5][0][2] <= nocolor ; 
 		state_rgb_led[5][0][3] <= nocolor ; 
 		state_rgb_led[5][0][4] <= nocolor ; 
 		state_rgb_led[5][0][5] <= nocolor ; 
 		state_rgb_led[5][1][0] <= nocolor ; 
 		state_rgb_led[5][1][1] <= nocolor ; 
 		state_rgb_led[5][1][2] <= nocolor ; 
 		state_rgb_led[5][1][3] <= nocolor ; 
 		state_rgb_led[5][1][4] <= nocolor ; 
 		state_rgb_led[5][1][5] <= nocolor ; 
 		state_rgb_led[5][2][0] <= nocolor ; 
 		state_rgb_led[5][2][1] <= nocolor ; 
 		state_rgb_led[5][2][2] <= nocolor ; 
 		state_rgb_led[5][2][3] <= nocolor ; 
 		state_rgb_led[5][2][4] <= nocolor ; 
 		state_rgb_led[5][2][5] <= nocolor ; 
 		state_rgb_led[5][3][0] <= nocolor ; 
 		state_rgb_led[5][3][1] <= nocolor ; 
 		state_rgb_led[5][3][2] <= nocolor ; 
 		state_rgb_led[5][3][3] <= nocolor ; 
 		state_rgb_led[5][3][4] <= nocolor ; 
 		state_rgb_led[5][3][5] <= nocolor ; 
 		state_rgb_led[5][4][0] <= nocolor ; 
 		state_rgb_led[5][4][1] <= nocolor ; 
 		state_rgb_led[5][4][2] <= nocolor ; 
 		state_rgb_led[5][4][3] <= nocolor ; 
 		state_rgb_led[5][4][4] <= nocolor ; 
 		state_rgb_led[5][4][5] <= nocolor ; 
 		state_rgb_led[5][5][0] <= nocolor ; 
 		state_rgb_led[5][5][1] <= nocolor ; 
 		state_rgb_led[5][5][2] <= nocolor ; 
 		state_rgb_led[5][5][3] <= nocolor ; 
 		state_rgb_led[5][5][4] <= nocolor ; 
 		state_rgb_led[5][5][5] <= nocolor ; 	
	end	
	
	else if(counter_2hz == 27'd50_000_000) begin
		case (flag_rgb_change_state)
			4'd1 : begin    //开始特效1
				state_rgb_led[0][0][0] <= yellow ; 
 				state_rgb_led[0][0][1] <= yellow ; 
 				state_rgb_led[0][0][2] <= yellow ; 
 				state_rgb_led[0][0][3] <= yellow ; 
 				state_rgb_led[0][0][4] <= yellow ; 
 				state_rgb_led[0][0][5] <= yellow ; 
 				state_rgb_led[0][1][0] <= yellow ; 
 				state_rgb_led[0][1][1] <= yellow ; 
 				state_rgb_led[0][1][2] <= yellow ; 
 				state_rgb_led[0][1][3] <= yellow ; 
 				state_rgb_led[0][1][4] <= yellow ; 
 				state_rgb_led[0][1][5] <= yellow ; 
 				state_rgb_led[0][2][0] <= yellow ; 
 				state_rgb_led[0][2][1] <= yellow ; 
 				state_rgb_led[0][2][2] <= yellow ; 
 				state_rgb_led[0][2][3] <= yellow ; 
 				state_rgb_led[0][2][4] <= yellow ; 
 				state_rgb_led[0][2][5] <= yellow ; 
 				state_rgb_led[0][3][0] <= yellow ; 
 				state_rgb_led[0][3][1] <= yellow ; 
 				state_rgb_led[0][3][2] <= yellow ; 
 				state_rgb_led[0][3][3] <= yellow ; 
 				state_rgb_led[0][3][4] <= yellow ; 
 				state_rgb_led[0][3][5] <= yellow ; 
 				state_rgb_led[0][4][0] <= yellow ; 
 				state_rgb_led[0][4][1] <= yellow ; 
 				state_rgb_led[0][4][2] <= yellow ; 
 				state_rgb_led[0][4][3] <= yellow ; 
 				state_rgb_led[0][4][4] <= yellow ; 
 				state_rgb_led[0][4][5] <= yellow ; 
 				state_rgb_led[0][5][0] <= yellow ; 
 				state_rgb_led[0][5][1] <= yellow ; 
 				state_rgb_led[0][5][2] <= yellow ; 
 				state_rgb_led[0][5][3] <= yellow ; 
 				state_rgb_led[0][5][4] <= yellow ; 
 				state_rgb_led[0][5][5] <= yellow ; 
 				state_rgb_led[1][0][0] <= yellow ; 
 				state_rgb_led[1][0][1] <= yellow ; 
 				state_rgb_led[1][0][2] <= yellow ; 
 				state_rgb_led[1][0][3] <= yellow ; 
 				state_rgb_led[1][0][4] <= yellow ; 
 				state_rgb_led[1][0][5] <= yellow ; 
 				state_rgb_led[1][1][0] <= yellow ; 
 				state_rgb_led[1][1][1] <= yellow ; 
 				state_rgb_led[1][1][2] <= yellow ; 
 				state_rgb_led[1][1][3] <= yellow ; 
 				state_rgb_led[1][1][4] <= yellow ; 
 				state_rgb_led[1][1][5] <= yellow ; 
 				state_rgb_led[1][2][0] <= yellow ; 
 				state_rgb_led[1][2][1] <= yellow ; 
 				state_rgb_led[1][2][2] <= yellow ; 
 				state_rgb_led[1][2][3] <= yellow ; 
 				state_rgb_led[1][2][4] <= yellow ; 
 				state_rgb_led[1][2][5] <= yellow ; 
 				state_rgb_led[1][3][0] <= yellow ; 
 				state_rgb_led[1][3][1] <= yellow ; 
 				state_rgb_led[1][3][2] <= yellow ; 
 				state_rgb_led[1][3][3] <= yellow ; 
 				state_rgb_led[1][3][4] <= yellow ; 
 				state_rgb_led[1][3][5] <= yellow ; 
 				state_rgb_led[1][4][0] <= yellow ; 
 				state_rgb_led[1][4][1] <= yellow ; 
 				state_rgb_led[1][4][2] <= yellow ; 
 				state_rgb_led[1][4][3] <= yellow ; 
 				state_rgb_led[1][4][4] <= yellow ; 
 				state_rgb_led[1][4][5] <= yellow ; 
 				state_rgb_led[1][5][0] <= yellow ; 
 				state_rgb_led[1][5][1] <= yellow ; 
 				state_rgb_led[1][5][2] <= yellow ; 
 				state_rgb_led[1][5][3] <= yellow ; 
 				state_rgb_led[1][5][4] <= yellow ; 
 				state_rgb_led[1][5][5] <= yellow ; 
 				state_rgb_led[2][0][0] <= yellow ; 
 				state_rgb_led[2][0][1] <= yellow ; 
 				state_rgb_led[2][0][2] <= yellow ; 
 				state_rgb_led[2][0][3] <= yellow ; 
 				state_rgb_led[2][0][4] <= yellow ; 
 				state_rgb_led[2][0][5] <= yellow ; 
 				state_rgb_led[2][1][0] <= yellow ; 
 				state_rgb_led[2][1][1] <= yellow ; 
 				state_rgb_led[2][1][2] <= yellow ; 
 				state_rgb_led[2][1][3] <= yellow ; 
 				state_rgb_led[2][1][4] <= yellow ; 
 				state_rgb_led[2][1][5] <= yellow ; 
 				state_rgb_led[2][2][0] <= yellow ; 
 				state_rgb_led[2][2][1] <= yellow ; 
 				state_rgb_led[2][2][2] <= yellow ; 
 				state_rgb_led[2][2][3] <= yellow ; 
 				state_rgb_led[2][2][4] <= yellow ; 
 				state_rgb_led[2][2][5] <= yellow ; 
 				state_rgb_led[2][3][0] <= yellow ; 
 				state_rgb_led[2][3][1] <= yellow ; 
 				state_rgb_led[2][3][2] <= yellow ; 
 				state_rgb_led[2][3][3] <= yellow ; 
 				state_rgb_led[2][3][4] <= yellow ; 
 				state_rgb_led[2][3][5] <= yellow ; 
 				state_rgb_led[2][4][0] <= yellow ; 
 				state_rgb_led[2][4][1] <= yellow ; 
 				state_rgb_led[2][4][2] <= yellow ; 
 				state_rgb_led[2][4][3] <= yellow ; 
 				state_rgb_led[2][4][4] <= yellow ; 
 				state_rgb_led[2][4][5] <= yellow ; 
 				state_rgb_led[2][5][0] <= yellow ; 
 				state_rgb_led[2][5][1] <= yellow ; 
 				state_rgb_led[2][5][2] <= yellow ; 
 				state_rgb_led[2][5][3] <= yellow ; 
 				state_rgb_led[2][5][4] <= yellow ; 
 				state_rgb_led[2][5][5] <= yellow ; 
 				state_rgb_led[3][0][0] <= yellow ; 
 				state_rgb_led[3][0][1] <= yellow ; 
 				state_rgb_led[3][0][2] <= yellow ; 
 				state_rgb_led[3][0][3] <= yellow ; 
 				state_rgb_led[3][0][4] <= yellow ; 
 				state_rgb_led[3][0][5] <= yellow ; 
 				state_rgb_led[3][1][0] <= yellow ; 
 				state_rgb_led[3][1][1] <= yellow ; 
 				state_rgb_led[3][1][2] <= yellow ; 
 				state_rgb_led[3][1][3] <= yellow ; 
 				state_rgb_led[3][1][4] <= yellow ; 
 				state_rgb_led[3][1][5] <= yellow ; 
 				state_rgb_led[3][2][0] <= yellow ; 
 				state_rgb_led[3][2][1] <= yellow ; 
 				state_rgb_led[3][2][2] <= yellow ; 
 				state_rgb_led[3][2][3] <= yellow ; 
 				state_rgb_led[3][2][4] <= yellow ; 
 				state_rgb_led[3][2][5] <= yellow ; 
 				state_rgb_led[3][3][0] <= yellow ; 
 				state_rgb_led[3][3][1] <= yellow ; 
 				state_rgb_led[3][3][2] <= yellow ; 
 				state_rgb_led[3][3][3] <= yellow ; 
 				state_rgb_led[3][3][4] <= yellow ; 
 				state_rgb_led[3][3][5] <= yellow ; 
 				state_rgb_led[3][4][0] <= yellow ; 
 				state_rgb_led[3][4][1] <= yellow ; 
 				state_rgb_led[3][4][2] <= yellow ; 
 				state_rgb_led[3][4][3] <= yellow ; 
 				state_rgb_led[3][4][4] <= yellow ; 
 				state_rgb_led[3][4][5] <= yellow ; 
 				state_rgb_led[3][5][0] <= yellow ; 
 				state_rgb_led[3][5][1] <= yellow ; 
 				state_rgb_led[3][5][2] <= yellow ; 
 				state_rgb_led[3][5][3] <= yellow ; 
 				state_rgb_led[3][5][4] <= yellow ; 
 				state_rgb_led[3][5][5] <= yellow ; 
 				state_rgb_led[4][0][0] <= yellow ; 
 				state_rgb_led[4][0][1] <= yellow ; 
 				state_rgb_led[4][0][2] <= yellow ; 
 				state_rgb_led[4][0][3] <= yellow ; 
 				state_rgb_led[4][0][4] <= yellow ; 
 				state_rgb_led[4][0][5] <= yellow ; 
 				state_rgb_led[4][1][0] <= yellow ; 
 				state_rgb_led[4][1][1] <= yellow ; 
 				state_rgb_led[4][1][2] <= yellow ; 
 				state_rgb_led[4][1][3] <= yellow ; 
 				state_rgb_led[4][1][4] <= yellow ; 
 				state_rgb_led[4][1][5] <= yellow ; 
 				state_rgb_led[4][2][0] <= yellow ; 
 				state_rgb_led[4][2][1] <= yellow ; 
 				state_rgb_led[4][2][2] <= yellow ; 
 				state_rgb_led[4][2][3] <= yellow ; 
 				state_rgb_led[4][2][4] <= yellow ; 
 				state_rgb_led[4][2][5] <= yellow ; 
 				state_rgb_led[4][3][0] <= yellow ; 
 				state_rgb_led[4][3][1] <= yellow ; 
 				state_rgb_led[4][3][2] <= yellow ; 
 				state_rgb_led[4][3][3] <= yellow ; 
 				state_rgb_led[4][3][4] <= yellow ; 
 				state_rgb_led[4][3][5] <= yellow ; 
 				state_rgb_led[4][4][0] <= yellow ; 
 				state_rgb_led[4][4][1] <= yellow ; 
 				state_rgb_led[4][4][2] <= yellow ; 
 				state_rgb_led[4][4][3] <= yellow ; 
 				state_rgb_led[4][4][4] <= yellow ; 
 				state_rgb_led[4][4][5] <= yellow ; 
 				state_rgb_led[4][5][0] <= yellow ; 
 				state_rgb_led[4][5][1] <= yellow ; 
 				state_rgb_led[4][5][2] <= yellow ; 
 				state_rgb_led[4][5][3] <= yellow ; 
 				state_rgb_led[4][5][4] <= yellow ; 
 				state_rgb_led[4][5][5] <= yellow ; 
 				state_rgb_led[5][0][0] <= yellow ; 
 				state_rgb_led[5][0][1] <= yellow ; 
 				state_rgb_led[5][0][2] <= yellow ; 
 				state_rgb_led[5][0][3] <= yellow ; 
 				state_rgb_led[5][0][4] <= yellow ; 
 				state_rgb_led[5][0][5] <= yellow ; 
 				state_rgb_led[5][1][0] <= yellow ; 
 				state_rgb_led[5][1][1] <= yellow ; 
 				state_rgb_led[5][1][2] <= yellow ; 
 				state_rgb_led[5][1][3] <= yellow ; 
 				state_rgb_led[5][1][4] <= yellow ; 
 				state_rgb_led[5][1][5] <= yellow ; 
 				state_rgb_led[5][2][0] <= yellow ; 
 				state_rgb_led[5][2][1] <= yellow ; 
 				state_rgb_led[5][2][2] <= yellow ; 
 				state_rgb_led[5][2][3] <= yellow ; 
 				state_rgb_led[5][2][4] <= yellow ; 
 				state_rgb_led[5][2][5] <= yellow ; 
 				state_rgb_led[5][3][0] <= yellow ; 
 				state_rgb_led[5][3][1] <= yellow ; 
 				state_rgb_led[5][3][2] <= yellow ; 
 				state_rgb_led[5][3][3] <= yellow ; 
 				state_rgb_led[5][3][4] <= yellow ; 
 				state_rgb_led[5][3][5] <= yellow ; 
 				state_rgb_led[5][4][0] <= yellow ; 
 				state_rgb_led[5][4][1] <= yellow ; 
 				state_rgb_led[5][4][2] <= yellow ; 
 				state_rgb_led[5][4][3] <= yellow ; 
 				state_rgb_led[5][4][4] <= yellow ; 
 				state_rgb_led[5][4][5] <= yellow ; 
 				state_rgb_led[5][5][0] <= yellow ; 
 				state_rgb_led[5][5][1] <= yellow ; 
 				state_rgb_led[5][5][2] <= yellow ; 
 				state_rgb_led[5][5][3] <= yellow ; 
 				state_rgb_led[5][5][4] <= yellow ; 
 				state_rgb_led[5][5][5] <= yellow ; 

				
			end 
			4'd2 : begin	//开始特效2
				state_rgb_led[0][0][0] <= bule ; 
 				state_rgb_led[0][0][1] <= bule ; 
 				state_rgb_led[0][0][2] <= bule ; 
 				state_rgb_led[0][0][3] <= bule ; 
 				state_rgb_led[0][0][4] <= bule ; 
 				state_rgb_led[0][0][5] <= bule ; 
 				state_rgb_led[0][1][0] <= bule ; 
 				state_rgb_led[0][1][1] <= bule ; 
 				state_rgb_led[0][1][2] <= bule ; 
 				state_rgb_led[0][1][3] <= bule ; 
 				state_rgb_led[0][1][4] <= bule ; 
 				state_rgb_led[0][1][5] <= bule ; 
 				state_rgb_led[0][2][0] <= bule ; 
 				state_rgb_led[0][2][1] <= bule ; 
 				state_rgb_led[0][2][2] <= bule ; 
 				state_rgb_led[0][2][3] <= bule ; 
 				state_rgb_led[0][2][4] <= bule ; 
 				state_rgb_led[0][2][5] <= bule ; 
 				state_rgb_led[0][3][0] <= bule ; 
 				state_rgb_led[0][3][1] <= bule ; 
 				state_rgb_led[0][3][2] <= bule ; 
 				state_rgb_led[0][3][3] <= bule ; 
 				state_rgb_led[0][3][4] <= bule ; 
 				state_rgb_led[0][3][5] <= bule ; 
 				state_rgb_led[0][4][0] <= bule ; 
 				state_rgb_led[0][4][1] <= bule ; 
 				state_rgb_led[0][4][2] <= bule ; 
 				state_rgb_led[0][4][3] <= bule ; 
 				state_rgb_led[0][4][4] <= bule ; 
 				state_rgb_led[0][4][5] <= bule ; 
 				state_rgb_led[0][5][0] <= bule ; 
 				state_rgb_led[0][5][1] <= bule ; 
 				state_rgb_led[0][5][2] <= bule ; 
 				state_rgb_led[0][5][3] <= bule ; 
 				state_rgb_led[0][5][4] <= bule ; 
 				state_rgb_led[0][5][5] <= bule ; 
 				state_rgb_led[1][0][0] <= bule ; 
 				state_rgb_led[1][0][1] <= bule ; 
 				state_rgb_led[1][0][2] <= bule ; 
 				state_rgb_led[1][0][3] <= bule ; 
 				state_rgb_led[1][0][4] <= bule ; 
 				state_rgb_led[1][0][5] <= bule ; 
 				state_rgb_led[1][1][0] <= bule ; 
 				state_rgb_led[1][1][1] <= bule ; 
 				state_rgb_led[1][1][2] <= bule ; 
 				state_rgb_led[1][1][3] <= bule ; 
 				state_rgb_led[1][1][4] <= bule ; 
 				state_rgb_led[1][1][5] <= bule ; 
 				state_rgb_led[1][2][0] <= bule ; 
 				state_rgb_led[1][2][1] <= bule ; 
 				state_rgb_led[1][2][2] <= bule ; 
 				state_rgb_led[1][2][3] <= bule ; 
 				state_rgb_led[1][2][4] <= bule ; 
 				state_rgb_led[1][2][5] <= bule ; 
 				state_rgb_led[1][3][0] <= bule ; 
 				state_rgb_led[1][3][1] <= bule ; 
 				state_rgb_led[1][3][2] <= bule ; 
 				state_rgb_led[1][3][3] <= bule ; 
 				state_rgb_led[1][3][4] <= bule ; 
 				state_rgb_led[1][3][5] <= bule ; 
 				state_rgb_led[1][4][0] <= bule ; 
 				state_rgb_led[1][4][1] <= bule ; 
 				state_rgb_led[1][4][2] <= bule ; 
 				state_rgb_led[1][4][3] <= bule ; 
 				state_rgb_led[1][4][4] <= bule ; 
 				state_rgb_led[1][4][5] <= bule ; 
 				state_rgb_led[1][5][0] <= bule ; 
 				state_rgb_led[1][5][1] <= bule ; 
 				state_rgb_led[1][5][2] <= bule ; 
 				state_rgb_led[1][5][3] <= bule ; 
 				state_rgb_led[1][5][4] <= bule ; 
 				state_rgb_led[1][5][5] <= bule ; 
 				state_rgb_led[2][0][0] <= bule ; 
 				state_rgb_led[2][0][1] <= bule ; 
 				state_rgb_led[2][0][2] <= bule ; 
 				state_rgb_led[2][0][3] <= bule ; 
 				state_rgb_led[2][0][4] <= bule ; 
 				state_rgb_led[2][0][5] <= bule ; 
 				state_rgb_led[2][1][0] <= bule ; 
 				state_rgb_led[2][1][1] <= bule ; 
 				state_rgb_led[2][1][2] <= bule ; 
 				state_rgb_led[2][1][3] <= bule ; 
 				state_rgb_led[2][1][4] <= bule ; 
 				state_rgb_led[2][1][5] <= bule ; 
 				state_rgb_led[2][2][0] <= bule ; 
 				state_rgb_led[2][2][1] <= bule ; 
 				state_rgb_led[2][2][2] <= bule ; 
 				state_rgb_led[2][2][3] <= bule ; 
 				state_rgb_led[2][2][4] <= bule ; 
 				state_rgb_led[2][2][5] <= bule ; 
 				state_rgb_led[2][3][0] <= bule ; 
 				state_rgb_led[2][3][1] <= bule ; 
 				state_rgb_led[2][3][2] <= bule ; 
 				state_rgb_led[2][3][3] <= bule ; 
 				state_rgb_led[2][3][4] <= bule ; 
 				state_rgb_led[2][3][5] <= bule ; 
 				state_rgb_led[2][4][0] <= bule ; 
 				state_rgb_led[2][4][1] <= bule ; 
 				state_rgb_led[2][4][2] <= bule ; 
 				state_rgb_led[2][4][3] <= bule ; 
 				state_rgb_led[2][4][4] <= bule ; 
 				state_rgb_led[2][4][5] <= bule ; 
 				state_rgb_led[2][5][0] <= bule ; 
 				state_rgb_led[2][5][1] <= bule ; 
 				state_rgb_led[2][5][2] <= bule ; 
 				state_rgb_led[2][5][3] <= bule ; 
 				state_rgb_led[2][5][4] <= bule ; 
 				state_rgb_led[2][5][5] <= bule ; 
 				state_rgb_led[3][0][0] <= bule ; 
 				state_rgb_led[3][0][1] <= bule ; 
 				state_rgb_led[3][0][2] <= bule ; 
 				state_rgb_led[3][0][3] <= bule ; 
 				state_rgb_led[3][0][4] <= bule ; 
 				state_rgb_led[3][0][5] <= bule ; 
 				state_rgb_led[3][1][0] <= bule ; 
 				state_rgb_led[3][1][1] <= bule ; 
 				state_rgb_led[3][1][2] <= bule ; 
 				state_rgb_led[3][1][3] <= bule ; 
 				state_rgb_led[3][1][4] <= bule ; 
 				state_rgb_led[3][1][5] <= bule ; 
 				state_rgb_led[3][2][0] <= bule ; 
 				state_rgb_led[3][2][1] <= bule ; 
 				state_rgb_led[3][2][2] <= bule ; 
 				state_rgb_led[3][2][3] <= bule ; 
 				state_rgb_led[3][2][4] <= bule ; 
 				state_rgb_led[3][2][5] <= bule ; 
 				state_rgb_led[3][3][0] <= bule ; 
 				state_rgb_led[3][3][1] <= bule ; 
 				state_rgb_led[3][3][2] <= bule ; 
 				state_rgb_led[3][3][3] <= bule ; 
 				state_rgb_led[3][3][4] <= bule ; 
 				state_rgb_led[3][3][5] <= bule ; 
 				state_rgb_led[3][4][0] <= bule ; 
 				state_rgb_led[3][4][1] <= bule ; 
 				state_rgb_led[3][4][2] <= bule ; 
 				state_rgb_led[3][4][3] <= bule ; 
 				state_rgb_led[3][4][4] <= bule ; 
 				state_rgb_led[3][4][5] <= bule ; 
 				state_rgb_led[3][5][0] <= bule ; 
 				state_rgb_led[3][5][1] <= bule ; 
 				state_rgb_led[3][5][2] <= bule ; 
 				state_rgb_led[3][5][3] <= bule ; 
 				state_rgb_led[3][5][4] <= bule ; 
 				state_rgb_led[3][5][5] <= bule ; 
 				state_rgb_led[4][0][0] <= bule ; 
 				state_rgb_led[4][0][1] <= bule ; 
 				state_rgb_led[4][0][2] <= bule ; 
 				state_rgb_led[4][0][3] <= bule ; 
 				state_rgb_led[4][0][4] <= bule ; 
 				state_rgb_led[4][0][5] <= bule ; 
 				state_rgb_led[4][1][0] <= bule ; 
 				state_rgb_led[4][1][1] <= bule ; 
 				state_rgb_led[4][1][2] <= bule ; 
 				state_rgb_led[4][1][3] <= bule ; 
 				state_rgb_led[4][1][4] <= bule ; 
 				state_rgb_led[4][1][5] <= bule ; 
 				state_rgb_led[4][2][0] <= bule ; 
 				state_rgb_led[4][2][1] <= bule ; 
 				state_rgb_led[4][2][2] <= bule ; 
 				state_rgb_led[4][2][3] <= bule ; 
 				state_rgb_led[4][2][4] <= bule ; 
 				state_rgb_led[4][2][5] <= bule ; 
 				state_rgb_led[4][3][0] <= bule ; 
 				state_rgb_led[4][3][1] <= bule ; 
 				state_rgb_led[4][3][2] <= bule ; 
 				state_rgb_led[4][3][3] <= bule ; 
 				state_rgb_led[4][3][4] <= bule ; 
 				state_rgb_led[4][3][5] <= bule ; 
 				state_rgb_led[4][4][0] <= bule ; 
 				state_rgb_led[4][4][1] <= bule ; 
 				state_rgb_led[4][4][2] <= bule ; 
 				state_rgb_led[4][4][3] <= bule ; 
 				state_rgb_led[4][4][4] <= bule ; 
 				state_rgb_led[4][4][5] <= bule ; 
 				state_rgb_led[4][5][0] <= bule ; 
 				state_rgb_led[4][5][1] <= bule ; 
 				state_rgb_led[4][5][2] <= bule ; 
 				state_rgb_led[4][5][3] <= bule ; 
 				state_rgb_led[4][5][4] <= bule ; 
 				state_rgb_led[4][5][5] <= bule ; 
 				state_rgb_led[5][0][0] <= bule ; 
 				state_rgb_led[5][0][1] <= bule ; 
 				state_rgb_led[5][0][2] <= bule ; 
 				state_rgb_led[5][0][3] <= bule ; 
 				state_rgb_led[5][0][4] <= bule ; 
 				state_rgb_led[5][0][5] <= bule ; 
 				state_rgb_led[5][1][0] <= bule ; 
 				state_rgb_led[5][1][1] <= bule ; 
 				state_rgb_led[5][1][2] <= bule ; 
 				state_rgb_led[5][1][3] <= bule ; 
 				state_rgb_led[5][1][4] <= bule ; 
 				state_rgb_led[5][1][5] <= bule ; 
 				state_rgb_led[5][2][0] <= bule ; 
 				state_rgb_led[5][2][1] <= bule ; 
 				state_rgb_led[5][2][2] <= bule ; 
 				state_rgb_led[5][2][3] <= bule ; 
 				state_rgb_led[5][2][4] <= bule ; 
 				state_rgb_led[5][2][5] <= bule ; 
 				state_rgb_led[5][3][0] <= bule ; 
 				state_rgb_led[5][3][1] <= bule ; 
 				state_rgb_led[5][3][2] <= bule ; 
 				state_rgb_led[5][3][3] <= bule ; 
 				state_rgb_led[5][3][4] <= bule ; 
 				state_rgb_led[5][3][5] <= bule ; 
 				state_rgb_led[5][4][0] <= bule ; 
 				state_rgb_led[5][4][1] <= bule ; 
 				state_rgb_led[5][4][2] <= bule ; 
 				state_rgb_led[5][4][3] <= bule ; 
 				state_rgb_led[5][4][4] <= bule ; 
 				state_rgb_led[5][4][5] <= bule ; 
 				state_rgb_led[5][5][0] <= bule ; 
 				state_rgb_led[5][5][1] <= bule ; 
 				state_rgb_led[5][5][2] <= bule ; 
 				state_rgb_led[5][5][3] <= bule ; 
 				state_rgb_led[5][5][4] <= bule ; 
 				state_rgb_led[5][5][5] <= bule ; 				
			end
			4'd3 : begin	//开始特效3
				state_rgb_led[0][0][0] <= purple ; 
 				state_rgb_led[0][0][1] <= purple ; 
 				state_rgb_led[0][0][2] <= purple ; 
 				state_rgb_led[0][0][3] <= purple ; 
 				state_rgb_led[0][0][4] <= purple ; 
 				state_rgb_led[0][0][5] <= purple ; 
 				state_rgb_led[0][1][0] <= purple ; 
 				state_rgb_led[0][1][1] <= purple ; 
 				state_rgb_led[0][1][2] <= purple ; 
 				state_rgb_led[0][1][3] <= purple ; 
 				state_rgb_led[0][1][4] <= purple ; 
 				state_rgb_led[0][1][5] <= purple ; 
 				state_rgb_led[0][2][0] <= purple ; 
 				state_rgb_led[0][2][1] <= purple ; 
 				state_rgb_led[0][2][2] <= purple ; 
 				state_rgb_led[0][2][3] <= purple ; 
 				state_rgb_led[0][2][4] <= purple ; 
 				state_rgb_led[0][2][5] <= purple ; 
 				state_rgb_led[0][3][0] <= purple ; 
 				state_rgb_led[0][3][1] <= purple ; 
 				state_rgb_led[0][3][2] <= purple ; 
 				state_rgb_led[0][3][3] <= purple ; 
 				state_rgb_led[0][3][4] <= purple ; 
 				state_rgb_led[0][3][5] <= purple ; 
 				state_rgb_led[0][4][0] <= purple ; 
 				state_rgb_led[0][4][1] <= purple ; 
 				state_rgb_led[0][4][2] <= purple ; 
 				state_rgb_led[0][4][3] <= purple ; 
 				state_rgb_led[0][4][4] <= purple ; 
 				state_rgb_led[0][4][5] <= purple ; 
 				state_rgb_led[0][5][0] <= purple ; 
 				state_rgb_led[0][5][1] <= purple ; 
 				state_rgb_led[0][5][2] <= purple ; 
 				state_rgb_led[0][5][3] <= purple ; 
 				state_rgb_led[0][5][4] <= purple ; 
 				state_rgb_led[0][5][5] <= purple ; 
 				state_rgb_led[1][0][0] <= purple ; 
 				state_rgb_led[1][0][1] <= purple ; 
 				state_rgb_led[1][0][2] <= purple ; 
 				state_rgb_led[1][0][3] <= purple ; 
 				state_rgb_led[1][0][4] <= purple ; 
 				state_rgb_led[1][0][5] <= purple ; 
 				state_rgb_led[1][1][0] <= purple ; 
 				state_rgb_led[1][1][1] <= purple ; 
 				state_rgb_led[1][1][2] <= purple ; 
 				state_rgb_led[1][1][3] <= purple ; 
 				state_rgb_led[1][1][4] <= purple ; 
 				state_rgb_led[1][1][5] <= purple ; 
 				state_rgb_led[1][2][0] <= purple ; 
 				state_rgb_led[1][2][1] <= purple ; 
 				state_rgb_led[1][2][2] <= purple ; 
 				state_rgb_led[1][2][3] <= purple ; 
 				state_rgb_led[1][2][4] <= purple ; 
 				state_rgb_led[1][2][5] <= purple ; 
 				state_rgb_led[1][3][0] <= purple ; 
 				state_rgb_led[1][3][1] <= purple ; 
 				state_rgb_led[1][3][2] <= purple ; 
 				state_rgb_led[1][3][3] <= purple ; 
 				state_rgb_led[1][3][4] <= purple ; 
 				state_rgb_led[1][3][5] <= purple ; 
 				state_rgb_led[1][4][0] <= purple ; 
 				state_rgb_led[1][4][1] <= purple ; 
 				state_rgb_led[1][4][2] <= purple ; 
 				state_rgb_led[1][4][3] <= purple ; 
 				state_rgb_led[1][4][4] <= purple ; 
 				state_rgb_led[1][4][5] <= purple ; 
 				state_rgb_led[1][5][0] <= purple ; 
 				state_rgb_led[1][5][1] <= purple ; 
 				state_rgb_led[1][5][2] <= purple ; 
 				state_rgb_led[1][5][3] <= purple ; 
 				state_rgb_led[1][5][4] <= purple ; 
 				state_rgb_led[1][5][5] <= purple ; 
 				state_rgb_led[2][0][0] <= purple ; 
 				state_rgb_led[2][0][1] <= purple ; 
 				state_rgb_led[2][0][2] <= purple ; 
 				state_rgb_led[2][0][3] <= purple ; 
 				state_rgb_led[2][0][4] <= purple ; 
 				state_rgb_led[2][0][5] <= purple ; 
 				state_rgb_led[2][1][0] <= purple ; 
 				state_rgb_led[2][1][1] <= purple ; 
 				state_rgb_led[2][1][2] <= purple ; 
 				state_rgb_led[2][1][3] <= purple ; 
 				state_rgb_led[2][1][4] <= purple ; 
 				state_rgb_led[2][1][5] <= purple ; 
 				state_rgb_led[2][2][0] <= purple ; 
 				state_rgb_led[2][2][1] <= purple ; 
 				state_rgb_led[2][2][2] <= purple ; 
 				state_rgb_led[2][2][3] <= purple ; 
 				state_rgb_led[2][2][4] <= purple ; 
 				state_rgb_led[2][2][5] <= purple ; 
 				state_rgb_led[2][3][0] <= purple ; 
 				state_rgb_led[2][3][1] <= purple ; 
 				state_rgb_led[2][3][2] <= purple ; 
 				state_rgb_led[2][3][3] <= purple ; 
 				state_rgb_led[2][3][4] <= purple ; 
 				state_rgb_led[2][3][5] <= purple ; 
 				state_rgb_led[2][4][0] <= purple ; 
 				state_rgb_led[2][4][1] <= purple ; 
 				state_rgb_led[2][4][2] <= purple ; 
 				state_rgb_led[2][4][3] <= purple ; 
 				state_rgb_led[2][4][4] <= purple ; 
 				state_rgb_led[2][4][5] <= purple ; 
 				state_rgb_led[2][5][0] <= purple ; 
 				state_rgb_led[2][5][1] <= purple ; 
 				state_rgb_led[2][5][2] <= purple ; 
 				state_rgb_led[2][5][3] <= purple ; 
 				state_rgb_led[2][5][4] <= purple ; 
 				state_rgb_led[2][5][5] <= purple ; 
 				state_rgb_led[3][0][0] <= purple ; 
 				state_rgb_led[3][0][1] <= purple ; 
 				state_rgb_led[3][0][2] <= purple ; 
 				state_rgb_led[3][0][3] <= purple ; 
 				state_rgb_led[3][0][4] <= purple ; 
 				state_rgb_led[3][0][5] <= purple ; 
 				state_rgb_led[3][1][0] <= purple ; 
 				state_rgb_led[3][1][1] <= purple ; 
 				state_rgb_led[3][1][2] <= purple ; 
 				state_rgb_led[3][1][3] <= purple ; 
 				state_rgb_led[3][1][4] <= purple ; 
 				state_rgb_led[3][1][5] <= purple ; 
 				state_rgb_led[3][2][0] <= purple ; 
 				state_rgb_led[3][2][1] <= purple ; 
 				state_rgb_led[3][2][2] <= purple ; 
 				state_rgb_led[3][2][3] <= purple ; 
 				state_rgb_led[3][2][4] <= purple ; 
 				state_rgb_led[3][2][5] <= purple ; 
 				state_rgb_led[3][3][0] <= purple ; 
 				state_rgb_led[3][3][1] <= purple ; 
 				state_rgb_led[3][3][2] <= purple ; 
 				state_rgb_led[3][3][3] <= purple ; 
 				state_rgb_led[3][3][4] <= purple ; 
 				state_rgb_led[3][3][5] <= purple ; 
 				state_rgb_led[3][4][0] <= purple ; 
 				state_rgb_led[3][4][1] <= purple ; 
 				state_rgb_led[3][4][2] <= purple ; 
 				state_rgb_led[3][4][3] <= purple ; 
 				state_rgb_led[3][4][4] <= purple ; 
 				state_rgb_led[3][4][5] <= purple ; 
 				state_rgb_led[3][5][0] <= purple ; 
 				state_rgb_led[3][5][1] <= purple ; 
 				state_rgb_led[3][5][2] <= purple ; 
 				state_rgb_led[3][5][3] <= purple ; 
 				state_rgb_led[3][5][4] <= purple ; 
 				state_rgb_led[3][5][5] <= purple ; 
 				state_rgb_led[4][0][0] <= purple ; 
 				state_rgb_led[4][0][1] <= purple ; 
 				state_rgb_led[4][0][2] <= purple ; 
 				state_rgb_led[4][0][3] <= purple ; 
 				state_rgb_led[4][0][4] <= purple ; 
 				state_rgb_led[4][0][5] <= purple ; 
 				state_rgb_led[4][1][0] <= purple ; 
 				state_rgb_led[4][1][1] <= purple ; 
 				state_rgb_led[4][1][2] <= purple ; 
 				state_rgb_led[4][1][3] <= purple ; 
 				state_rgb_led[4][1][4] <= purple ; 
 				state_rgb_led[4][1][5] <= purple ; 
 				state_rgb_led[4][2][0] <= purple ; 
 				state_rgb_led[4][2][1] <= purple ; 
 				state_rgb_led[4][2][2] <= purple ; 
 				state_rgb_led[4][2][3] <= purple ; 
 				state_rgb_led[4][2][4] <= purple ; 
 				state_rgb_led[4][2][5] <= purple ; 
 				state_rgb_led[4][3][0] <= purple ; 
 				state_rgb_led[4][3][1] <= purple ; 
 				state_rgb_led[4][3][2] <= purple ; 
 				state_rgb_led[4][3][3] <= purple ; 
 				state_rgb_led[4][3][4] <= purple ; 
 				state_rgb_led[4][3][5] <= purple ; 
 				state_rgb_led[4][4][0] <= purple ; 
 				state_rgb_led[4][4][1] <= purple ; 
 				state_rgb_led[4][4][2] <= purple ; 
 				state_rgb_led[4][4][3] <= purple ; 
 				state_rgb_led[4][4][4] <= purple ; 
 				state_rgb_led[4][4][5] <= purple ; 
 				state_rgb_led[4][5][0] <= purple ; 
 				state_rgb_led[4][5][1] <= purple ; 
 				state_rgb_led[4][5][2] <= purple ; 
 				state_rgb_led[4][5][3] <= purple ; 
 				state_rgb_led[4][5][4] <= purple ; 
 				state_rgb_led[4][5][5] <= purple ; 
 				state_rgb_led[5][0][0] <= purple ; 
 				state_rgb_led[5][0][1] <= purple ; 
 				state_rgb_led[5][0][2] <= purple ; 
 				state_rgb_led[5][0][3] <= purple ; 
 				state_rgb_led[5][0][4] <= purple ; 
 				state_rgb_led[5][0][5] <= purple ; 
 				state_rgb_led[5][1][0] <= purple ; 
 				state_rgb_led[5][1][1] <= purple ; 
 				state_rgb_led[5][1][2] <= purple ; 
 				state_rgb_led[5][1][3] <= purple ; 
 				state_rgb_led[5][1][4] <= purple ; 
 				state_rgb_led[5][1][5] <= purple ; 
 				state_rgb_led[5][2][0] <= purple ; 
 				state_rgb_led[5][2][1] <= purple ; 
 				state_rgb_led[5][2][2] <= purple ; 
 				state_rgb_led[5][2][3] <= purple ; 
 				state_rgb_led[5][2][4] <= purple ; 
 				state_rgb_led[5][2][5] <= purple ; 
 				state_rgb_led[5][3][0] <= purple ; 
 				state_rgb_led[5][3][1] <= purple ; 
 				state_rgb_led[5][3][2] <= purple ; 
 				state_rgb_led[5][3][3] <= purple ; 
 				state_rgb_led[5][3][4] <= purple ; 
 				state_rgb_led[5][3][5] <= purple ; 
 				state_rgb_led[5][4][0] <= purple ; 
 				state_rgb_led[5][4][1] <= purple ; 
 				state_rgb_led[5][4][2] <= purple ; 
 				state_rgb_led[5][4][3] <= purple ; 
 				state_rgb_led[5][4][4] <= purple ; 
 				state_rgb_led[5][4][5] <= purple ; 
 				state_rgb_led[5][5][0] <= purple ; 
 				state_rgb_led[5][5][1] <= purple ; 
 				state_rgb_led[5][5][2] <= purple ; 
 				state_rgb_led[5][5][3] <= purple ; 
 				state_rgb_led[5][5][4] <= purple ; 
 				state_rgb_led[5][5][5] <= purple ; 				
			end
			4'd4 : begin    //第一个头启动
				snak_state[0][0][0] = 1'd1 ;
				snak_state[4][3][2] = 1'd1 ;
				snak_body[0] = 8'd0 ;
				state_rgb_led[0][0][0] <= purple ; 
 				state_rgb_led[0][0][1] <= nocolor ; 
 				state_rgb_led[0][0][2] <= nocolor ; 
 				state_rgb_led[0][0][3] <= nocolor ; 
 				state_rgb_led[0][0][4] <= nocolor ; 
 				state_rgb_led[0][0][5] <= nocolor ; 
 				state_rgb_led[0][1][0] <= nocolor ; 
 				state_rgb_led[0][1][1] <= nocolor ; 
 				state_rgb_led[0][1][2] <= nocolor ; 
 				state_rgb_led[0][1][3] <= nocolor ; 
 				state_rgb_led[0][1][4] <= nocolor ; 
 				state_rgb_led[0][1][5] <= nocolor ; 
 				state_rgb_led[0][2][0] <= nocolor ; 
 				state_rgb_led[0][2][1] <= nocolor ; 
 				state_rgb_led[0][2][2] <= nocolor ; 
 				state_rgb_led[0][2][3] <= nocolor ; 
 				state_rgb_led[0][2][4] <= nocolor ; 
 				state_rgb_led[0][2][5] <= nocolor ; 
 				state_rgb_led[0][3][0] <= nocolor ; 
 				state_rgb_led[0][3][1] <= nocolor ; 
 				state_rgb_led[0][3][2] <= nocolor ; 
 				state_rgb_led[0][3][3] <= nocolor ; 
 				state_rgb_led[0][3][4] <= nocolor ; 
 				state_rgb_led[0][3][5] <= nocolor ; 
 				state_rgb_led[0][4][0] <= nocolor ; 
 				state_rgb_led[0][4][1] <= nocolor ; 
 				state_rgb_led[0][4][2] <= nocolor ; 
 				state_rgb_led[0][4][3] <= nocolor ; 
 				state_rgb_led[0][4][4] <= nocolor ; 
 				state_rgb_led[0][4][5] <= nocolor ; 
 				state_rgb_led[0][5][0] <= nocolor ; 
 				state_rgb_led[0][5][1] <= nocolor ; 
 				state_rgb_led[0][5][2] <= nocolor ; 
 				state_rgb_led[0][5][3] <= nocolor ; 
 				state_rgb_led[0][5][4] <= nocolor ; 
 				state_rgb_led[0][5][5] <= nocolor ; 
 				state_rgb_led[1][0][0] <= nocolor ; 
 				state_rgb_led[1][0][1] <= nocolor ; 
 				state_rgb_led[1][0][2] <= nocolor ; 
 				state_rgb_led[1][0][3] <= nocolor ; 
 				state_rgb_led[1][0][4] <= nocolor ; 
 				state_rgb_led[1][0][5] <= nocolor ; 
 				state_rgb_led[1][1][0] <= nocolor ; 
 				state_rgb_led[1][1][1] <= nocolor ; 
 				state_rgb_led[1][1][2] <= nocolor ; 
 				state_rgb_led[1][1][3] <= nocolor ; 
 				state_rgb_led[1][1][4] <= nocolor ; 
 				state_rgb_led[1][1][5] <= nocolor ; 
 				state_rgb_led[1][2][0] <= nocolor ; 
 				state_rgb_led[1][2][1] <= nocolor ; 
 				state_rgb_led[1][2][2] <= nocolor ; 
 				state_rgb_led[1][2][3] <= nocolor ; 
 				state_rgb_led[1][2][4] <= nocolor ; 
 				state_rgb_led[1][2][5] <= nocolor ; 
 				state_rgb_led[1][3][0] <= nocolor ; 
 				state_rgb_led[1][3][1] <= nocolor ; 
 				state_rgb_led[1][3][2] <= nocolor ; 
 				state_rgb_led[1][3][3] <= nocolor ; 
 				state_rgb_led[1][3][4] <= nocolor ; 
 				state_rgb_led[1][3][5] <= nocolor ; 
 				state_rgb_led[1][4][0] <= nocolor ; 
 				state_rgb_led[1][4][1] <= nocolor ; 
 				state_rgb_led[1][4][2] <= nocolor ; 
 				state_rgb_led[1][4][3] <= nocolor ; 
 				state_rgb_led[1][4][4] <= nocolor ; 
 				state_rgb_led[1][4][5] <= nocolor ; 
 				state_rgb_led[1][5][0] <= nocolor ; 
 				state_rgb_led[1][5][1] <= nocolor ; 
 				state_rgb_led[1][5][2] <= nocolor ; 
 				state_rgb_led[1][5][3] <= nocolor ; 
 				state_rgb_led[1][5][4] <= nocolor ; 
 				state_rgb_led[1][5][5] <= nocolor ; 
 				state_rgb_led[2][0][0] <= nocolor ; 
 				state_rgb_led[2][0][1] <= nocolor ; 
 				state_rgb_led[2][0][2] <= nocolor ; 
 				state_rgb_led[2][0][3] <= nocolor ; 
 				state_rgb_led[2][0][4] <= nocolor ; 
 				state_rgb_led[2][0][5] <= nocolor ; 
 				state_rgb_led[2][1][0] <= nocolor ; 
 				state_rgb_led[2][1][1] <= nocolor ; 
 				state_rgb_led[2][1][2] <= nocolor ; 
 				state_rgb_led[2][1][3] <= nocolor ; 
 				state_rgb_led[2][1][4] <= nocolor ; 
 				state_rgb_led[2][1][5] <= nocolor ; 
 				state_rgb_led[2][2][0] <= nocolor ; 
 				state_rgb_led[2][2][1] <= nocolor ; 
 				state_rgb_led[2][2][2] <= nocolor ; 
 				state_rgb_led[2][2][3] <= nocolor ; 
 				state_rgb_led[2][2][4] <= nocolor ; 
 				state_rgb_led[2][2][5] <= nocolor ; 
 				state_rgb_led[2][3][0] <= nocolor ; 
 				state_rgb_led[2][3][1] <= nocolor ; 
 				state_rgb_led[2][3][2] <= nocolor ; 
 				state_rgb_led[2][3][3] <= nocolor ; 
 				state_rgb_led[2][3][4] <= nocolor ; 
 				state_rgb_led[2][3][5] <= nocolor ; 
 				state_rgb_led[2][4][0] <= nocolor ; 
 				state_rgb_led[2][4][1] <= nocolor ; 
 				state_rgb_led[2][4][2] <= nocolor ; 
 				state_rgb_led[2][4][3] <= nocolor ; 
 				state_rgb_led[2][4][4] <= nocolor ; 
 				state_rgb_led[2][4][5] <= nocolor ; 
 				state_rgb_led[2][5][0] <= nocolor ; 
 				state_rgb_led[2][5][1] <= nocolor ; 
 				state_rgb_led[2][5][2] <= nocolor ; 
 				state_rgb_led[2][5][3] <= nocolor ; 
 				state_rgb_led[2][5][4] <= nocolor ; 
 				state_rgb_led[2][5][5] <= nocolor ; 
 				state_rgb_led[3][0][0] <= nocolor ; 
 				state_rgb_led[3][0][1] <= nocolor ; 
 				state_rgb_led[3][0][2] <= nocolor ; 
 				state_rgb_led[3][0][3] <= nocolor ; 
 				state_rgb_led[3][0][4] <= nocolor ; 
 				state_rgb_led[3][0][5] <= nocolor ; 
 				state_rgb_led[3][1][0] <= nocolor ; 
 				state_rgb_led[3][1][1] <= nocolor ; 
 				state_rgb_led[3][1][2] <= nocolor ; 
 				state_rgb_led[3][1][3] <= nocolor ; 
 				state_rgb_led[3][1][4] <= nocolor ; 
 				state_rgb_led[3][1][5] <= nocolor ; 
 				state_rgb_led[3][2][0] <= nocolor ; 
 				state_rgb_led[3][2][1] <= nocolor ; 
 				state_rgb_led[3][2][2] <= nocolor ; 
 				state_rgb_led[3][2][3] <= nocolor ; 
 				state_rgb_led[3][2][4] <= nocolor ; 
 				state_rgb_led[3][2][5] <= nocolor ; 
 				state_rgb_led[3][3][0] <= nocolor ; 
 				state_rgb_led[3][3][1] <= nocolor ; 
 				state_rgb_led[3][3][2] <= nocolor ; 
 				state_rgb_led[3][3][3] <= nocolor ; 
 				state_rgb_led[3][3][4] <= nocolor ; 
 				state_rgb_led[3][3][5] <= nocolor ; 
 				state_rgb_led[3][4][0] <= nocolor ; 
 				state_rgb_led[3][4][1] <= nocolor ; 
 				state_rgb_led[3][4][2] <= nocolor ; 
 				state_rgb_led[3][4][3] <= nocolor ; 
 				state_rgb_led[3][4][4] <= nocolor ; 
 				state_rgb_led[3][4][5] <= nocolor ; 
 				state_rgb_led[3][5][0] <= nocolor ; 
 				state_rgb_led[3][5][1] <= nocolor ; 
 				state_rgb_led[3][5][2] <= nocolor ; 
 				state_rgb_led[3][5][3] <= nocolor ; 
 				state_rgb_led[3][5][4] <= nocolor ; 
 				state_rgb_led[3][5][5] <= nocolor ; 
 				state_rgb_led[4][0][0] <= nocolor ; 
 				state_rgb_led[4][0][1] <= nocolor ; 
 				state_rgb_led[4][0][2] <= nocolor ; 
 				state_rgb_led[4][0][3] <= nocolor ; 
 				state_rgb_led[4][0][4] <= nocolor ; 
 				state_rgb_led[4][0][5] <= nocolor ; 
 				state_rgb_led[4][1][0] <= nocolor ; 
 				state_rgb_led[4][1][1] <= nocolor ; 
 				state_rgb_led[4][1][2] <= nocolor ; 
 				state_rgb_led[4][1][3] <= nocolor ; 
 				state_rgb_led[4][1][4] <= nocolor ; 
 				state_rgb_led[4][1][5] <= nocolor ; 
 				state_rgb_led[4][2][0] <= nocolor ; 
 				state_rgb_led[4][2][1] <= nocolor ; 
 				state_rgb_led[4][2][2] <= nocolor ; 
 				state_rgb_led[4][2][3] <= nocolor ; 
 				state_rgb_led[4][2][4] <= nocolor ; 
 				state_rgb_led[4][2][5] <= nocolor ; 
 				state_rgb_led[4][3][0] <= nocolor ; 
 				state_rgb_led[4][3][1] <= nocolor ; 
 				state_rgb_led[4][3][2] <= green   ; 
 				state_rgb_led[4][3][3] <= nocolor ; 
 				state_rgb_led[4][3][4] <= nocolor ; 
 				state_rgb_led[4][3][5] <= nocolor ; 
 				state_rgb_led[4][4][0] <= nocolor ; 
 				state_rgb_led[4][4][1] <= nocolor ; 
 				state_rgb_led[4][4][2] <= nocolor ; 
 				state_rgb_led[4][4][3] <= nocolor ; 
 				state_rgb_led[4][4][4] <= nocolor ; 
 				state_rgb_led[4][4][5] <= nocolor ; 
 				state_rgb_led[4][5][0] <= nocolor ; 
 				state_rgb_led[4][5][1] <= nocolor ; 
 				state_rgb_led[4][5][2] <= nocolor ; 
 				state_rgb_led[4][5][3] <= nocolor ; 
 				state_rgb_led[4][5][4] <= nocolor ; 
 				state_rgb_led[4][5][5] <= nocolor ; 
 				state_rgb_led[5][0][0] <= nocolor ; 
 				state_rgb_led[5][0][1] <= nocolor ; 
 				state_rgb_led[5][0][2] <= nocolor ; 
 				state_rgb_led[5][0][3] <= nocolor ; 
 				state_rgb_led[5][0][4] <= nocolor ; 
 				state_rgb_led[5][0][5] <= nocolor ; 
 				state_rgb_led[5][1][0] <= nocolor ; 
 				state_rgb_led[5][1][1] <= nocolor ; 
 				state_rgb_led[5][1][2] <= nocolor ; 
 				state_rgb_led[5][1][3] <= nocolor ; 
 				state_rgb_led[5][1][4] <= nocolor ; 
 				state_rgb_led[5][1][5] <= nocolor ; 
 				state_rgb_led[5][2][0] <= nocolor ; 
 				state_rgb_led[5][2][1] <= nocolor ; 
 				state_rgb_led[5][2][2] <= nocolor ; 
 				state_rgb_led[5][2][3] <= nocolor ; 
 				state_rgb_led[5][2][4] <= nocolor ; 
 				state_rgb_led[5][2][5] <= nocolor ; 
 				state_rgb_led[5][3][0] <= nocolor ; 
 				state_rgb_led[5][3][1] <= nocolor ; 
 				state_rgb_led[5][3][2] <= nocolor ; 
 				state_rgb_led[5][3][3] <= nocolor ; 
 				state_rgb_led[5][3][4] <= nocolor ; 
 				state_rgb_led[5][3][5] <= nocolor ; 
 				state_rgb_led[5][4][0] <= nocolor ; 
 				state_rgb_led[5][4][1] <= nocolor ; 
 				state_rgb_led[5][4][2] <= nocolor ; 
 				state_rgb_led[5][4][3] <= nocolor ; 
 				state_rgb_led[5][4][4] <= nocolor ; 
 				state_rgb_led[5][4][5] <= nocolor ; 
 				state_rgb_led[5][5][0] <= nocolor ; 
 				state_rgb_led[5][5][1] <= nocolor ; 
 				state_rgb_led[5][5][2] <= nocolor ; 
 				state_rgb_led[5][5][3] <= nocolor ; 
 				state_rgb_led[5][5][4] <= nocolor ; 
 				state_rgb_led[5][5][5] <= nocolor ; 				
			end
			4'd5 : begin    //下一步空_可以走运动
				state_rgb_led[x_now_header][y_now_header][z_now_header] = red ;  //
				state_rgb_led[x_now_tail][y_now_tail][z_now_tail] = nocolor ;
				snak_body[seat_header_snak+1'd1] = next_header   ;
				snak_state [x_next_header][y_next_header][z_next_header] = 1'd1 ;
				snak_state[x_now_tail][y_now_tail][z_now_tail] <= 1'd0 ;
				seat_header_snak <= seat_header_snak + 1'd1	;				
				seat_tail_snak <= seat_tail_snak + 1'd1	;				
				state_rgb_led[x_next_header][y_next_header][z_next_header] <= purple ;								
							
			end			
			4'd6 : begin    //下一步目标_可以走动
				state_rgb_led[x_now_header][y_now_header][z_now_header] = red ;  //
				state_rgb_led[x_next_header][y_next_header][z_next_header] = purple ;
				snak_body[seat_header_snak+1'd1] = next_header   ;			
				seat_header_snak <= seat_header_snak + 1'd1	;	
				x_aim_snak = x_random_num ;
				y_aim_snak = y_random_num ;
				z_aim_snak = z_random_num ;
				state_rgb_led[x_aim_snak][y_aim_snak][z_aim_snak] = green ;
				snak_state [x_aim_snak][y_aim_snak][z_aim_snak] = 1'd1 ;
			end			
			4'd7 : begin	//下一步吃自己_不能走动
				state_rgb_led[x_next_header][y_next_header][z_next_header] = yellow ;				
			end
			default: state_rgb_led[0][0][0] = red ; 
		endcase
	end
end

reg [2:0]   x_random_num   ;
reg [2:0]   y_random_num   ;
reg [2:0]   z_random_num   ;

reg flag_find_difnum  ;
reg [24:0]  time_find_go_run ;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (!sys_rst_n)  begin  //复位
		address <= 12'd0 ;
		x_random_num <= 3'd0 ;
		y_random_num <= 3'd0 ;
		z_random_num <= 3'd0 ;
	end
	else if(counter_2hz == 27'd50)   begin//走一步就更新一次
		time_find_go_run <= 24'd1562_5000 ;	 end
	else if(time_find_go_run == 27'd0)	//跑15625000次没找到就不跑了	
		time_find_go_run <= time_find_go_run ;
	else begin              //找空位
		y_random_num =  (y_random_num + rom_random_num + 4'd10) / 3'd3 ;
		time_find_go_run <= time_find_go_run - 1'd1 ;   //找一次少一次
		address <= address +1'd1 ;                    //找一次rom变化一次
		if( snak_state[x_random_num][y_random_num][z_random_num] == 0 )  //找到就不找了
			time_find_go_run <= 27'd0 ;   
		else begin   //没找到继续找
			if((time_find_go_run - 16'd6250 * (time_find_go_run / 16'd6250)) == 0 )  //跑6250次更新一次x
				x_random_num <= rom_random_num ;
			else if((time_find_go_run - 9'd250 * (time_find_go_run / 9'd250)) == 0 ) //跑250次更新一次y
					y_random_num <= rom_random_num ;
			else   //其余都在更新z
					z_random_num <= rom_random_num ;
		end		
	end
end 

reg [11:0]  address;
wire [2:0]  rom_random_num ;  //rom 里面的随机数

u_rom_random_P u_rom_random_P (
	.addra(address),
	.clka(sys_clk),
	.douta(rom_random_num)
);


RGB_CTL	u0_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[0][0][5],state_rgb_led[0][0][4],state_rgb_led[0][0][3],state_rgb_led[0][0][2],state_rgb_led[0][0][1],state_rgb_led[0][0][0]}),  
    .rgb_led (rgb_led[0])  
);  
RGB_CTL	u1_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[0][1][5],state_rgb_led[0][1][4],state_rgb_led[0][1][3],state_rgb_led[0][1][2],state_rgb_led[0][1][1],state_rgb_led[0][1][0]}),  
    .rgb_led (rgb_led[1])  
);  
RGB_CTL	u2_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[0][2][5],state_rgb_led[0][2][4],state_rgb_led[0][2][3],state_rgb_led[0][2][2],state_rgb_led[0][2][1],state_rgb_led[0][2][0]}),  
    .rgb_led (rgb_led[2])  
);  
RGB_CTL	u3_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[0][3][5],state_rgb_led[0][3][4],state_rgb_led[0][3][3],state_rgb_led[0][3][2],state_rgb_led[0][3][1],state_rgb_led[0][3][0]}),  
    .rgb_led (rgb_led[3])  
);  
RGB_CTL	u4_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[0][4][5],state_rgb_led[0][4][4],state_rgb_led[0][4][3],state_rgb_led[0][4][2],state_rgb_led[0][4][1],state_rgb_led[0][4][0]}),  
    .rgb_led (rgb_led[4])  
);  
RGB_CTL	u5_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[0][5][5],state_rgb_led[0][5][4],state_rgb_led[0][5][3],state_rgb_led[0][5][2],state_rgb_led[0][5][1],state_rgb_led[0][5][0]}),  
    .rgb_led (rgb_led[5])  
);  
RGB_CTL	u6_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[1][0][5],state_rgb_led[1][0][4],state_rgb_led[1][0][3],state_rgb_led[1][0][2],state_rgb_led[1][0][1],state_rgb_led[1][0][0]}),  
    .rgb_led (rgb_led[6])  
);  
RGB_CTL	u7_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[1][1][5],state_rgb_led[1][1][4],state_rgb_led[1][1][3],state_rgb_led[1][1][2],state_rgb_led[1][1][1],state_rgb_led[1][1][0]}),  
    .rgb_led (rgb_led[7])  
);  
RGB_CTL	u8_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[1][2][5],state_rgb_led[1][2][4],state_rgb_led[1][2][3],state_rgb_led[1][2][2],state_rgb_led[1][2][1],state_rgb_led[1][2][0]}),  
    .rgb_led (rgb_led[8])  
);  
RGB_CTL	u9_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[1][3][5],state_rgb_led[1][3][4],state_rgb_led[1][3][3],state_rgb_led[1][3][2],state_rgb_led[1][3][1],state_rgb_led[1][3][0]}),  
    .rgb_led (rgb_led[9])  
);  
RGB_CTL	u10_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[1][4][5],state_rgb_led[1][4][4],state_rgb_led[1][4][3],state_rgb_led[1][4][2],state_rgb_led[1][4][1],state_rgb_led[1][4][0]}),  
    .rgb_led (rgb_led[10])  
);  
RGB_CTL	u11_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[1][5][5],state_rgb_led[1][5][4],state_rgb_led[1][5][3],state_rgb_led[1][5][2],state_rgb_led[1][5][1],state_rgb_led[1][5][0]}),  
    .rgb_led (rgb_led[11])  
);  
RGB_CTL	u12_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[2][0][5],state_rgb_led[2][0][4],state_rgb_led[2][0][3],state_rgb_led[2][0][2],state_rgb_led[2][0][1],state_rgb_led[2][0][0]}),  
    .rgb_led (rgb_led[12])  
);  
RGB_CTL	u13_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[2][1][5],state_rgb_led[2][1][4],state_rgb_led[2][1][3],state_rgb_led[2][1][2],state_rgb_led[2][1][1],state_rgb_led[2][1][0]}),  
    .rgb_led (rgb_led[13])  
);  
RGB_CTL	u14_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[2][2][5],state_rgb_led[2][2][4],state_rgb_led[2][2][3],state_rgb_led[2][2][2],state_rgb_led[2][2][1],state_rgb_led[2][2][0]}),  
    .rgb_led (rgb_led[14])  
);  
RGB_CTL	u15_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[2][3][5],state_rgb_led[2][3][4],state_rgb_led[2][3][3],state_rgb_led[2][3][2],state_rgb_led[2][3][1],state_rgb_led[2][3][0]}),  
    .rgb_led (rgb_led[15])  
);  
RGB_CTL	u16_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[2][4][5],state_rgb_led[2][4][4],state_rgb_led[2][4][3],state_rgb_led[2][4][2],state_rgb_led[2][4][1],state_rgb_led[2][4][0]}),  
    .rgb_led (rgb_led[16])  
);  
RGB_CTL	u17_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[2][5][5],state_rgb_led[2][5][4],state_rgb_led[2][5][3],state_rgb_led[2][5][2],state_rgb_led[2][5][1],state_rgb_led[2][5][0]}),  
    .rgb_led (rgb_led[17])  
);  
RGB_CTL	u18_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[3][0][5],state_rgb_led[3][0][4],state_rgb_led[3][0][3],state_rgb_led[3][0][2],state_rgb_led[3][0][1],state_rgb_led[3][0][0]}),  
    .rgb_led (rgb_led[18])  
);  
RGB_CTL	u19_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[3][1][5],state_rgb_led[3][1][4],state_rgb_led[3][1][3],state_rgb_led[3][1][2],state_rgb_led[3][1][1],state_rgb_led[3][1][0]}),  
    .rgb_led (rgb_led[19])  
);  
RGB_CTL	u20_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[3][2][5],state_rgb_led[3][2][4],state_rgb_led[3][2][3],state_rgb_led[3][2][2],state_rgb_led[3][2][1],state_rgb_led[3][2][0]}),  
    .rgb_led (rgb_led[20])  
);  
RGB_CTL	u21_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[3][3][5],state_rgb_led[3][3][4],state_rgb_led[3][3][3],state_rgb_led[3][3][2],state_rgb_led[3][3][1],state_rgb_led[3][3][0]}),  
    .rgb_led (rgb_led[21])  
);  
RGB_CTL	u22_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[3][4][5],state_rgb_led[3][4][4],state_rgb_led[3][4][3],state_rgb_led[3][4][2],state_rgb_led[3][4][1],state_rgb_led[3][4][0]}),  
    .rgb_led (rgb_led[22])  
);  
RGB_CTL	u23_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[3][5][5],state_rgb_led[3][5][4],state_rgb_led[3][5][3],state_rgb_led[3][5][2],state_rgb_led[3][5][1],state_rgb_led[3][5][0]}),  
    .rgb_led (rgb_led[23])  
);  
RGB_CTL	u24_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[4][0][5],state_rgb_led[4][0][4],state_rgb_led[4][0][3],state_rgb_led[4][0][2],state_rgb_led[4][0][1],state_rgb_led[4][0][0]}),  
    .rgb_led (rgb_led[24])  
);  
RGB_CTL	u25_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[4][1][5],state_rgb_led[4][1][4],state_rgb_led[4][1][3],state_rgb_led[4][1][2],state_rgb_led[4][1][1],state_rgb_led[4][1][0]}),  
    .rgb_led (rgb_led[25])  
);  
RGB_CTL	u26_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[4][2][5],state_rgb_led[4][2][4],state_rgb_led[4][2][3],state_rgb_led[4][2][2],state_rgb_led[4][2][1],state_rgb_led[4][2][0]}),  
    .rgb_led (rgb_led[26])  
);  
RGB_CTL	u27_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[4][3][5],state_rgb_led[4][3][4],state_rgb_led[4][3][3],state_rgb_led[4][3][2],state_rgb_led[4][3][1],state_rgb_led[4][3][0]}),  
    .rgb_led (rgb_led[27])  
);  
RGB_CTL	u28_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[4][4][5],state_rgb_led[4][4][4],state_rgb_led[4][4][3],state_rgb_led[4][4][2],state_rgb_led[4][4][1],state_rgb_led[4][4][0]}),  
    .rgb_led (rgb_led[28])  
);  
RGB_CTL	u29_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[4][5][5],state_rgb_led[4][5][4],state_rgb_led[4][5][3],state_rgb_led[4][5][2],state_rgb_led[4][5][1],state_rgb_led[4][5][0]}),  
    .rgb_led (rgb_led[29])  
);  
RGB_CTL	u30_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[5][0][5],state_rgb_led[5][0][4],state_rgb_led[5][0][3],state_rgb_led[5][0][2],state_rgb_led[5][0][1],state_rgb_led[5][0][0]}),  
    .rgb_led (rgb_led[30])  
);  
RGB_CTL	u31_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[5][1][5],state_rgb_led[5][1][4],state_rgb_led[5][1][3],state_rgb_led[5][1][2],state_rgb_led[5][1][1],state_rgb_led[5][1][0]}),  
    .rgb_led (rgb_led[31])  
);  
RGB_CTL	u32_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[5][2][5],state_rgb_led[5][2][4],state_rgb_led[5][2][3],state_rgb_led[5][2][2],state_rgb_led[5][2][1],state_rgb_led[5][2][0]}),  
    .rgb_led (rgb_led[32])  
);  
RGB_CTL	u33_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[5][3][5],state_rgb_led[5][3][4],state_rgb_led[5][3][3],state_rgb_led[5][3][2],state_rgb_led[5][3][1],state_rgb_led[5][3][0]}),  
    .rgb_led (rgb_led[33])  
);  
RGB_CTL	u34_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[5][4][5],state_rgb_led[5][4][4],state_rgb_led[5][4][3],state_rgb_led[5][4][2],state_rgb_led[5][4][1],state_rgb_led[5][4][0]}),  
    .rgb_led (rgb_led[34])  
);  
RGB_CTL	u35_RGB_CTL(  
    .sys_clk (sys_clk),  
    .sys_rst_n (sys_rst_n),  
    .rgb_data_in ({state_rgb_led[5][5][5],state_rgb_led[5][5][4],state_rgb_led[5][5][3],state_rgb_led[5][5][2],state_rgb_led[5][5][1],state_rgb_led[5][5][0]}),  
    .rgb_led (rgb_led[35])  
);

key_debounce u0_key_debounce(
    .key_clk        (sys_clk),
    .key_rst_n      (sys_rst_n),
    
    .key            (key[0]),
    .key_flag       (flag[0]),
    .key_value      (value[0])
);
key_debounce u1_key_debounce(
    .key_clk        (sys_clk),
    .key_rst_n      (sys_rst_n),
    
    .key            (key[1]),
    .key_flag       (flag[1]),
    .key_value      (value[1])
);
key_debounce u2_key_debounce(
    .key_clk        (sys_clk),
    .key_rst_n      (sys_rst_n),
    
    .key            (key[2]),
    .key_flag       (flag[2]),
    .key_value      (value[2])
);
key_debounce u3_key_debounce(
    .key_clk        (sys_clk),
    .key_rst_n      (sys_rst_n),
    
    .key            (key[3]),
    .key_flag       (flag[3]),
    .key_value      (value[3])
);
key_debounce u4_key_debounce(
    .key_clk        (sys_clk),
    .key_rst_n      (sys_rst_n),
    
    .key            (key[4]),
    .key_flag       (flag[4]),
    .key_value      (value[4])
);
key_debounce u5_key_debounce(
    .key_clk        (sys_clk),
    .key_rst_n      (sys_rst_n),
    
    .key            (key[5]),
    .key_flag       (flag[5]),
    .key_value      (value[5])
);
	
	



endmodule 