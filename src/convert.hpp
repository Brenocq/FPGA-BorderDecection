#include <vector>
#include <iostream>
#include "lib/svpng/svpng.h"

struct Image
{
	std::vector<unsigned char> buffer;
	uint32_t width = 0;
	uint32_t height = 0;
	uint8_t channels = 3;

	unsigned char getPixel(int x, int y, int c=0)
	{
		return buffer[y*width*channels + x*channels + c];
	}
};

//--------------------//
//------- PNG --------//
//--------------------//
void writePng(std::string fileName, Image image)
{
	Image output;
	output.width = image.width;
	output.height = image.height;
	if(image.channels == 1)
	{
		output.channels = 3;
		output.buffer = std::vector<unsigned char>(output.width*output.height*output.channels);
		for(int y=0;y<image.height;y++)
			for(int x=0;x<image.width;x++)
			{
				unsigned char val = image.buffer[y*image.width + x];
				output.buffer[y*output.width*output.channels + x*output.channels + 0] = val;
				output.buffer[y*output.width*output.channels + x*output.channels + 1] = val;
				output.buffer[y*output.width*output.channels + x*output.channels + 2] = val;
			}
	}
	else if(image.channels==3 || image.channels==4)
		output = image;
	else
		return;

	// Save png
	FILE* fp = fopen((fileName).c_str(), "wb");
	svpng(fp, output.width, output.height, output.buffer.data(), output.channels==3?0:1);
	fclose(fp);
}
