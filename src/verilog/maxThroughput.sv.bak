`define SIZE 76800
`define WIDTH 320
`define HEIGHT 240

// Image Processing
module ImageProcessing (
  input clk,
  input [7:0] in [0:(`SIZE-1)],
  output reg[7:0] out [0:(`SIZE-1)]
);
  
  integer x = 0;
  integer y = 0;
  integer width = `WIDTH;
  integer height = `HEIGHT;

  always @(posedge clk) begin
    // Erase corners
    for(y=0; y<height; y=y+1) begin
      out[y*width+0] <= 0;
      out[y*width+width-1] <= 0;
    end
    for(x=0; x<width; x=x+1) begin
      out[0*width+x] <= 0;
      out[(height-1)*width+x] <= 0;
    end
    
    // Process image
    for(y=1; y<height-1; y=y+1) begin
      for(x=1; x<width-1; x=x+1) begin
        reg[7:0] pixels [0:8];
        reg[7:0] erosion;
        
        pixels[0] = in[(y-1)*width+x-1];
        pixels[1] = in[(y-1)*width+x];
        pixels[2] = in[(y-1)*width+x+1];
        pixels[3] = in[(y)*width+x-1];
        pixels[4] = in[(y)*width+x];
        pixels[5] = in[(y)*width+x+1];
        pixels[6] = in[(y+1)*width+x-1];
        pixels[7] = in[(y+1)*width+x];
        pixels[8] = in[(y+1)*width+x+1];

        erosion = 
			((pixels[0]<127) | (pixels[1]<127)  | (pixels[2]<127) 
        	| (pixels[3]<127)  | (pixels[5]<127)
         	| (pixels[6]<127)  | (pixels[7]<127)  | (pixels[8]<127))
        	&& (pixels[4]>127);

        out[y*width+x] <= pixels[4]*erosion;
		//$display("%h <= %h * %h", out[y*width+x], pixels[4], erosion);
      end
    end
  end
  
endmodule
