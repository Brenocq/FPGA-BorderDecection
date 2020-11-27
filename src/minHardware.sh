#g++ bmpHex.cpp -o bmpHex
#./bmpHex images/icmc.bmp
cd verilog
iverilog minHardware.sv minHardwareTest.sv -g2012 -gno-specify -o a
vvp a

cd ..
./bmpHex output/test0MinHardware200.hex
feh output/test0MinHardware200.png
