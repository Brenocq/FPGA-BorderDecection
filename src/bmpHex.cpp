#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <iostream>
#include <array>
#include <algorithm>
#include "convert.hpp"

Image readBmp(std::string fileName)
{
	Image image;

	static constexpr size_t HEADER_SIZE = 54;
	std::string path = fileName;
	std::ifstream bmp(path.c_str(), std::ios::binary);
    std::array<char, HEADER_SIZE> header;
    bmp.read(header.data(), header.size());

    auto fileSize = *reinterpret_cast<uint32_t *>(&header[2]);
    auto dataOffset = *reinterpret_cast<uint32_t *>(&header[10]);
    auto width = *reinterpret_cast<uint32_t *>(&header[18]);
    auto height = *reinterpret_cast<uint32_t *>(&header[22]);
    auto depth = *reinterpret_cast<uint16_t *>(&header[28]);

	image.width = width;
	image.height = height;
	image.channels = 1;

    std::cout << "fileSize: " << fileSize << std::endl;
    std::cout << "dataOffset: " << dataOffset << std::endl;
    std::cout << "width: " << width << std::endl;
    std::cout << "height: " << height << std::endl;
    std::cout << "depth: " << depth << "-bit" << std::endl;
    std::cout << "channels: " << (int)image.channels << std::endl;
	
    auto dataSize = ((width*3 + 3) & (~3)) * height;
	std::cout << "data: " << dataSize << std::endl;
	std::cout << "size: " << width*height<< std::endl;
    //auto dataSize = width*height;
    std::vector<char> img(dataSize);
    bmp.read(img.data(), img.size());
    std::vector<unsigned char> buffer(width*height);

	for(int y=0;y<height;y++)
		for(int x=0;x<width;x++)
			//buffer[y*width+x] = 255;//(unsigned char)(img[y*width*3+x*3]);//float(i)/dataSize*255;//
			buffer[(height-y-1)*width+x] = (unsigned char)(img[y*width*3+x*3+80]);//float(i)/dataSize*255;//
			//buffer[(height-y-1)*width+x] = (unsigned char)(127);//float(i)/dataSize*255;//

	image.buffer.assign(buffer.begin(), buffer.end());

	return image;
}

int main(int argc, char *argv[])
{
	if(argc == 1 || argc > 2)
	{
		std::cout << "./bmpHex [file.bmp|hex]" << std::endl;
		return 0;
	}
	std::string fileName = argv[1];

	std::size_t foundBmp = fileName.find(".bmp");
	std::size_t foundHex = fileName.find(".hex");
  	if(foundBmp!=std::string::npos)
	{
		std::string outputFile = fileName.substr(0, foundBmp);
		outputFile+=".hex";
		std::cout << "Converting to " + outputFile << std::endl;
		Image image = readBmp(fileName);
		int width = image.width;
		int height = image.height;

		std::ofstream file;
		//file.open(outputFile, std::ios::binary | std::ios::out);
		file.open(outputFile, std::ios::out);
		file << std::hex;
		for(int y=0;y<height;y++)
			for(int x=0;x<width;x++)
			{
				file << (int)image.buffer[y*width + x] << " ";
				//file << (unsigned char)(image.buffer[y*width + x]);
				//file << (uint32_t)200;
			}
		file.close();
	}
	else if(foundHex!=std::string::npos)
	{
		std::string outputFile = fileName.substr(0, foundHex);
		outputFile+=".png";
		std::cout << "Converting to " + outputFile << std::endl;
		int width = 320;
		int height = 240;
		std::vector<unsigned char> buffer(width*height);

		// Populate buffer from file (bin)
		//std::ifstream file(fileName, std::ios::in | std::ios::binary);
		//char bufferFile[width*height];
		//file.read(bufferFile, buffer.size());
		//for(int i=0; i<width*height; i++)
		//	buffer[i] = bufferFile[i];
		
		// Populate buffer from file (hex)
		std::ifstream file(fileName, std::ios::in);
		std::string line;
		if(file.is_open())
		{
			while(getline(file,line))
			{
				std::stringstream ss;
				std::replace(line.begin(), line.end(), 'x', '0');
				ss << std::hex << line;
				for(int i=0; i<width*height; i++)
				{
					int val;
					ss >> val;
					buffer[i] = val;
				}
			}
			file.close();
		}
		//for(int i=0; i<width*height; i++)
		//	buffer[i] = 255;

		// Send buffer to image
		Image image;
		image.width = width;
		image.height = height;
		image.channels = 1;
		image.buffer = buffer;

		// Save bmp image
		writePng(outputFile, image);
	}
	else
	{
		std::cout << "Please only .bmp or .hex" << std::endl;
	}

	return 0;
}
