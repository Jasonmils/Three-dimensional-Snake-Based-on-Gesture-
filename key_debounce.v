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
    input            key_clk,          //�ⲿ50Mʱ��
    input            key_rst_n,        //�ⲿ��λ�źţ�����Ч
    
    input            key,              //�ⲿ��������
    output reg       key_flag,         //����������Ч�ź�
	output reg       key_value         //���������������  
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
        if(key_reg != key)             //һ����⵽����״̬�����仯(�а��������»��ͷ�)
            delay_cnt <= 32'd1000000;  //����ʱ����������װ�س�ʼֵ������ʱ��Ϊ20ms��
        else if(key_reg == key) begin  //�ڰ���״̬�ȶ�ʱ���������ݼ�����ʼ20ms����ʱ
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
        if(delay_cnt == 32'd1) begin   //���������ݼ���1ʱ��˵�������ȶ�״̬ά����20ms
            key_flag  <= 1'b1;         //��ʱ�������̽���������һ��ʱ�����ڵı�־�ź�
            key_value <= key;          //���Ĵ��ʱ������ֵ
        end
        else begin
            key_flag  <= 1'b0;
            key_value <= key_value; 
        end  
    end   
end
    
endmodule 
