cmake_minimum_required(VERSION 3.20)
project(tinycbor C)

file(GLOB sources src/cbor*.c)
list(FILTER sources EXCLUDE REGEX "cbortojson.c$")
add_library(tinycbor ${sources})

install(TARGETS tinycbor)
install(FILES src/cbor.h src/cborjson.h src/tinycbor-version.h DESTINATION include/tinycbor)
