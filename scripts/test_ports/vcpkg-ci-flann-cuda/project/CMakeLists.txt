cmake_minimum_required(VERSION 3.16)
project(flann-test LANGUAGES C CXX)

find_package(flann CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:flann::flann_cpp>,flann::flann_cpp,flann::flann_cpp_s>)
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:flann::flann_cuda>,flann::flann_cuda,flann::flann_cuda_s>)
target_compile_definitions(main PRIVATE WITH_CUDA)
