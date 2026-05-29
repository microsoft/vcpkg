cmake_minimum_required(VERSION 3.7)
project(vcpkg-ci-openimageio C CXX) # C is transitive requirement for MPI via vtk

add_executable(main main.cpp)

find_package(OpenImageIO CONFIG REQUIRED)
target_link_libraries(main PRIVATE OpenImageIO::OpenImageIO)
