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

reg [9:0]x,y,addr;
reg [7:0] arr [107:0];
reg [9:0] load;
reg [2:0] cmd_reg;
reg state,next,cstate;//0:ok for next,1:process
always @(posedge clk or posedge reset) begin
    if(reset)begin
      state <= 1'd0;
    end
    else begin
      state <= next;
    end
end
always @(*) begin
    if (state == 0) begin
        next <= 1'd1;
    end
    else begin
      if ((cmd_reg == 1 && load == 15)|| (cmd_reg == 2 && load == 15)) begin//
        next <= 1'd0;
      end
      else begin
        next <= 1'd1;
      end
    end
end

always @(posedge clk or posedge reset) begin
    if(reset)begin
      output_valid <= 1'd0;
      busy <= 1'd0;
    end
    else begin
      if (state == 0) begin
          if(cmd_valid)begin
            if(cstate == 0&&cmd == 1)begin
              x <= 4;
              y <= 3;
            end
            cmd_reg <= cmd;
            load <= 10'd0;
            busy <= 1'd1;
          end
          output_valid <= 1'd0;
      end
      else begin
        case (cmd_reg)
            3'd0:begin//load
              busy <= 1;
              load <= load + 10'd1;
              if(load == 10'd107)begin
                load <= 10'd0;
                cmd_reg <= 3'd2;
              end
              arr[load] <= datain;
              x <= 6 - 2;
              y <= 5 - 2;
            end
            3'd1:begin//zoom in
              cstate <= 1;
              busy <= 1;
              load <= load + 10'd1;
              output_valid <= 1'd1;
              dataout <= arr[addr];
              if(load == 10'd1 || load == 2 ||load == 0||load == 6||load==4||load==5||load==8 || load == 9||load == 10||load == 12||load==13||load==14)begin
                x <= x + 1;
              end
              else if (load == 3||load == 7||load == 11) begin
                y <= y + 1;
                x <= x - 3;
              end
              else if (load == 15) begin
                  load <= 10'd0;
                  busy <= 1'd0;
                  x <= x -3;
                  y <= y -3;
              end
            end
            3'd2:begin//zoom fit
            cstate <= 0;
            busy <= 1;
              load <= load + 1;
              output_valid <= 1'd1;
              if (load == 0) begin
                dataout <= arr[13];
              end 
              else if(load == 1)begin
                dataout <= arr[16];
              end
              else if(load == 2)begin
                dataout <= arr[19];
              end
              else if(load == 3)begin
                dataout <= arr[22];
              end
              else if(load == 4)begin
                dataout <= arr[37];
              end
              else if(load == 5)begin
                dataout <= arr[40];
              end
              else if(load == 6)begin
                dataout <= arr[43];
              end
              else if(load == 7)begin
                dataout <= arr[46];
              end
              else if(load == 8)begin
                dataout <= arr[61];
              end
              else if(load == 9)begin
                dataout <= arr[64];
              end
              else if(load == 10)begin
                dataout <= arr[67];
              end
              else if(load == 11)begin
                dataout <= arr[70];
              end
              else if(load == 12)begin
                dataout <= arr[85];
              end
              else if(load == 13)begin
                dataout <= arr[88];
              end
              else if(load == 14)begin
                dataout <= arr[91];
              end
              else if(load == 15)begin
                dataout <= arr[94];
                load <= 10'd0;
                busy <= 1'd0;
              end
            end
            3'd3:begin//r
            busy <= 1;
            if (cstate == 1) begin
              if(x < 8)begin
                x <= x + 1;
              end
              else begin
                x <= x;
              end
              cmd_reg <= 3'd1;
            end
            else begin
              cmd_reg <= 3'd2;
            end
            end
            3'd4:begin//l
            busy <= 1;
            if (cstate == 1) begin
              if(x > 0)begin
                x <= x - 1;
              end
              else begin
                x <= x;
              end
              cmd_reg <= 3'd1;
            end
            else begin
              cmd_reg <= 3'd2;
            end
            end
            3'd5:begin//u
            busy <= 1;
            if (cstate == 1) begin
              if(y > 0)begin
                y <= y - 1;
              end
              else begin
                y <= y;
              end
              cmd_reg <= 3'd1;
            end
            else begin
              cmd_reg <= 3'd2;
            end
            end
            3'd6:begin//d
            busy <= 1;
            if (cstate == 1) begin
              if(y < 5)begin
                y <= y + 1;
              end
              else begin
                y <= y;
              end
              cmd_reg <= 3'd1;
            end
            else begin
              cmd_reg <= 3'd2;
            end
            end  
        endcase
      end
    end
end
always @(*) begin
    addr <= y*12 + x;
end
endmodule