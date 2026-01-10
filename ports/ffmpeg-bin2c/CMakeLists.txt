cmake_minimum_required(VERSION 3.10)
project(ffmpeg-bin2c C)

# Create the executable from the source file
add_executable(bin2c bin2c.c)

# Install rule to put it into the standard bin directory
install(TARGETS bin2c DESTINATION manual-tools/ffmpeg-bin2c)
