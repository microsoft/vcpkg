cmake_minimum_required(VERSION 3.20)

project(vcpkg-ci-alibabacloud-oss-cpp-sdk-v2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(alibabacloud_oss_v2 CONFIG REQUIRED)
find_package(tinyxml2 CONFIG REQUIRED)

find_path(BOOST_BEAST_INCLUDE_DIR boost/beast/core/detail/base64.hpp REQUIRED)

add_executable(main main.cpp)
target_include_directories(main PRIVATE "${BOOST_BEAST_INCLUDE_DIR}")
target_link_libraries(main PRIVATE alibabacloud_oss_v2::oss tinyxml2::tinyxml2)
install(TARGETS main RUNTIME DESTINATION "bin/vcpkg-ci-alibabacloud-oss-cpp-sdk-v2")

if(NOT WIN32)
    find_package(unofficial-aliyun-oss-cpp-sdk CONFIG REQUIRED)
    get_property(imported_targets DIRECTORY PROPERTY IMPORTED_TARGETS)
    foreach(imported_target IN LISTS imported_targets)
        if(imported_target MATCHES "^unofficial::aliyun-oss-cpp-sdk::")
            set(legacy_oss_target "${imported_target}")
            break()
        endif()
    endforeach()
    if(NOT DEFINED legacy_oss_target)
        message(FATAL_ERROR "Could not find the imported target for unofficial-aliyun-oss-cpp-sdk.")
    endif()
    target_compile_definitions(main PRIVATE HAS_LEGACY_OSS_SDK=1)
    target_link_libraries(main PRIVATE "${legacy_oss_target}")
endif()
