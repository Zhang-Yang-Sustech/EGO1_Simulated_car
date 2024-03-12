`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/13 18:59:55
// Design Name: 
// Module Name: seg_mod
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


module seg_mod(
input clk,//连接时钟
input [2:0]sw,//连接开关
input [3:0]state,//当前状态
output reg [7:0] seg1_out,//七段数码管 
output reg [3:0] seg1_en//使能端
);
//与top文件里的状态一致
parameter off = 4'b0000, no_st = 4'b0011, start = 4'b0111, movef = 4'b0110, moveb = 4'b0101; 
parameter wait_command = 4'b1000, left_turning = 4'b1001, right_turning = 4'b1010, circle_turning = 4'b1011,keep_go=4'b1110,semi_movef=4'b1111;

//切换显示灯的时间
parameter c = 27'd10000_0, h = 27'd5_0000, zero = 27'b0;
reg [26:0] cnt = zero;
    always @ (negedge clk) begin
        case(seg1_en)
        4'b0100:
            case(state)
                        off: seg1_out <= 8'b11111100;//O.
                        no_st: seg1_out <= 8'b00101010;//n.
                        start: seg1_out <= 8'b10110110;//S.
                        movef: seg1_out <= 8'b10001110;//F.
                        keep_go: seg1_out <= 8'b10001110;//F.
                        semi_movef: seg1_out <= 8'b10001110;//F.
                        moveb: seg1_out <= 8'b11111110;//B.
                        wait_command: seg1_out <= 8'b10011100;//C.
                        left_turning: seg1_out <= 8'b00011100;//L.
                        right_turning: seg1_out <= 8'b00001010;//r.
                        circle_turning: seg1_out <= 8'b00111010;//o.
                        default: seg1_out <= 8'b00000001;
            endcase
        4'b1000:
            case(sw)
                            3'b100: seg1_out <= 8'b11111111;//B.
                            3'b010: seg1_out <= 8'b10110111;//S.
                            3'b001: seg1_out <= 8'b11101111;//A.
                            default: seg1_out <= 8'b00000001;
            endcase    
       default: seg1_out <= 8'b10000000;
       endcase    
    end
    
    always @ (posedge clk) begin
        if(cnt!=c) cnt <= cnt +1'b1;
        else cnt <= zero; 
        if(cnt < h) seg1_en <= 4'b0100;
        else seg1_en <= 4'b1000;
    end
endmodule
