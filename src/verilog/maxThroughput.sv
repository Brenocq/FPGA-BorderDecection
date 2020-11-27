`define SIZE 76800
`define WIDTH 320
`define HEIGHT 240
`define THRESH 127

// Image Processing
module maxThroughput (
  input clk,
  input [7:0] in [0:(`SIZE-1)],
  output reg[7:0] out [0:(`SIZE-1)]
);
  
  integer x = 0;
  integer y = 0;

  always @(posedge clk) begin
    // Erase corners
    for(y=0; y<`HEIGHT; y=y+1) begin
      out[y*(`WIDTH)+0] <= 0;
      out[(y+1)*(`WIDTH)-1] <= 0;
    end
    for(x=0; x<`WIDTH; x=x+1) begin
      out[0*(`WIDTH)+x] <= 0;
      out[((`HEIGHT)-1)*(`WIDTH)+x] <= 0;
    end
    
    // Process image
    for(y=1; y<(`HEIGHT-1); y=y+1) begin
      for(x=1; x<(`WIDTH-1); x=x+1) begin
        reg[7:0] pixels [0:8];
        reg[7:0] erosion;
        
        pixels[0] = in[(y-1)*(`WIDTH)+x-1];
        pixels[1] = in[(y-1)*(`WIDTH)+x];
        pixels[2] = in[(y-1)*(`WIDTH)+x+1];
        pixels[3] = in[(y)*(`WIDTH)+x-1];
        pixels[4] = in[(y)*(`WIDTH)+x];
        pixels[5] = in[(y)*(`WIDTH)+x+1];
        pixels[6] = in[(y+1)*(`WIDTH)+x-1];
        pixels[7] = in[(y+1)*(`WIDTH)+x];
        pixels[8] = in[(y+1)*(`WIDTH)+x+1];

        erosion = 
			((pixels[0]<(`THRESH)) | (pixels[1]<(`THRESH))  | (pixels[2]<(`THRESH)) 
        	| (pixels[3]<(`THRESH))  | (pixels[5]<(`THRESH))
         	| (pixels[6]<(`THRESH))  | (pixels[7]<(`THRESH))  | (pixels[8]<(`THRESH)))
        	&& (pixels[4]>(`THRESH));

        out[y*(`WIDTH)+x] <= pixels[4]*erosion;
		//$display("%h <= %h * %h", out[y*width+x], pixels[4], erosion);
      end
    end
  end
  
endmodule
