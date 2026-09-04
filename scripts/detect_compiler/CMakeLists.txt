cmake_minimum_required(VERSION 3.20)
project(detect_compiler NONE)

if(CMAKE_GENERATOR STREQUAL "Ninja" AND CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(CMAKE_C_COMPILER_WORKS 1)
    set(CMAKE_C_COMPILER_FORCED 1)
    set(CMAKE_CXX_COMPILER_WORKS 1)
    set(CMAKE_CXX_COMPILER_FORCED 1)
endif()

enable_language(C)
enable_language(CXX)

# CMake 4.0 stopped mapping /usr/bin compilers on macOS into the active Xcode toolchain. Those are
# `xcrun` dispatch stubs, identical across every toolchain, so hash what they resolve to instead.
function(resolve_apple_compiler_stub compiler_path out_var)
    set("${out_var}" "${compiler_path}" PARENT_SCOPE)
    if(NOT CMAKE_HOST_APPLE OR NOT compiler_path MATCHES "^/usr/bin/")
        return()
    endif()

    get_filename_component(compiler_name "${compiler_path}" NAME)
    execute_process(
        COMMAND xcrun --find "${compiler_name}"
        OUTPUT_VARIABLE RESOLVED_PATH
        RESULT_VARIABLE XCRUN_RESULT
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(XCRUN_RESULT EQUAL 0 AND RESOLVED_PATH AND EXISTS "${RESOLVED_PATH}")
        set("${out_var}" "${RESOLVED_PATH}" PARENT_SCOPE)
    endif()
endfunction()

resolve_apple_compiler_stub("${CMAKE_C_COMPILER}" C_COMPILER_PATH)
resolve_apple_compiler_stub("${CMAKE_CXX_COMPILER}" CXX_COMPILER_PATH)

if(VCPKG_COMPILER_CACHE_FILE)
    if(EXISTS "${VCPKG_COMPILER_CACHE_FILE}")
        file(READ "${VCPKG_COMPILER_CACHE_FILE}" JSON_CONTENT)
    else()
        set(JSON_CONTENT "{}")
    endif()

    function(get_hash compiler_path out_var)
        file(TO_CMAKE_PATH "${compiler_path}" "compiler_path")
        file(SIZE "${compiler_path}" SIZE)
        file(TIMESTAMP "${compiler_path}" TIMESTAMP "%s" UTC)

        string(JSON COMPILER_EXISTS ERROR_VARIABLE JSON_ERROR GET "${JSON_CONTENT}" "${compiler_path}")
        if(NOT JSON_ERROR)
            # Get compiler attributes using JSON API
            string(JSON SIZE_JSON GET "${JSON_CONTENT}" "${compiler_path}" "size")
            string(JSON TIMESTAMP_JSON GET "${JSON_CONTENT}" "${compiler_path}" "timestamp")
            string(JSON HASH_JSON GET "${JSON_CONTENT}" "${compiler_path}" "hash")
            if ((SIZE_JSON EQUAL SIZE) AND (TIMESTAMP_JSON EQUAL TIMESTAMP))
                set("${out_var}" "${HASH_JSON}" PARENT_SCOPE)
                return()
            endif()
        endif()
        file(SHA1 "${compiler_path}" HASH)
        # Add new entry to JSON
        string(JSON JSON_CONTENT SET "${JSON_CONTENT}" "${compiler_path}" "{\"size\": ${SIZE}, \"timestamp\": ${TIMESTAMP}, \"hash\": \"${HASH}\"}")
        set("${out_var}" "${HASH}" PARENT_SCOPE)
        set(JSON_CONTENT "${JSON_CONTENT}" PARENT_SCOPE)
    endfunction()

    get_hash("${C_COMPILER_PATH}" C_HASH)
    get_hash("${CXX_COMPILER_PATH}" CXX_HASH)

    # Write updated JSON back to file
    file(WRITE "${VCPKG_COMPILER_CACHE_FILE}" "${JSON_CONTENT}")
else()
    file(SHA1 "${CXX_COMPILER_PATH}" CXX_HASH)
    file(SHA1 "${C_COMPILER_PATH}" C_HASH)
endif()
string(SHA1 COMPILER_HASH "${C_HASH}${CXX_HASH}")

message("#COMPILER_HASH#${COMPILER_HASH}")
message("#COMPILER_C_HASH#${C_HASH}")
message("#COMPILER_C_VERSION#${CMAKE_C_COMPILER_VERSION}")
message("#COMPILER_C_ID#${CMAKE_C_COMPILER_ID}")
message("#COMPILER_C_PATH#${C_COMPILER_PATH}")
message("#COMPILER_CXX_HASH#${CXX_HASH}")
message("#COMPILER_CXX_VERSION#${CMAKE_CXX_COMPILER_VERSION}")
message("#COMPILER_CXX_ID#${CMAKE_CXX_COMPILER_ID}")
message("#COMPILER_CXX_PATH#${CXX_COMPILER_PATH}")
