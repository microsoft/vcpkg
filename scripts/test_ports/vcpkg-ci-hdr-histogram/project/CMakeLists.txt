cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-hdr-histogram)

################################################################################
#                              Use cmake config                                #
################################################################################
find_package(hdr_histogram CONFIG REQUIRED)
add_executable(vcpkg-ci-hdr-histogram main.c)
target_link_libraries(vcpkg-ci-hdr-histogram PRIVATE $<IF:$<TARGET_EXISTS:hdr_histogram::hdr_histogram>,hdr_histogram::hdr_histogram,hdr_histogram::hdr_histogram_static>)

################################################################################
#                                Use pkg-config                                #
################################################################################
find_package(PkgConfig)
pkg_check_modules(hdr_histogram REQUIRED IMPORTED_TARGET hdr_histogram)
add_executable(vcpkg-ci-hdr-histogram-pc main.c)
target_link_libraries(vcpkg-ci-hdr-histogram-pc PRIVATE PkgConfig::hdr_histogram)
