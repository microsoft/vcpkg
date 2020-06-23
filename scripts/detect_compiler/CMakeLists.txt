cmake_minimum_required(VERSION 3.10)
project(detect_compiler)

file(SHA1 "${CMAKE_CXX_COMPILER}" CXX_HASH)
file(SHA1 "${CMAKE_C_COMPILER}" C_HASH)
string(SHA1 COMPILER_HASH "${C_HASH}${CXX_HASH}")

message("#COMPILER_HASH#${COMPILER_HASH}")
