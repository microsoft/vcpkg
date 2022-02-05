cmake_minimum_required(VERSION 3.0)

# if -DVCPKG_TARGET_ANDROID=ON is specified when invoking cmake, load cmake/vcpkg_android.cmake
# !!! Important: place this line before calling project() !!!
if (VCPKG_TARGET_ANDROID)
    include("cmake/vcpkg_android.cmake")
endif()

project(test)

find_package(jsoncpp CONFIG REQUIRED)
add_library(my_lib my_lib.cpp)
target_link_libraries(my_lib JsonCpp::JsonCpp)
