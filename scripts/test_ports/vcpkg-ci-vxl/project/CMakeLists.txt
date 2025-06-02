cmake_minimum_required(VERSION 3.7)
project(vnl-test CXX)

if(APPLE)
    set(CMAKE_CXX_STANDARD "11")
endif()

find_package(VXL CONFIG REQUIRED)

# The use file doesn't only set variables,
# but also directly calls include_directories().
# (Calling link_directories() must remain disabled in vcpkg.)
# The imported targets don't carry the main include directories!
include("${VXL_CMAKE_DIR}/UseVXL.cmake")

# Catch wrong link directories.
find_library(vcpkg_ci_vnl_library NAMES vnl REQUIRED)
cmake_path(GET vcpkg_ci_vnl_library PARENT_PATH vcpkg_ci_vnl_library_dir)
if(BUILD_TYPE STREQUAL "debug" AND NOT vcpkg_ci_vnl_library_dir MATCHES "/debug/lib\$")
    message(SEND_ERROR "vil library directory is wrong."
      "\n  Expected path: '${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib'"
      "\n  Actual path:   '${vcpkg_ci_vnl_library_dir}'"
    )
endif()

add_executable(main main.cpp)
target_link_libraries(main PRIVATE
    $<TARGET_NAME:vil>       # required. Needs image format deps
    $<TARGET_NAME:vnl_algo>  # test only: wants netlib
    $<TARGET_NAME:vgl>       # test only: wants polyclipping
    $<TARGET_NAME:vgl_algo>  # test only: wants image formats
)

