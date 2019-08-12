module test(clk, reset);
	input clk, reset;
	wire[3:0] outVal1, outVal2;
	wrapper w0(clk, reset, 4'd0, outVal1);
	wrapper w1(clk, reset, 4'd4, outVal2);
endmodule
module wrapper(clk, reset, startVal, outVal);
	input clk, reset;
	input[3:0] startVal;
	output[3:0] outVal;
	counter c0(clk, reset, startVal, outVal);
endmodule

module counter(clk, reset, startVal, outVal);
	input clk, reset;
	input[3:0] startVal;
	output reg[3:0] outVal;
	always @(posedge clk) begin
		if (~reset) begin
			outVal <= startVal;
		end
		else begin
			outVal <= outVal + 1'b1;
		end
	end
endmodule