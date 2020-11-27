g++ bmpHex.cpp -o bmpHex
./bmpHex images/test0.bmp
cd verilog
iverilog maxThroughput.sv maxThroughputTest.sv -g2012 -gno-specify -o a
vvp a

cd ..
./bmpHex output/test0MaxThroughput127.hex
feh output/test0MaxThroughput127.png
