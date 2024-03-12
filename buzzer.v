`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/07 20:23:47
// Design Name: 
// Module Name: buzzer
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


//以下为小车用蜂鸣器
module buzzer(
  input clk,//时钟输入
  input [3:0]state, //按键输入
  output reg buzzer //驱动蜂鸣器
);

 parameter off =4'b0000, no_st = 4'b0011, start = 4'b0111, movef = 4'b0110, moveb = 4'b0101;
    //手动模式五个状态，分别为关机、未起步、起步、前进、后退（可控制左右方向）
 parameter wait_command=4'b1000,left_turning=4'b1001,right_turning=4'b1010,circle_turning=4'b1011,keep_go=4'b1110,semi_movef=4'b1111;
    //分别为等待指令、左转、右转、掉头、保持前进、不可控制左右方向的前进
parameter y0 = 16'b1011011110011000, y1 = 16'b1010010000010000, y2 = 16'b0111100100011000, y3 = 16'b0110000110101000;
parameter c0 = 8'b01111001                   ,c1 =  8'b01111101                 , c2 = 8'b10110100                  , c3 = 8'b11100110;
reg[15:0] y;
reg[7:0]c; 
reg [0:0] stat_transform_front;
reg [16:0]	cnt0;	//计数每个音符对应的时序周期
reg [7:0]	cnt1;	//计数每个音符重复次数


always @(posedge clk) begin
  case(state)
    start: stat_transform_front <=1'b1;
    default: stat_transform_front<=1'b0;
  endcase
end

always @(posedge clk) begin
  if(stat_transform_front) begin
        if(cnt1 < c )begin//周期数
              if(cnt0 < y )begin//时序周期半数
                    buzzer <= 1'b1;
                    cnt0 <= cnt0 +1'b1;
              end 
              else if (cnt0<y0*2)begin
                    buzzer <= 1'b0;
                    cnt0 <= cnt0 +1'b1;
              end 
              else begin 
                    cnt0 <= 0;
                    cnt1 <= cnt1+1'b1;
              end
         end     
         else case(c)
                    c0: begin 
                        c <= c1;
                        y <= y1;
                    end
                    c1: begin 
                        c <= c2;
                        y <= y2;
                    end
                    c2: begin 
                        c <= c3;
                        y <= y3;
                    end
                endcase
   end             
   else begin
        c <= c0;
        y <= y0;
        cnt0 <= 0;
        cnt1 <= 0;
   end      
end
     
endmodule
