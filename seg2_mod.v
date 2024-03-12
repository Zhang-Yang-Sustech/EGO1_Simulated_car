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


module seg2_mod(
input clk,//连接时钟
input [3:0]state,//当前状态
output reg [7:0] seg1_out,//七段数码管 
output reg [3:0] seg1_en//使能端
);
//与top中状态一致
parameter off = 4'b0000, no_st = 4'b0011, start = 4'b0111, movef = 4'b0110, moveb = 4'b0101,keep_go=4'b1110,semi_movef=4'b1111; 

//四个灯切换的时间
parameter f = 30'd13200_00, o = 30'd9900_00, t = 30'd6600_00, tr = 30'd3300_00, zero = 30'b0;

//一秒、十秒、一百秒、0.1秒
parameter one = 37'd10000_0000, ten = 37'd10000_0000_0, s = 37'd10000_0000_00, dian = 37'd10000_000;
reg [36:0] cnt = zero;//里程计数器
reg [29:0] sh = zero;//换管计数器

always @ (posedge clk) begin
    case (state)
        movef: begin
            cnt <= cnt+3'd1;
        end
        moveb: begin
            cnt <= cnt+3'd1;
        end
        keep_go: begin
            cnt <= cnt+3'd1;
        end
        semi_movef: begin
            cnt <= cnt+3'd1;
        end
        off: 
            cnt <= zero;
        default:
            cnt <= cnt;
    endcase
end

always @ (posedge clk) begin
    case(seg1_en)
        4'b0001:begin
                case((cnt-one*(cnt/one))/dian)
                    4'd0: seg1_out <= 8'b11111100;//0
                    4'd1: seg1_out <= 8'b01100000;//1
                    4'd2: seg1_out <= 8'b11011010;//2
                    4'd3: seg1_out <= 8'b11110010;//3
                    4'd4: seg1_out <= 8'b01100110;//4
                    4'd5: seg1_out <= 8'b10110110;//5
                    4'd6: seg1_out <= 8'b10111110;//6
                    4'd7: seg1_out <= 8'b11100000;//7
                    4'd8: seg1_out <= 8'b11111110;//8
                    4'd9: seg1_out <= 8'b11110110;//9
                endcase
        end
        
        4'b0010:begin
                case((cnt-ten*(cnt/ten))/one)
                    4'd0: seg1_out <= 8'b11111101;//0
                    4'd1: seg1_out <= 8'b01100001;//1
                    4'd2: seg1_out <= 8'b11011011;//2
                    4'd3: seg1_out <= 8'b11110011;//3
                    4'd4: seg1_out <= 8'b01100111;//4
                    4'd5: seg1_out <= 8'b10110111;//5
                    4'd6: seg1_out <= 8'b10111111;//6
                    4'd7: seg1_out <= 8'b11100001;//7
                    4'd8: seg1_out <= 8'b11111111;//8
                    4'd9: seg1_out <= 8'b11110111;//9
                endcase
        end

        4'b0100:begin
                case((cnt - s*(cnt/s))/ten)
                    4'd0: seg1_out <= 8'b11111100;//0
                    4'd1: seg1_out <= 8'b01100000;//1
                    4'd2: seg1_out <= 8'b11011010;//2
                    4'd3: seg1_out <= 8'b11110010;//3
                    4'd4: seg1_out <= 8'b01100110;//4
                    4'd5: seg1_out <= 8'b10110110;//5
                    4'd6: seg1_out <= 8'b10111110;//6
                    4'd7: seg1_out <= 8'b11100000;//7
                    4'd8: seg1_out <= 8'b11111110;//8
                    4'd9: seg1_out <= 8'b11110110;//9
                endcase
        end

        4'b1000:begin
                case(cnt/s)
                    4'd0: seg1_out <= 8'b11111100;//0
                    4'd1: seg1_out <= 8'b01100000;//1
                    4'd2: seg1_out <= 8'b11011010;//2
                    4'd3: seg1_out <= 8'b11110010;//3
                    4'd4: seg1_out <= 8'b01100110;//4
                    4'd5: seg1_out <= 8'b10110110;//5
                    4'd6: seg1_out <= 8'b10111110;//6
                    4'd7: seg1_out <= 8'b11100000;//7
                    4'd8: seg1_out <= 8'b11111110;//8
                    4'd9: seg1_out <= 8'b11110110;//9
                endcase
        end

    endcase
end

always @ (negedge clk) begin
    if(sh<f) sh <= sh+1'b1;
    else sh <= zero;
    if(sh<tr) seg1_en <= 4'b0001;
    else if (sh<t) seg1_en <= 4'b0010;
    else if (sh<o) seg1_en <= 4'b0100;
    else seg1_en <= 4'b1000;
end
endmodule
