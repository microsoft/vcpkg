cmake_minimum_required(VERSION 3.15)
project(vcpkg_ci_dawn)

set(CMAKE_CXX_STANDARD 17)

find_package(glfw3 CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(Dawn CONFIG REQUIRED)

if (APPLE)
    file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS src/*.hpp src/*.cpp src/*.mm)
else()
    file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS src/*.hpp src/*.cpp)
endif ()
add_executable(vcpkg_ci_dawn ${SOURCES})
target_link_libraries(vcpkg_ci_dawn PUBLIC
        glfw
        fmt::fmt
        spdlog::spdlog
        dawn::webgpu_dawn
)
if (EMSCRIPTEN)
    target_link_options(vcpkg_ci_dawn PUBLIC -sASYNCIFY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/index.html" "${CMAKE_BINARY_DIR}/index.html")
endif ()
