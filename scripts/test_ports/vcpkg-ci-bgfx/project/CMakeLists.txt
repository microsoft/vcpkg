cmake_minimum_required(VERSION 3.10)
project(bgfx-test CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(bgfx CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE
    bgfx::bgfx
    # auxiliary targets
    bgfx::bx
    bgfx::bimg
    bgfx::bimg_decode
    bgfx::bimg_encode
)
if(ANDROID)
    find_package(OpenGL COMPONENTS EGL GLES2 REQUIRED)
    target_link_libraries(main PRIVATE nativewindow OpenGL::EGL OpenGL::GLES2)
endif()
