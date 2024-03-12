`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/26 22:10:40
// Design Name: 
// Module Name: dev_top
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


module SimulatedDevice(//统统高电平有效
    input sys_clk, //bind to P17 pin (100MHz system clock)
    input rx, //bind to N5 pin
    output tx, //bind to T4 pin
    input rst_de,//复位信号
    input turn_left_signal,//左转信号，
    input turn_right_signal,//右转信号，
    input move_forward_signal,//前进信号，
    input move_backward_signal,//后退信号
   //四个墙壁探测器
    output  front_detector,//前探测器
    output  back_detector,//后探测器
    output  left_detector,//左探测器
    output  right_detector,//右探测器

input [2:0]swi,//开关switch缩写
input thr,//油门
input clu,//离合
input bra,//刹车
input rgs,//倒车
output reg turn_left,//左转向灯
output reg turn_right,//右转向灯
output [7:0] seg_out, //模式灯和状态灯
output [3:0] seg_en,//使能端
output [7:0] seg1_out, //里程灯
output [3:0] seg1_en,//使能端

output  hsync,
output  vsync,
output [11:0]vga_rgb,//vga

output  bu//蜂鸣器

    );
    parameter off =4'b0000, no_st = 4'b0011, start = 4'b0111, movef = 4'b0110, moveb = 4'b0101;
    //手动模式五个状态，分别为关机、未起步、起步、前进、后退（可控制左右方向）
    parameter wait_command=4'b1000,left_turning=4'b1001,right_turning=4'b1010,circle_turning=4'b1011,keep_go=4'b1110,semi_movef=4'b1111;
    //分别为等待指令、左转、右转、掉头、保持前进、不可控制左右方向的前进
parameter not_going=3'b000,manual = 3'b100, semiAuto=3'b010, auto = 3'b001;
//开关四个状态，关机、手动、半自动、全自动
parameter one_second = 27'd10000_0000, zero = 27'b000_0000_0000_0000_0000_0000_0000;
parameter one_second1920 = 27'd9500_0000,one_second45 = 27'd8000_0000,one_second180 = 28'd18000_0000;
//参数，在100MHz下的一秒钟、零（用于重置计数器）
    reg [0:0]place_barrier_signal;//放信标
    reg [0:0]destroy_barrier_signal;//摧毁信标
    reg[27:0] keep_cnt=zero;//保持前进的计数器（通过它实现保持前进一段时间）
    reg[26:0] cnt=zero;//开机的计数器（通过它实现开开关一秒后开机）
    reg [7:0] in = 8'b00000000;//变成了reg类型，因为要后面更改in的值，实现小车各种功能，模板自带的
    reg[27:0]ti;//time的缩写，用它约束保持前进的时间，它设置多久，保持前进就多久
    reg[0:0]place;//用于保持前进后放不放信标，1为放，0为不放，默认不放
    wire [7:0] rec;//传递结果，已经帮我们写好了，通过它获取墙壁检测器的值
reg [3:0]stat = off;//状态
reg[27:0]turn_cnt=zero;//转向所用计数器

assign front_detector = rec[0];
assign back_detector = rec[3];
assign left_detector = rec[1];
assign right_detector = rec[2];
always @ (negedge sys_clk) begin//需要sys_clk及时更新，以更新stat，并累进时间

case(stat)//看状态是什么
	off: begin 
          in <= 8'b1000_0000;
          turn_left<=1'b1;
          turn_right<=1'b1;
    end
	movef: begin
	       in <= {2'b10, destroy_barrier_signal, place_barrier_signal, turn_right_signal, turn_left_signal, 1'b0, 1'b1};
           turn_left<=turn_left_signal;
           turn_right<=turn_right_signal;
	end
	moveb: begin
	       in <= {2'b10, destroy_barrier_signal, place_barrier_signal, turn_right_signal, turn_left_signal, 1'b1, 1'b0};
           turn_left<=turn_left_signal;
           turn_right<=turn_right_signal;
	end
	semi_movef: begin
           in <= {2'b10, destroy_barrier_signal, place_barrier_signal, 1'b0,1'b0, 1'b0, 1'b1};
           turn_left<=1'b0;
           turn_right<=1'b0;
    end
    left_turning:begin
           in <= {2'b10, destroy_barrier_signal, place_barrier_signal, 1'b0, 1'b1, 1'b0, 1'b0};
           turn_left<=1'b1;
           turn_right<=1'b0;
    end
    right_turning:begin
           in <= {2'b10, destroy_barrier_signal, place_barrier_signal, 1'b1, 1'b0, 1'b0, 1'b0};
           turn_left<=1'b0;
           turn_right<=1'b1;
    end 
    circle_turning:begin
           in <= {2'b10, destroy_barrier_signal, place_barrier_signal, 1'b0, 1'b1, 1'b0, 1'b0};
           turn_left<=turn_left_signal;
           turn_right<=1'b0;
    end
    keep_go:begin
           in <= {2'b10, destroy_barrier_signal, place_barrier_signal, 1'b0, 1'b0, 1'b0, 1'b1};
           turn_left<=1'b0;
           turn_right<=1'b0;
    end
    default: begin 
	       in <= 8'b1000_0000;
           turn_left<=1'b0;
           turn_right<=1'b0;
    end 
    endcase
end

//parameter off = 3'b000, no_st = 3'b011, start = 3'b111, movef = 3'b110, moveb = 3'b101;
//input thr,//油门
//input clu,//离合
//input bra,//刹车
//input rgs,//倒车
//    parameter off = 3'b000, no_st = 3'b011, start = 3'b111, movef = 3'b110, moveb = 3'b101;

always@(posedge sys_clk)begin
    case(swi)
        manual:begin//选择了手动驾驶挡位，要实现手动驾驶的对应效果
            place_barrier_signal<=1'b0;
            destroy_barrier_signal<=1'b0;
            if({stat,thr,bra,clu,rgs}=={no_st,4'b1010})
            stat<=start;//不知道为什么，这些地方不能放test，放了就无效
            else if({stat,thr,bra,clu,rgs}=={no_st,4'b1000})
              begin
                      stat<=off;
                      cnt<=zero;
                end
                  else if({stat,thr,bra,clu,rgs}=={no_st,4'b1001})
                            begin
                                    stat<=off;
                                    cnt<=zero;
                              end
    
            else if({stat,thr,bra,clu,rgs}=={start,4'b0100})
            stat<=no_st;
            else if({stat,thr,bra,clu,rgs}=={start,4'b0101})
             stat<=no_st;
             else if({stat,thr,bra,clu,rgs}=={start,4'b0110})
             stat<=no_st;
            else if({stat,thr,bra,clu,rgs}=={start,4'b0111})
              stat<=no_st;
               else if({stat,thr,bra,clu,rgs}=={start,4'b1100})
                 stat<=no_st;
                       else if({stat,thr,bra,clu,rgs}=={start,4'b1101})
                            stat<=no_st;
                                  else if({stat,thr,bra,clu,rgs}=={start,4'b1110})
                                       stat<=no_st;
                                             else if({stat,thr,bra,clu,rgs}=={start,4'b1111})
                                                  stat<=no_st;
            else if({stat,thr,bra,clu,rgs}=={start,4'b1001})
            stat<=moveb;
            else if({stat,thr,bra,clu,rgs}=={start,4'b1000})
            stat<=movef;
            else if({stat,thr,bra,clu,rgs}=={moveb,4'b0001})
            stat<=start;
            else if({stat,thr,bra,clu,rgs}=={moveb,4'b1011})
            stat<=start;
            else if({stat,thr,bra,clu,rgs}=={moveb,4'b1101})
            stat<=no_st;
            else if({stat,thr,bra,clu,rgs}=={moveb,4'b1000})
            begin
            stat<=off;
            cnt<=zero;
            end
            else if({stat,thr,bra,clu,rgs}=={movef,4'b0000})
            stat<=start;
            else if({stat,thr,bra,clu,rgs}=={movef,4'b1010})
            stat<=start;
            else if({stat,thr,bra,clu,rgs}=={movef,4'b1100})
            stat<=no_st;
            else if({stat,thr,bra,clu,rgs}=={movef,4'b1001})
             begin
                      stat<=off;
                      cnt<=zero;
             end
            else if({stat,thr,bra,clu,rgs}==  {off,4'b0000})
             begin
                  if(cnt<=one_second)
                        begin
                         cnt=cnt+1'b1;       
                       end
                       else stat<=no_st;          
                end//else if的
            else stat<=stat;
            end //case1的
            
      semiAuto:begin
                    place_barrier_signal<=1'b0;
                    destroy_barrier_signal<=1'b0;
                  //    parameter keep_go=4'b1111;
      //             front_detector <= rec[0];
      //                      back_detector <= rec[3];
      //                      left_detector <= rec[1];
      //                      right_detector <= rec[2];
                  casex({stat,front_detector,back_detector,left_detector,right_detector})
      //                parameter wait_command=4'b1000,left_turning=4'b1001,right_turning=4'b1010,circle_turning=4'b1011;
      //               parameter semi_start=4'b1100; 
      //    input turn_left_signal
      //input turn_right_signal,
      //input move_forward_signal,
      //input move_backward_signal,
                     {off,4'bxxxx}:begin
                          if(cnt<=one_second)
                              begin
                              cnt=cnt+1'b1;
                              end
                          else begin
                           stat<=wait_command;
                           cnt<=zero;
                           keep_cnt <=zero;
                           turn_cnt<= zero;
                           end//半自动驾驶小车将在等待一秒后，进入前进状态
                      end//case1
                         {keep_go,4'bxxxx}:begin
                                          if(keep_cnt>=one_second1920)begin
                                             stat<=semi_movef;
                                             keep_cnt<=zero;
                                          end
                                            else begin
                                              keep_cnt=keep_cnt+1'b1;
                                             end
                                          end
                      
                      {wait_command,4'bxxxx}:begin
                        case({turn_left_signal,turn_right_signal,move_forward_signal,move_backward_signal})
                            4'b1000: stat<=left_turning;
                            4'b0100: stat<=right_turning;
                            4'b0010: stat<=keep_go;
                            4'b0001: stat<=circle_turning;
                            default: stat<=stat;
                        endcase
                        keep_cnt <=zero;
                        turn_cnt<= zero;
                      end//case2
                      //reg[25:0]turn_cnt=zero;
                      {left_turning,4'bxxxx}:begin
                          if(turn_cnt>=one_second45)begin
                          stat<=keep_go;
                          turn_cnt<=0;
                          end
                           else begin
                             turn_cnt=turn_cnt+1'b1;
                           end
                      end
                      
                      {right_turning,4'bxxxx}:begin
                          if(turn_cnt>=one_second45)begin
                          stat<=keep_go;
                          turn_cnt<=zero;
                      end
                      else begin
                          turn_cnt=turn_cnt+1'b1;
                          end
                     end
                   
                       {circle_turning,4'bxxxx}:begin
                                       if(turn_cnt>=one_second180)begin
                                       stat<=keep_go;
                                       turn_cnt<=zero;
                                   end
                                   else begin
                                       turn_cnt=turn_cnt+1'b1;
                                       end
                                  end
                      
                      
                      {semi_movef,4'b0000}:begin
                          stat<=wait_command;
                      end
                      {semi_movef,4'b0001}:begin
                          stat<=wait_command;
                      end
                      {semi_movef,4'b0010}:begin
                          stat<=wait_command;
                      end
                       {semi_movef,4'b0011}:begin
                          stat<=semi_movef;
                       end
                       {semi_movef,4'b0100}:begin
                         stat<=wait_command;
                         end
                         {semi_movef,4'b0101}:begin
                         stat<=semi_movef;
                         end
                         {semi_movef,4'b0110}:begin
                         stat<=semi_movef;
                         end
                         {semi_movef,4'b0111}:begin
                         stat<=semi_movef;
                         end
                         {semi_movef,4'b1000}:begin
                         stat<=wait_command;
                         end
                         {semi_movef,4'b1001}:begin
                         stat<=left_turning;
                         end
                         {semi_movef,4'b1010}:begin
                         stat<=right_turning;
                         end
                         {semi_movef,4'b1011}:begin
                         stat<=wait_command;
                         end
                         {semi_movef,4'b1100}:begin
                         stat<=wait_command;
                         end
                         {semi_movef,4'b1101}:begin
                         stat<=left_turning;
                         end
                         {semi_movef,4'b1110}:begin
                         stat<=right_turning;
                         end
                         {semi_movef,4'b1111}:begin
                         stat<=off;
                         end
                   
                         default:stat<=stat;
                          
                      
                  endcase
                  //parameter not_going=3'b000;
                  end
                  
          auto: begin
                
                casex({stat, front_detector, back_detector, left_detector, right_detector})
                    {off,4'bxxxx}:begin
                          place_barrier_signal<=1'b0;
                          destroy_barrier_signal<=1'b0;
                          ti <= zero;
                          place <= 1'b0;
                          if(cnt<=one_second)
                                cnt=cnt+1'b1;
                          else begin
                                stat<=semi_movef;
                                cnt<=zero;
                          end//自动驾驶小车将在等待一秒后，进入前进状态
                    end
                    {semi_movef, 4'b0000}: begin
                        stat <= right_turning;
                        ti <= one_second*17/20;
                        place <= 1'b1;
                    end
                    {semi_movef, 4'b0010}: begin
                        stat <= right_turning;
                        ti <= one_second*17/20;
                        place <= 1'b1;
                    end
                    {semi_movef, 4'b0100}: begin
                        stat <= right_turning;
                        ti <= one_second*17/20;
                        place <= 1'b1;
                    end
                    {semi_movef, 4'b0110}: begin
                        stat <= right_turning;
                        ti <= one_second*17/20;
                        place <= 1'b0;
                    end
                    {semi_movef, 4'b1000}: begin
                        stat <= right_turning;
                        ti <= one_second*17/20;
                        place <= 1'b1;
                    end
                    {semi_movef, 4'b1010}: begin
                        stat <= right_turning;
                        ti <= one_second*19/20;
                        place <= 1'b0;
                    end
                    {semi_movef, 4'b1100}: begin
                        stat <= right_turning;
                        ti <= one_second*19/20;
                        place <= 1'b0;
                    end
                    {semi_movef, 4'b1110}: begin
                        stat <= right_turning;
                        ti <= one_second*17/20;
                        place <= 1'b0;
                    end
                    {semi_movef, 4'b0001}: begin
                        ti <= one_second*19/20;
                        place <= 1'b1;
                        stat <= keep_go;
                    end
                    {semi_movef, 4'b0011}: begin
                        ti <= ti;
                        place <= place;
                        stat <= semi_movef;
                    end
                    {semi_movef, 4'b0101}: begin
                        ti <= ti;
                        place <= place;
                        stat <= semi_movef;
                    end
                    {semi_movef, 4'b0111}: begin
                        ti <= ti;
                        place <= place;
                        stat <= semi_movef;
                    end
                    {semi_movef, 4'b1001}: begin
                        stat <= left_turning;
                        ti <= one_second*17/20;
                        place <= 1'b0;
                    end
                    {semi_movef, 4'b1011}: begin
                        ti <= one_second*3/20;
                        place <= 1'b0;
                        stat <= keep_go;
                    end
                    {semi_movef, 4'b1101}: begin
                        stat <= left_turning;
                        ti <= one_second*17/20;
                        place <= 1'b0;
                    end
                    {semi_movef, 4'b1111}: begin
                        stat <= left_turning;
                        ti <= one_second*17/20;
                        place <= 1'b0;
                    end
                    {left_turning,4'bxxxx}:begin
                         if(turn_cnt>=one_second*4/5)begin
                              stat<=keep_go;
                              turn_cnt<=0;
                         end
                         else begin
                              turn_cnt=turn_cnt+1'b1;
                         end
                    end
                    {right_turning, 4'bxxxx}: begin
                        if(turn_cnt>=one_second*4/5)begin
                              stat<=keep_go;
                              turn_cnt<=zero;
                        end
                        else begin
                             turn_cnt=turn_cnt+1'b1;
                        end
                    end
                    {keep_go, 4'bxxxx}: begin
                        if(keep_cnt>=ti)begin
                            keep_cnt<=zero;
                            place_barrier_signal <=1'b0;
                            if({front_detector, back_detector, left_detector, right_detector} == 4'b1011) 
                                  stat <= circle_turning;
                            else
                                  stat<=semi_movef;
                                  
                        end
                        else begin
                              if(place & keep_cnt==ti*4/5) place_barrier_signal <=1'b1;
                              keep_cnt=keep_cnt+1'b1;
                        end
                    end
                    
                    {circle_turning,4'bxxxx}:begin
                         if(turn_cnt>={one_second,1'b0}*9/10)begin
                               destroy_barrier_signal <= 1'b0;
                               turn_cnt<=zero;
                               stat <= semi_movef;
                         end
                         else begin
                               if(turn_cnt=={one_second,1'b0}*4/5) destroy_barrier_signal <= 1'b1;
                               turn_cnt=turn_cnt+1'b1;
                         end
                    end
                    default: begin
                        stat<= stat;
                        place_barrier_signal <= place_barrier_signal;
                        destroy_barrier_signal <= destroy_barrier_signal;
                    end
                endcase
          end
                  
         not_going:begin
                   cnt<=zero;
                   stat<=off;
                   place_barrier_signal <= 1'b0;
                   destroy_barrier_signal <= 1'b0;
                   keep_cnt <= zero;
                   ti <= zero;
                   place <= 1'b0;
                   turn_cnt<=zero;
         end
                  
                  
                default: stat<=stat;
            endcase
          end  
 reg [3:0] state;
 reg [2:0] fen;
 always @(posedge sys_clk) begin
    if(rst_de) fen <= 0;
    else begin
        if(fen!=3'd4) begin
            fen <=fen+1'b1;
            state <= state;
        end
        else begin
            fen <= 0;
            state <=stat;
        end
    end
 end
                  
       
           
        seg_mod se1(sys_clk,swi,stat,seg_out,seg_en);
        seg2_mod se2(sys_clk,stat,seg1_out,seg1_en);
        uart_top md(.clk(sys_clk), .rst(0), .data_in(in), .data_rec(rec), .rxd(rx), .txd(tx));
        vga V_G_A(sys_clk , rst_de ,  state, swi ,   hsync , vsync , vga_rgb );
        buzzer Buzzer(sys_clk, stat, bu);
    
endmodule




