`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/24 16:14:08
// Design Name: 
// Module Name: RGB_CTL
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RGB_CTL(
	
	input		sys_clk ,
	input		sys_rst_n ,
	input	[143:0] rgb_data_in ,
	
	output  reg rgb_led	
);

reg [4:0] cnt_rgb_bit  ;
reg [9:0] cnt_led_num  ;

reg flag_one_time ;

wire [7:0] num_rgb_data_in ;
assign num_rgb_data_in = cnt_led_num[2:0] * 5'd24 + cnt_rgb_bit ;

reg	[9:0] counter_100k ;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        counter_100k <= 10'd0;  end
    else if (counter_100k < 10'd66)
        counter_100k <= counter_100k + 1'b1;
    else
        counter_100k <= 10'd0;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
		rgb_led <= 1'b0 ;
		cnt_rgb_bit <= 5'd0 ;
		cnt_led_num <= 10'd0 ; 
		flag_one_time<= 1'd0 ;
		end
		
    else if(counter_100k == 10'd1) begin	
		if( cnt_led_num >= 10'd6 )  begin
			cnt_led_num <= cnt_led_num + 1'd1 ;
			if(cnt_led_num == 10'd500)
				cnt_led_num <= 10'd0 ; 
		end		
		else begin
			rgb_led <= 1'b1 ;
			flag_one_time <= 1'b1 ;			
		end		
	end
	
	else if( (flag_one_time) &&(((counter_100k == 10'd44)&&(rgb_data_in[num_rgb_data_in] == 1'b1)) || ((counter_100k == 10'd22)&&(rgb_data_in[num_rgb_data_in] == 1'b0))) ) begin //高电平归零
			rgb_led <= 1'b0 ;
			cnt_rgb_bit <= cnt_rgb_bit +1'b1 ;
			flag_one_time <= 1'd0 ;
			if (cnt_rgb_bit == 5'd23) begin   //24位归零				
				cnt_rgb_bit <= 5'd0 ;
				cnt_led_num <= cnt_led_num + 1'd1 ;	 end			
	end
	
    else  
		rgb_led <= rgb_led ;   
end
endmodule 
