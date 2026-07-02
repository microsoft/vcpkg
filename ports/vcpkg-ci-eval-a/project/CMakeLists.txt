cmake_minimum_required(VERSION 3.20)
project(vcpkg-ci-eval-a VERSION 1.0.0 LANGUAGES C)

option(WITH_FEATURE_A "Build platform utilities module" OFF)
option(WITH_FEATURE_B "Build and install library with CMake config" OFF)
option(WITH_FEATURE_C "Install shared configuration header" OFF)

if(WITH_FEATURE_A)
    add_library(eval_utils STATIC utils.c)
    target_include_directories(eval_utils PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
endif()

if(WITH_FEATURE_B)
    add_library(eval_lib INTERFACE)
    target_include_directories(eval_lib INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
    )
    install(TARGETS eval_lib EXPORT eval_lib-targets)
    install(FILES eval.h DESTINATION include/vcpkg-ci-eval-a)
    install(EXPORT eval_lib-targets
        FILE vcpkg-ci-eval-a-config.cmake
        DESTINATION lib/cmake/vcpkg-ci-eval-a
    )
endif()

if(WITH_FEATURE_C)
    install(FILES config.h DESTINATION include/vcpkg-ci-eval)
endif()
