message(STATUS "Using VCPKG FindLAPACK. Remove if CMake has been updated to account for -lm and -lgfortran in lapack-reference!")
include(${CMAKE_CURRENT_LIST_DIR}/FindLAPACK.cmake)
