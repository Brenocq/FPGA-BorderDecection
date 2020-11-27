`define WIDTH 320
`define THRESH 230

module minHardware (
  	input clk,
	input[7:0] in1 [0:(`WIDTH-1)],
	input[7:0] in2 [0:(`WIDTH-1)],
	input[7:0] in3 [0:(`WIDTH-1)],
	output reg[7:0] out [0:(`WIDTH-1)]
);
	integer x;

	initial begin
		out[0] = 0;
		out[(`WIDTH-1)] = 0;
	end

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
				((pixels[0]<(`THRESH)) | (pixels[1]<(`THRESH))  | (pixels[2]<(`THRESH)) 
				| (pixels[3]<(`THRESH))  | (pixels[5]<(`THRESH))
				| (pixels[6]<(`THRESH))  | (pixels[7]<(`THRESH))  | (pixels[8]<(`THRESH)))
				&& (pixels[4]>(`THRESH));

			out[x] <= erosion*pixels[4];
			//$display("%h <= %h * %h", out[x], pixels[4], erosion);
		end
	end
endmodule
