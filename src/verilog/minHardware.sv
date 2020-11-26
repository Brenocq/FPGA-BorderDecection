`define WIDTH 320

module BorderDetection (
  	input clk,
	input[7:0] in1 [0:(`WIDTH-1)],
	input[7:0] in2 [0:(`WIDTH-1)],
	input[7:0] in3 [0:(`WIDTH-1)],
	output reg[7:0] out [0:(`WIDTH-1)]
);
	integer x;

	always @(posedge clk) begin
		for(x=1; x<(`WIDTH-1); x=x+1) begin
        	reg[7:0] pixels [0:8];
        	reg[7:0] erosion;

			pixels[0] = in1[x-1];
			pixels[1] = in1[x];
			pixels[2] = in1[x+1];
			pixels[3] = in2[x-1];
			pixels[4] = in2[x];
			pixels[5] = in2[x+1];
			pixels[6] = in3[x-1];
			pixels[7] = in3[x];
			pixels[8] = in3[x+1];

			erosion = 
				((pixels[0]<127) | (pixels[1]<127)  | (pixels[2]<127) 
				| (pixels[3]<127)  | (pixels[5]<127)
				| (pixels[6]<127)  | (pixels[7]<127)  | (pixels[8]<127))
				&& (pixels[4]>127);

			out[x] <= erosion*pixels[4];
			//$display("%h <= %h * %h", out[x], pixels[4], erosion);
		end
	end
endmodule
