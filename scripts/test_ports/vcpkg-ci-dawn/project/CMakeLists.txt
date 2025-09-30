cmake_minimum_required(VERSION 3.15)
project(vcpkg_ci_dawn)

set(CMAKE_CXX_STANDARD 17)

find_package(glfw3 CONFIG REQUIRED)

################################################################################
#                              Use cmake config                                #
################################################################################
find_package(Dawn CONFIG REQUIRED)
add_executable(vcpkg_ci_dawn main.cpp webgpu_glfw3.cpp)
target_link_libraries(vcpkg_ci_dawn PRIVATE glfw dawn::webgpu_dawn)
if (EMSCRIPTEN)
    target_link_options(vcpkg_ci_dawn PRIVATE -sASYNCIFY)
    set(TARGET_NAME "vcpkg_ci_dawn")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/main.html" "${CMAKE_BINARY_DIR}/${TARGET_NAME}.html" @ONLY)
endif ()

################################################################################
#                                Use pkg-config                                #
################################################################################
find_package(PkgConfig)
pkg_check_modules(webgpu_dawn REQUIRED IMPORTED_TARGET unofficial_webgpu_dawn)
add_executable(vcpkg_ci_dawn_pc main.cpp webgpu_glfw3.cpp)
target_link_libraries(vcpkg_ci_dawn_pc PRIVATE glfw PkgConfig::webgpu_dawn)
if (EMSCRIPTEN)
    target_link_options(vcpkg_ci_dawn_pc PRIVATE -sASYNCIFY)
    set(TARGET_NAME "vcpkg_ci_dawn_pc")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/main.html" "${CMAKE_BINARY_DIR}/${TARGET_NAME}.html" @ONLY)
endif ()
