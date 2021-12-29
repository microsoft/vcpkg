# This module helps to acquire a version of CMake satisfying a particular minimum.
# As a last resort, it will always use the current `CMAKE_COMMAND`.

if(COMMAND vcpkg_maintainer_options_minimum_cmake)
    return()
endif()

# Self-test invoked at vcpkg-maintainer-options build time.
# As a side effect, it handles the cmake download in download-only mode.
function(z_vcpkg_maintainer_options_test_minimum-cmake)
    set(versions 3.4.3)
    foreach(version IN LISTS versions)
        vcpkg_maintainer_options_minimum_cmake(OUT_VAR cmake VERSION ${version})
        if(NOT cmake)
            message(FATAL_ERROR "Unable to find a suitable CMake >= ${version}")
        endif()
    endforeach()
endfunction()

# Helper function for downloading a particular version of CMake.
# It also ensures that it is really executable (runtime dependencies).
function(z_vcpkg_maintainer_options_acquire_cmake)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "ARCHIVE;BIN_DIR;OUT_VAR;SHA512"
        ""
    )
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "z_vcpkg_maintainer_options_acquire_cmake was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(keyword IN ITEMS ARCHIVE BIN_DIR OUT_VAR SHA512)
        if(NOT arg_${keyword})
            message(FATAL_ERROR "z_vcpkg_maintainer_options_acquire_cmake must be passed a ${keyword} argument.")
        endif()
    endforeach()

    if(NOT arg_ARCHIVE MATCHES "^(cmake-(([0-9]+\\.[0-9]+)\\.[0-9]+)[^/]+)\\.(tar\\.gz|zip)\$")
        message(FATAL_ERROR "Could not determine version from archive name ${arg_ARCHIVE}.")
    endif()
    set(name "${CMAKE_MATCH_1}")
    set(version "${CMAKE_MATCH_2}")
    set(cmake_major_minor "${CMAKE_MATCH_3}")
    
    set(build_dir "${BUILDTREES_DIR}/vcpkg-maintainer-options")
    set(cache_dir "${build_dir}/${name}")
    if(EXISTS "${cache_dir}")
        message(STATUS "Using ${cache_dir}")
    else()
        message(STATUS "Creating ${cache_dir}")
        file(MAKE_DIRECTORY "${build_dir}")
        vcpkg_download_distfile(cmake_archive
            FILENAME "${arg_ARCHIVE}"
            URLS "https://github.com/Kitware/CMake/releases/download/v${version}/${arg_ARCHIVE}"
                 "https://cmake.org/files/v${cmake_major_minor}/${arg_ARCHIVE}"
            SHA512 ${arg_SHA512}
        )
        vcpkg_extract_source_archive_ex(
            OUT_SOURCE_PATH cmake_dir
            ARCHIVE "${cmake_archive}"
            REF "${version}"
            WORKING_DIRECTORY "${build_dir}"
        )
        file(RENAME "${cmake_dir}" "${cache_dir}")
    endif()
    set(cmake "${cache_dir}/${arg_BIN_DIR}/cmake")
    execute_process(
        COMMAND "${cmake}" --version
        OUTPUT_VARIABLE cmake_output
        RESULT_VARIABLE cmake_failure
    )
    string(REGEX MATCH "[1-9][0-9]*\\.[0-9]*\\.[0-9]*" cmake_version "${cmake_output}")
    if(cmake_failure)
        message(WARNING "Failed to run ${cmake}. To enable tests with this version, resolve missing runtime dependencies.")
        set(cmake IGNORE)
    elseif(NOT cmake_version)
        message(WARNING "Failed to determine version for '${cmake}'.")
        set(cmake IGNORE)
    else()
        list(APPEND cmake VERSION "${cmake_version}")
    endif()
    set("${arg_OUT_VAR}" "${cmake}" PARENT_SCOPE)
endfunction()

# Acquire a minimum version of CMake satisfying the given condition
function(vcpkg_maintainer_options_minimum_cmake)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "OUT_VAR;VERSION"
        ""
    )
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_maintainer_options_minimum_cmake was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(keyword IN ITEMS OUT_VAR VERSION)
        if(NOT arg_${keyword})
            message(FATAL_ERROR "vcpkg_maintainer_options_minimum_cmake must be passed a ${keyword} argument.")
        endif()
    endforeach()

    string(MAKE_C_IDENTIFIER "Z_VCPKG_MAINTAINER_OPTIONS_MINIMUM_CMAKE_${arg_VERSION}" cache_var)
    if(NOT DEFINED "${cache_var}")
        if(arg_VERSION VERSION_LESS_EQUAL "3.4.3")
            if(HOST_TRIPLET MATCHES "^x.*-(windows|mingw)")
                z_vcpkg_maintainer_options_acquire_cmake(
                    OUT_VAR "cmake"
                    ARCHIVE "cmake-3.4.3-win32-x86.zip"
                    SHA512  "c74a8f85ce04a2c0f68fd315a9a7e2fee5cc98af9e8117cca6b35a4f0942cae2d101672e5936a8bfc20289c8c82da582531495308657348a1121e3f568588bd3"
                    BIN_DIR "bin"
                )
            elseif(HOST_TRIPLET MATCHES "^x.*-osx")
                z_vcpkg_maintainer_options_acquire_cmake(
                    OUT_VAR "cmake"
                    ARCHIVE "cmake-3.4.3-Darwin-x86_64.tar.gz"
                    SHA512  "c3da566a19e95b8f91bf601518b9c49304b9bb8500f5a086eb2c867514176278e51dd893952b8ab54a2839ed02c898036c7985fe0bb761db9ccb988343463ea2"
                    BIN_DIR "CMake.app/Contents/bin"
                )
            elseif(HOST_TRIPLET MATCHES "^x.*-linux")
                z_vcpkg_maintainer_options_acquire_cmake(
                    OUT_VAR "cmake"
                    ARCHIVE "cmake-3.4.3-Linux-x86_64.tar.gz"
                    SHA512  "455b8f940ccda0ba1169d3620db67c0bf89284126386408cd28b76b66c59c4c2ea5ad8def0095166e7524f6cf5202f117a2fa49e1525f93ed711657a5d2ae988"
                    BIN_DIR "bin"
                )
            endif()
        endif()
        if(NOT cmake)
            set(cmake "${CMAKE_COMMAND}" VERSION  "${CMAKE_VERSION}")
        endif()
        set("${cache_var}" "${cmake}" CACHE STRING "Version and path of CMake executable >= ${arg_VERSION}")
    endif()
    set("${arg_OUT_VAR}" "${${cache_var}}" PARENT_SCOPE)
endfunction()
