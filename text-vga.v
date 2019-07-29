//each character display is 3x5 pixels
//every three bits represents a row in the character display
//i.e. the display of 0 (where 1 is enabled pixel):
//111
//101
//101
//101
//111
module patternEncoding(letterCode, pixelPattern);
	input [5:0] letterCode;
	output reg [0:14] pixelPattern;
	
	always @(*) begin
		case(letterCode)
			6'd1: pixelPattern <= 15'b111_101_101_101_111; //0
			6'd2: pixelPattern <= 15'b010_110_010_010_111; //1
			6'd3: pixelPattern <= 15'b111_001_111_100_111; //2
			6'd4: pixelPattern <= 15'b111_001_111_001_111; //3
			6'd5: pixelPattern <= 15'b101_101_111_001_001; //4
			6'd6: pixelPattern <= 15'b111_100_111_001_111; //5
			6'd7: pixelPattern <= 15'b111_100_111_101_111; //6
			6'd8: pixelPattern <= 15'b111_001_001_001_001; //7
			6'd9: pixelPattern <= 15'b111_101_111_101_111; //8
			6'd10: pixelPattern <= 15'b111_101_111_001_001; //9
			6'd11: pixelPattern <= 15'b010_101_111_101_101; //A
			6'd12: pixelPattern <= 15'b110_101_110_101_110; //B
			6'd13: pixelPattern <= 15'b010_101_100_101_010; //C
			6'd14: pixelPattern <= 15'b110_101_101_101_110; //D
			6'd15: pixelPattern <= 15'b111_100_111_100_111; //E
			6'd16: pixelPattern <= 15'b111_100_111_100_100; //F
			6'd17: pixelPattern <= 15'b011_100_100_101_011; //G
			6'd18: pixelPattern <= 15'b101_101_111_101_101; //H
			6'd19: pixelPattern <= 15'b010_010_010_010_010; //I
			6'd20: pixelPattern <= 15'b001_001_001_101_010; //J
			6'd21: pixelPattern <= 15'b101_101_110_101_101; //K
			6'd22: pixelPattern <= 15'b100_100_100_100_111; //L
			6'd23: pixelPattern <= 15'b101_111_101_101_101; //M
			6'd24: pixelPattern <= 15'b110_101_101_101_101; //N
			6'd25: pixelPattern <= 15'b010_101_101_101_010; //O
			6'd26: pixelPattern <= 15'b110_101_110_100_100; //P
			6'd27: pixelPattern <= 15'b010_101_101_111_011; //Q
			6'd28: pixelPattern <= 15'b110_101_110_101_101; //R
			6'd29: pixelPattern <= 15'b011_100_010_001_110; //S
			6'd30: pixelPattern <= 15'b111_010_010_010_010; //T
			6'd31: pixelPattern <= 15'b101_101_101_101_111; //U
			6'd32: pixelPattern <= 15'b101_101_101_101_010; //V
			6'd33: pixelPattern <= 15'b101_101_101_111_101; //W
			6'd34: pixelPattern <= 15'b101_101_010_101_101; //X
			6'd35: pixelPattern <= 15'b101_101_111_010_010; //Y
			6'd36: pixelPattern <= 15'b111_001_010_100_111; //Z
			default: pixelPattern <= 15'b000_000_000_000_000; //blank display
		endcase
	end
endmodule

module displayPattern(clk, reset, pixelPattern, x, y);
	input clk, reset;
	input [0:14] pixelPattern;
	output reg [7:0] x;
	output reg [6:0] y;

endmodule
