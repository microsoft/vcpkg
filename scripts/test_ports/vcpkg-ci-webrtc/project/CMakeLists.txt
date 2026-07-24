cmake_minimum_required(VERSION 3.20)

project(webrtc_ci_test LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(unofficial-webrtc CONFIG REQUIRED)

add_executable(main main.cc)
target_link_libraries(main PRIVATE unofficial::webrtc::webrtc)

install(TARGETS main RUNTIME DESTINATION bin/vcpkg-ci-webrtc)
