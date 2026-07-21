cmake_minimum_required(VERSION 3.16)
project(flann-test LANGUAGES C CXX)

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

add_executable(main_c main.c)
target_link_libraries(main_c PRIVATE $<IF:$<TARGET_EXISTS:flann::flann>,flann::flann,flann::flann_s>)

# Verify Pkg target
find_package(PkgConfig REQUIRED)
pkg_check_modules(Flann REQUIRED IMPORTED_TARGET flann)

if(WIN32 AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    get_target_property(FLANN_PKG_LIBRARIES PkgConfig::Flann INTERFACE_LINK_LIBRARIES)
    if(TARGET flann::flann_s)
        set(EXPECTED_FLANN_PKG_LIBRARIES flann_sd.lib flann_cpp_sd.lib)
    else()
        set(EXPECTED_FLANN_PKG_LIBRARIES flannd.lib flann_cppd.lib)
    endif()
    foreach(EXPECTED_FLANN_PKG_LIBRARY IN LISTS EXPECTED_FLANN_PKG_LIBRARIES)
        string(FIND "${FLANN_PKG_LIBRARIES}" "${EXPECTED_FLANN_PKG_LIBRARY}" EXPECTED_FLANN_PKG_LIBRARY_INDEX)
        if(EXPECTED_FLANN_PKG_LIBRARY_INDEX EQUAL -1)
            message(FATAL_ERROR "Missing Debug library ${EXPECTED_FLANN_PKG_LIBRARY}: ${FLANN_PKG_LIBRARIES}")
        endif()
    endforeach()
endif()

add_executable(main_pkg main.cpp)
target_link_libraries(main_pkg PRIVATE PkgConfig::Flann)
