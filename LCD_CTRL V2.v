`timescale 1ns/1ps
module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output reg  [7:0]   dataout;
output reg         output_valid;
output reg         busy;
reg [7:0]buffer[107:0];
reg [8:0] x,y,addr;
reg [9:0] load_cnt;
reg [2:0] cmd_reg,state,cur,next;//0:wait 1:process 0:zoom in 1:zoom fit
always @(*) begin
  case (cur)
    0:begin
      if(cmd_valid == 0)begin
        next = 0;
      end
      else begin
        next = 1;
      end
    end
    1:begin
      if((cmd_reg == 1||cmd_reg==2)&&load_cnt == 15)begin
        next = 0;
      end
      else begin
        next = 1;
      end
    end
  endcase
end
always @(posedge clk or posedge reset) begin
    if(reset)begin
      x <= 4;
      y <= 3;
      load_cnt <= 0;
      output_valid <= 0;
      busy <= 0;
      cur <= 0;
      state <= 1;
    end
    else begin
      cur <= next;
      if(cur == 0)begin
        if (cmd_valid == 1) begin
          busy <= 1;
          cmd_reg <= cmd;
        end
        output_valid <= 0;
      end
      else begin
        case(cmd_reg)
        0:begin//load
          load_cnt <= load_cnt + 1;
          buffer[load_cnt] <= datain;
          if(load_cnt == 107)begin
            load_cnt <= 0;
            cmd_reg <= 2;
          end
        end
        1:begin
          state <= 0;
          load_cnt <= load_cnt + 10'd1;
          output_valid <= 1'd1;
          dataout <= buffer[addr];
          if(load_cnt == 10'd1 || load_cnt == 2 ||load_cnt == 0||load_cnt == 6||load_cnt==4||load_cnt==5||load_cnt==8 || load_cnt == 9||load_cnt == 10||load_cnt == 12||load_cnt==13||load_cnt==14)begin
            x <= x + 1;
          end
          else if (load_cnt == 3||load_cnt == 7||load_cnt == 11) begin
            y <= y + 1;
            x <= x - 3;
          end
          else if (load_cnt == 15) begin
              load_cnt <= 10'd0;
              busy <= 1'd0;
              x <= x -3;
              y <= y -3;
          end  
        end
        2:begin
          x <= 4;
          y <= 3;
          state <= 1;
          load_cnt <= load_cnt + 1;
          output_valid <= 1'd1;
          if (load_cnt == 0) begin
            dataout <= buffer[13];
          end 
          else if(load_cnt == 1)begin
            dataout <= buffer[16];
          end
          else if(load_cnt == 2)begin
            dataout <= buffer[19];
          end
          else if(load_cnt == 3)begin
            dataout <= buffer[22];
          end
          else if(load_cnt == 4)begin
            dataout <= buffer[37];
          end
          else if(load_cnt == 5)begin
            dataout <= buffer[40];
          end
          else if(load_cnt == 6)begin
            dataout <= buffer[43];
          end
          else if(load_cnt == 7)begin
            dataout <= buffer[46];
          end
          else if(load_cnt == 8)begin
            dataout <= buffer[61];
          end
          else if(load_cnt == 9)begin
            dataout <= buffer[64];
          end
          else if(load_cnt == 10)begin
            dataout <= buffer[67];
          end
          else if(load_cnt == 11)begin
            dataout <= buffer[70];
          end
          else if(load_cnt == 12)begin
            dataout <= buffer[85];
          end
          else if(load_cnt == 13)begin
            dataout <= buffer[88];
          end
          else if(load_cnt == 14)begin
            dataout <= buffer[91];
          end
          else if(load_cnt == 15)begin
            dataout <= buffer[94];
            load_cnt <= 10'd0;
            busy <= 1'd0;
          end
        end
        3:begin
          if (state == 0) begin//zoom in
            if(x<8)begin
              x <= x+1;
            end
            cmd_reg <= 1;
          end
          else begin
            cmd_reg <= 2;
          end
        end
        4:begin
          if (state == 0) begin//zoom in
            if(x>0)begin
              x <= x-1;
            end
            cmd_reg <= 1;
          end
          else begin
            cmd_reg <= 2;
          end
        end
        5:begin
          if (state == 0) begin//zoom in
            if(y>0)begin
              y <= y-1;
            end
            cmd_reg <= 1;
          end
          else begin
            cmd_reg <= 2;
          end
        end
        6:begin
          if (state == 0) begin//zoom in
            if(y<5)begin
              y <= y+1;
            end
            cmd_reg <= 1;
          end
          else begin
            cmd_reg <= 2;
          end
        end
        endcase
      end
    end
end
always @(*) begin
  addr = y*12+x;
end
endmodule