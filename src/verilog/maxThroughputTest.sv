`define SIZE 76800
// Testbench
module test();
  
  localparam inputImage = "../images/test0.hex";
  localparam outputImage = "../output/test0MaxThroughput127.hex";
  integer file;
  integer read;
  integer tmp;
  integer i;
  reg clk;

  reg [7:0] in [0:(`SIZE-1)];
  wire [7:0] out [0:(`SIZE-1)];
  
  // Instantiate design under test
  maxThroughput mt(.clk(clk), .in(in), .out(out));
  
  always #5 clk=~clk;
  
  initial begin
    $display("--------- Populating memory with file ---------");
    file=$fopen(inputImage,"r");
    if(!file) begin
      $display("Error: %s cannot be opened.", inputImage);
      $finish;
    end
    
    for (i=0; i<`SIZE; i=i+1) begin
      read = $fscanf(file,"%h",in[i]);
      //$display("Value: %h.", in[i]);
    end

    #1 $fclose(file);
    $display("--------- Processing ---------");
    clk=1;
    for(i=0; i<1; i=i+1)
      @(posedge clk)
        $display("clock");
    
    $display("--------- Saving from memory to file ---------");
    file=$fopen(outputImage,"w");
    if(!file) begin
      $display("Error: %s cannot be opened.", outputImage);
      $finish;
    end
    
    for (i=0; i<`SIZE; i=i+1) begin
      $fwrite(file, "%h ", out[i]);
    end
    #1 $fclose(file);
    
    
    $display("--------- RESULTS ---------");
    display;
    $stop;
  end
  
  task display;
    #1 $display("out:%0h", out[130]);
  endtask

endmodule
