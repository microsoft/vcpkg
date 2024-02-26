cmake_minimum_required(VERSION 3.10)
project(test)
set(CMAKE_CXX_STANDARD 11)
add_executable(main main.cpp)
find_package(gRPC CONFIG REQUIRED)
# note: 7 additional targets are not displayed.
target_link_libraries(main PRIVATE gRPC::gpr gRPC::grpc gRPC::grpc++ gRPC::grpc++_alts)
The package asio-grpc can be used with different backends.
find_package(asio-grpc CONFIG REQUIRED)
The Boost.Asio backend. Install "boost-asio" and link with:
target_link_libraries(main PRIVATE asio-grpc::asio-grpc)
The standalone Asio backend. Install "asio" and link with:
target_link_libraries(main PRIVATE asio-grpc::asio-grpc-standalone-asio)
The libunifex backend. Install "libunifex" and link with:
target_link_libraries(main PRIVATE asio-grpc::asio-grpc-unifex)
The stdexec backend. Install "stdexec" and link with:
target_link_libraries(main PRIVATE asio-grpc::asio-grpc-stdexec)
