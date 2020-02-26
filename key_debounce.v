`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/24 16:15:28
// Design Name: 
// Module Name: key_debounce
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
module key_debounce(
    input            key_clk,          //外部50M时钟
    input            key_rst_n,        //外部复位信号，低有效
    
    input            key,              //外部按键输入
    output reg       key_flag,         //按键数据有效信号
	output reg       key_value         //按键消抖后的数据  
    );
    
reg [31:0] delay_cnt;
reg        key_reg;

always @(posedge key_clk) begin 
    if (!key_rst_n) begin 
        key_reg   <= 1'b1;
        delay_cnt <= 32'd0;
    end
    else begin
        key_reg <= key;
        if(key_reg != key)             //一旦检测到按键状态发生变化(有按键被按下或释放)
            delay_cnt <= 32'd1000000;  //给延时计数器重新装载初始值（计数时间为20ms）
        else if(key_reg == key) begin  //在按键状态稳定时，计数器递减，开始20ms倒计时
                 if(delay_cnt > 32'd0)
                     delay_cnt <= delay_cnt - 1'b1;
                 else
                     delay_cnt <= delay_cnt;
             end           
    end   
end

always @(posedge key_clk) begin 
    if (!key_rst_n) begin 
        key_flag  <= 1'b0;
        key_value <= 1'b1;          
    end
    else begin
        if(delay_cnt == 32'd1) begin   //当计数器递减到1时，说明按键稳定状态维持了20ms
            key_flag  <= 1'b1;         //此时消抖过程结束，给出一个时钟周期的标志信号
            key_value <= key;          //并寄存此时按键的值
        end
        else begin
            key_flag  <= 1'b0;
            key_value <= key_value; 
        end  
    end   
end
    
endmodule 
