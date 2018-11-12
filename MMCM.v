`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 01/28/2018 03:26:51 PM
// Design Name: 
// Module Name: MMCM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Dependencies: 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////
module MMCM(
    input [11:0] sw,
    output reg CS,
    input SDO,
    output wire SCK,
    output NC,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaBlue,
    output reg [3:0] vgaGreen,
    output [6:0] seg,
    output [3:0] an,
    input clk_fpga,
    input reset,
    output Hsync,
    output Vsync
    );
    reg [4:0] count1;
    reg[7:0] accept1;
    wire clk_1M;
    wire clk_5Hz;
    reg [14:0] accept;
    reg [4:0] counter_1M;
    reg [22:0] counter_5Hz;
    reg [3:0] count;
    wire [7:0] vercount;
    wire clk_25M;
    wire [10:0] Vcount;
    wire [10:0] Hcount;
    wire blank;
    wire [7:0] display;
    reg [13:0] counter_2_5kHz;
    wire clk_2_5kHz;
      clk_wiz_0 instance_name
     (
      // Clock out ports
      .clk_25M(clk_25M),     // output clk_25M
      // Status and control signals
      .reset(reset), // input reset
      .locked(locked),       // output locked
     // Clock in ports
      .clk_in1(clk_fpga));      // input clk_in1
  // INST_TAG_END ------ End INSTANTIATION Template ---------
  
  vga_controller_640_60 v (.rst(reset),.pixel_clk(clk_25M),.HS(Hsync), .VS(Vsync), .hcount(Hcount),.vcount(Vcount),.blank(blank));
  
  seven_seg s (.an(an), .seg(seg), .sw(display), .clk(clk_2_5kHz), .reset(reset));
  assign SCK= clk_1M;
  assign display = accept1;
  assign clk_2_5kHz = (counter_2_5kHz ==0)?1:0 ;
    always @(posedge clk_25M, posedge reset)  //Creating a 2.5kHz clock from 25MHz
    begin
    if(reset)
        counter_2_5kHz <= 0;
    else if(counter_2_5kHz == 5000-1)
        counter_2_5kHz <= 0;
    else 
        counter_2_5kHz <= counter_2_5kHz + 1;
    end
    always @(posedge clk_25M, posedge reset) //Designing a ADC SCLK clock at 1MHz
        begin
        if(reset)
            counter_1M <= 0;
        else if(counter_1M == 25-1)
            counter_1M <= 0;
        else 
            counter_1M <= counter_1M + 1;
        end
    always @(posedge clk_25M, posedge reset) //Creating a 5Hz clock to capture light sensor value every 200ms
        begin
        if(reset)
            counter_5Hz <=0;
        else if(counter_5Hz == 2_500_000-1)
            counter_5Hz <= 0;
        else
            counter_5Hz <= counter_5Hz +1;
        end
    assign clk_1M = (counter_1M < 12);
    assign clk_5Hz = (counter_5Hz == 0) ? 1'b1 : 1'b0; // 10Hz
    always @(posedge clk_1M, posedge reset)
    begin
        if (reset)
            begin
                count1 <= 0;
                CS<=1;
                accept <= 0;
                accept1 <= 0;
            end
        else //if (SCK)    
            begin
                if(clk_5Hz == 1'b1 && count1 == 5'b0) 
                    CS <= 0;
                else if(count1 == 15) begin
                    accept1 <= accept[10:3];
                    count1 <= 0;
                    CS <= 1;
                    end
                else
                    begin
                        accept <= {accept[13:0], SDO};
                        count1 <= count1 + 1;
                        CS <= 0;
                   end
            end
    end
    
    always @(posedge clk_25M, posedge reset)
    if (reset)
        begin
            vgaGreen = 4'b0000;
            vgaBlue  = 4'b0000;
            vgaRed   = 4'b0000;
        end
    else
        begin
            if(blank == 1'b1) 
                begin
                    vgaGreen = 4'b0000;
                    vgaBlue = 4'b0000;
                    vgaRed = 4'b0000;
                end
            else 
                begin
                case(sw[4:0])                
                5'b00001: begin
                vgaGreen = 4'b1111;
                vgaBlue  = 4'b0000;
                vgaRed   = 4'b0000;
                end
                
                5'b00010: begin
                if(Vcount < 60)
                    begin
                    vgaGreen = 4'b1111;
                    vgaBlue  = 4'b0000;
                    vgaRed   = 4'b1111;    
                    end
                else if(Vcount < 120)
                    begin
                    vgaGreen = 4'b1111;
                    vgaBlue  = 4'b1111;
                    vgaRed   = 4'b0000;
                    end
                else if(Vcount < 180)
                    begin
                    vgaGreen = 4'b1000;
                    vgaBlue  = 4'b0000;
                    vgaRed   = 4'b1000;
                    end     
                else if(Vcount < 240)
                    begin
                    vgaGreen = 4'b0000;
                    vgaBlue  = 4'b1000;
                    vgaRed   = 4'b1000;
                    end
                else if(Vcount < 300)
                    begin
                    vgaGreen = 4'b1000;
                    vgaBlue  = 4'b0110;
                    vgaRed   = 4'b0000;
                    end             
                else if(Vcount < 360)
                    begin
                    vgaGreen = 4'b1111;
                    vgaBlue  = 4'b0000;
                    vgaRed   = 4'b1111;
                    end               
                else if(Vcount < 420)
                    begin
                    vgaGreen = 4'b1111;
                    vgaBlue  = 4'b1001;
                    vgaRed   = 4'b0000;
                    end              
                else if(Vcount < 480)
                    begin
                    vgaGreen = 4'b1111;
                    vgaBlue  = 4'b0000;
                    vgaRed   = 4'b1010;
                    end
                end                
                5'b00100: begin
                if(Vcount<32 & Hcount>304)
                begin
                    if(Hcount<336)
                    begin
                    vgaGreen <= 4'b1111;
                    vgaBlue <= 4'b0000;
                    vgaRed <= 4'b1111;
                    end 
                    else
                    begin
                    vgaGreen <= 4'b0000;
                    vgaBlue <= 4'b0000;
                    vgaRed <= 4'b0000;
                    end 
                end
                end                
                5'b01000: begin
                if(Hcount> 304) begin
                if( Hcount < 336) begin
                   if(accept1<16)begin
                        if( Vcount< 32)
                            begin
                            vgaGreen <= 4'b1111;
                            vgaBlue <= 4'b0000;
                            vgaRed <= 4'b1111;
                            end 
                   end
                   else //Vcount<16
                    if(Vcount> accept1-16) begin
                    if(Vcount < accept1+16)
                            begin
                            vgaGreen <= 4'b1111;
                            vgaBlue <= 4'b0000;
                            vgaRed <= 4'b1111;
                            end   
                            else
                            begin
                            vgaGreen <= 4'b0000;
                            vgaBlue <= 4'b0000;
                            vgaRed <= 4'b0000;
                            end   end  //Vcount > vercount1
                end
                else // Hcount begin
                begin
                        vgaGreen <= 4'b0000;
                        vgaBlue <= 4'b0000;
                        vgaRed <= 4'b0000;
                        end
                end
                end
                5'b10000: begin
                    if(Vcount<64) begin
                        if(Hcount> 192 && Hcount <256) begin 
                            vgaGreen <= 4'b1111;
                            vgaBlue <= 4'b1111;
                            vgaRed <= 4'b0000;
                        end
                        else if(Hcount> 384 && Hcount <448) begin 
                            vgaGreen <= 4'b1111;
                            vgaBlue <= 4'b1111;
                            vgaRed <= 4'b0000;
                        end
                        else
                        begin
                            vgaGreen <= 4'b0000;
                            vgaBlue <= 4'b0000;
                            vgaRed <= 4'b0000;
                        end
                    end
                    else if(Vcount > 63 && Vcount <96 )begin
                        if(Hcount> 192 && Hcount <448) begin 
                            vgaGreen <= 4'b1111;
                            vgaBlue <= 4'b1111;
                            vgaRed <= 4'b0000;
                        end
                        else
                            begin
                                vgaGreen <= 4'b0000;
                                vgaBlue <= 4'b0000;
                                vgaRed <= 4'b0000;
                            end
                    end
                    else if(Vcount >95 && Vcount <160 )begin
                        if(Hcount> 192 && Hcount <256) begin 
                            vgaGreen <= 4'b1111;
                            vgaBlue <= 4'b1111;
                            vgaRed <= 4'b0000;
                        end
                        else if(Hcount> 384 && Hcount <448) begin 
                            vgaGreen <= 4'b1111;
                            vgaBlue <= 4'b1111;
                            vgaRed <= 4'b0000;
                        end
                        else
                            begin
                                vgaGreen <= 4'b0000;
                                vgaBlue <= 4'b0000;
                                vgaRed <= 4'b0000;
                            end
                    end
                end
                default:
                    begin
                        vgaGreen <= 4'b0000;
                        vgaBlue <= 4'b0000;
                        vgaRed <= 4'b0000;
                    end    
                endcase
            end      
        end
endmodule
