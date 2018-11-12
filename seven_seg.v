module seven_seg(
    input [7:0] sw,
    input reset,
    output reg [3:0] an,
    output [6:0] seg,
    input clk
    );
    reg [3:0] out;
    reg [1:0] count;
    always @(posedge clk, posedge reset) // include 
    begin
        if (reset)
            count <= 0;
        else if (count == 3)
            count <= 0;
        else
            count <= count + 1;
    end
    
    always @ (count)
    case (count)
        2'b00: an = 4'b1110;
        2'b01: an = 4'b1101;
        2'b10: an = 4'b1011;
        default: an = 4'b0111;
    endcase
   always @ (an, sw)
        case(an)
        4'b1110: out= sw[3:0];
        4'b1101: out= sw[7:4];
        4'b1011: out=4'b0000;
        default: out=4'b0000;
        endcase                        
     assign seg = (out == 4'b0000)? 7'b1000000:
                 (out == 4'b0001)? 7'b1111001:
                 (out == 4'b0010)? 7'b0100100:
                 (out == 4'b0011)? 7'b0110000:
                 (out == 4'b0100)? 7'b0011001:
                 (out == 4'b0101)? 7'b0010010:
                 (out == 4'b0110)? 7'b0000010:
                 (out == 4'b0111)? 7'b1111000:
                 (out == 4'b1000)? 7'b0000000:
                 (out == 4'b1001)? 7'b0011000:
                 (out == 4'b1010)? 7'b0001000:
                 (out == 4'b1011)? 7'b0000011:
                 (out == 4'b1100)? 7'b1000110:
                 (out == 4'b1101)? 7'b0100001:
                 (out == 4'b1110)? 7'b0000110: 7'b0001110;
endmodule
