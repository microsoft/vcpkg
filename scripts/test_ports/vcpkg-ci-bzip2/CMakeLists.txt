cmake_minimum_required(VERSION 3.21)
project(vcpkg-ci-bzip2 LANGUAGES C)

option(VCPKG_CI_RUN_TEST "Run the test executable after building it" OFF)

find_package(BZip2 1.0.8 REQUIRED)

foreach(result_variable IN ITEMS
    BZIP2_FOUND
    BZip2_FOUND
    BZIP2_INCLUDE_DIR
    BZIP2_INCLUDE_DIRS
    BZIP2_LIBRARIES
    BZIP2_LIBRARY
    BZIP2_LIBRARY_RELEASE
    BZIP2_LIBRARY_DEBUG
    BZIP2_NEED_PREFIX
    BZIP2_VERSION_STRING
)
    if(NOT DEFINED ${result_variable})
        message(FATAL_ERROR "FindBZip2 did not define ${result_variable}")
    endif()
endforeach()
if(NOT BZIP2_FOUND OR NOT BZip2_FOUND)
    message(FATAL_ERROR "FindBZip2 result variables do not report success")
endif()
if(NOT BZIP2_VERSION_STRING VERSION_EQUAL "1.0.8")
    message(FATAL_ERROR "Unexpected BZIP2_VERSION_STRING: ${BZIP2_VERSION_STRING}")
endif()
if(NOT BZIP2_INCLUDE_DIRS OR NOT BZIP2_LIBRARIES)
    message(FATAL_ERROR "FindBZip2 did not populate its include or library variables")
endif()
if(NOT TARGET BZip2::BZip2)
    message(FATAL_ERROR "FindBZip2 did not define BZip2::BZip2")
endif()

get_target_property(bzip2_target_type BZip2::BZip2 TYPE)
if(WIN32 AND BUILD_SHARED_LIBS)
    if(NOT bzip2_target_type STREQUAL "SHARED_LIBRARY")
        message(FATAL_ERROR "Expected a shared imported BZip2 target, got ${bzip2_target_type}")
    endif()
else()
    if(NOT bzip2_target_type STREQUAL "UNKNOWN_LIBRARY")
        message(FATAL_ERROR "The wrapper changed the built-in target type for a non-DLL build")
    endif()
endif()

add_executable(test main.c)
target_link_libraries(test PRIVATE BZip2::BZip2)
install(TARGETS test RUNTIME DESTINATION bin/vcpkg-ci-bzip2)

set(runtime_file "${CMAKE_CURRENT_BINARY_DIR}/runtime-dlls-$<CONFIG>.txt")
file(GENERATE OUTPUT "${runtime_file}" CONTENT "$<JOIN:$<TARGET_RUNTIME_DLLS:test>,\n>")

if(WIN32 AND BUILD_SHARED_LIBS)
    set(runtime_copy_dir "${CMAKE_CURRENT_BINARY_DIR}/runtime-copy/$<CONFIG>")

    add_custom_command(TARGET test POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E rm -rf "${runtime_copy_dir}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${runtime_copy_dir}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            $<TARGET_RUNTIME_DLLS:test>
            "${runtime_copy_dir}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "$<TARGET_FILE:test>"
            "${runtime_copy_dir}"
        COMMAND "${CMAKE_COMMAND}"
            "-DRUNTIME_FILE=${runtime_file}"
            "-DCOPY_DIR=${runtime_copy_dir}"
            "-DEXPECTED_DLL=bz2$<$<CONFIG:Debug>:d>.dll"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/verify-runtime.cmake"
        COMMAND "${runtime_copy_dir}/$<TARGET_FILE_NAME:test>"
        COMMAND_EXPAND_LISTS
        VERBATIM
    )
elseif(NOT BUILD_SHARED_LIBS)
    add_custom_command(TARGET test POST_BUILD
        COMMAND "${CMAKE_COMMAND}"
            "-DRUNTIME_FILE=${runtime_file}"
            -DEXPECT_EMPTY=ON
            -P "${CMAKE_CURRENT_SOURCE_DIR}/verify-runtime.cmake"
        VERBATIM
    )
endif()

if(VCPKG_CI_RUN_TEST AND NOT (WIN32 AND BUILD_SHARED_LIBS))
    add_custom_command(TARGET test POST_BUILD COMMAND "$<TARGET_FILE:test>" VERBATIM)
endif()
