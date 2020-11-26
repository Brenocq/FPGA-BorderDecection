g++ bmpHex.cpp -o bmpHex
./bmpHex images/brasiil.bmp
cd verilog
iverilog maxThroughput.sv maxThroughputTest.sv -g2012 -gno-specify -o a
vvp a
cd ..
./bmpHex images/brasiilOut.hex
feh images/brasiilOut.png
