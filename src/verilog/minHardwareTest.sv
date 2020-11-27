`define SIZE 76800
`define WIDTH 320
`define HEIGHT 240
// Testbench
module test();
  
  localparam inputImage = "../images/icmc.hex";
  localparam outputImage = "../output/icmcMinHardware200.hex";
  integer fileIn;
  integer fileOut;
  integer read;
  integer i;
  integer x;
  integer y;
  reg clk;

  reg [7:0] in1 [0:(`WIDTH-1)];
  reg [7:0] in2 [0:(`WIDTH-1)];
  reg [7:0] in3 [0:(`WIDTH-1)];
  wire [7:0] out [0:(`WIDTH-1)];
  
  // Instantiate design under test
  minHardware mh(.clk(clk), .in1(in1), .in2(in2), .in3(in3), .out(out));
  
  always #5 clk=~clk;
  
  initial begin
    $display("--------- Populating memory and processing and writing ---------");
    fileIn=$fopen(inputImage,"r");
    fileOut=$fopen(outputImage,"w");
    if(!fileIn) begin
      $display("Error: %s cannot be opened.", inputImage);
      $finish;
    end
    if(!fileOut) begin
      $display("Error: %s cannot be opened.", outputImage);
      $finish;
    end
    
	for (y=0; y<2; y=y+1) begin
		for (x=0; x<`WIDTH; x=x+1) begin
			in1[x] <= in2[x];
			in2[x] <= in3[x];
			read = $fscanf(fileIn,"%h",in3[x]);
		end
	end

    clk=1;
	y=0;
	for (y=0; y<`HEIGHT; y=y+1) begin
		@(posedge clk) begin
			$display("clock");
			for (x=0; x<`WIDTH; x=x+1) begin
				in1[x] <= in2[x];
				in2[x] <= in3[x];
				read = $fscanf(fileIn,"%h",in3[x]);
			end
			for (x=0; x<`WIDTH; x=x+1) begin
			  $fwrite(fileOut, "%h ", out[x]);
			end
		end
	end
    #1 $fclose(fileIn);
    #1 $fclose(fileOut);
    $stop;

    $display("--------- RESULTS ---------");
    display;
  end
  
  task display;
    #1 $display("out:%0h", out[130]);
  endtask

endmodule
