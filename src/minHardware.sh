g++ bmpHex.cpp -o bmpHex
./bmpHex images/icmc.bmp
cd verilog
iverilog minHardware.sv minHardwareTest.sv -g2012 -gno-specify -o a
vvp a

cd ..
./bmpHex output/icmcMinHardware200.hex
feh output/icmcMinHardware200.png
