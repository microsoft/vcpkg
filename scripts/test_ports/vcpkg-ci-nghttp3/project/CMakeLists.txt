cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-nghttp3 C)

find_package(nghttp3 CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:nghttp3::nghttp3>,nghttp3::nghttp3,nghttp3::nghttp3_static>)
