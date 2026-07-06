cmake_minimum_required(VERSION 3.16)
project(flann-test)

# Verify CMake targets
find_package(flann CONFIG REQUIRED)

add_executable(main main.cpp)
if(WITH_CUDA)
    target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:flann::flann_cuda>,flann::flann_cuda,flann::flann_cuda_s>)
else()
    target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:flann::flann_cpp>,flann::flann_cpp,flann::flann_cpp_s>)
endif()
if(WITH_HDF5)
    target_compile_definitions(main PRIVATE WITH_HDF5)
endif()

# Verify Pkg target
find_package(PkgConfig REQUIRED)
pkg_check_modules(Flann REQUIRED IMPORTED_TARGET flann)

add_executable(main_pkg main.cpp)
target_link_libraries(main_pkg PRIVATE PkgConfig::Flann)
if(WITH_HDF5)
    target_compile_definitions(main_pkg PRIVATE WITH_HDF5)
endif()
