cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-nghttp3 C)

################################################################################
#                              Use cmake config                                #
################################################################################
find_package(nghttp3 CONFIG REQUIRED)
add_executable(vcpkg-ci-nghttp3 main.c)
target_link_libraries(vcpkg-ci-nghttp3 PRIVATE $<IF:$<TARGET_EXISTS:nghttp3::nghttp3>,nghttp3::nghttp3,nghttp3::nghttp3_static>)

################################################################################
#                                Use pkg-config                                #
################################################################################
find_package(PkgConfig)
pkg_check_modules(nghttp3 REQUIRED IMPORTED_TARGET libnghttp3)
add_executable(vcpkg-ci-nghttp3-pc main.c)
target_link_libraries(vcpkg-ci-nghttp3-pc PRIVATE PkgConfig::nghttp3)
