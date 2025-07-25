cmake_minimum_required(VERSION 3.16)
project(test_malware_detector)

# Find vcpkg toolchain
find_package(malware_detector CONFIG REQUIRED)

add_executable(test_malware_detector test_malware_detector.cpp)
target_link_libraries(test_malware_detector PRIVATE malware_detector::malware_detector)
target_compile_features(test_malware_detector PRIVATE cxx_std_17)
