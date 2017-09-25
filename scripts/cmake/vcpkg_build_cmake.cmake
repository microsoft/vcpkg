## # vcpkg_build_cmake
##
## Build a cmake project.
##
## ## Usage:
## ```cmake
## vcpkg_build_cmake([MSVC_64_TOOLSET] [DISABLE_PARALLEL])
## ```
##
## ## Parameters:
## ### MSVC_64_TOOLSET
## This adds the `/p:PreferredToolArchitecture=x64` switch to the underlying buildsystem parameters. Some large projects can run out of memory when linking if they use the 32-bit hosted tools.
##
## ### DISABLE_PARALLEL
## The /m parameter will not be added to the underlying buildsystem parameters
##
## ## Notes:
## This command should be preceeded by a call to [`vcpkg_configure_cmake()`](vcpkg_configure_cmake.md).
## Use [`vcpkg_install_cmake()`](vcpkg_configure_cmake.md) function if your CMake script supports the "install" target
##
## ## Examples:
##
## * [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
## * [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
## * [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
## * [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
function(vcpkg_build_cmake)
    cmake_parse_arguments(_bc "MSVC_64_TOOLSET;DISABLE_PARALLEL" "" "" ${ARGN})

    set(MSVC_EXTRA_ARGS
        "/p:VCPkgLocalAppDataDisabled=true"
        "/p:UseIntelMKL=No"
    )

    # Specifies the architecture of the toolset, NOT the architecture of the produced binary
    # This can help libraries that cause the linker to run out of memory.
    # https://support.microsoft.com/en-us/help/2891057/linker-fatal-error-lnk1102-out-of-memory
    if (_bc_MSVC_64_TOOLSET)
        list(APPEND MSVC_EXTRA_ARGS "/p:PreferredToolArchitecture=x64")
    endif()

    if (NOT _bc_DISABLE_PARALLEL)
        list(APPEND MSVC_EXTRA_ARGS "/m")
    endif()

    if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/build.ninja)
        set(BUILD_ARGS -v) # verbose output
	endif()
	
    if(_bc_MSVC_64_TOOLSET)
        set(BUILD_ARGS ${MSVC_EXTRA_ARGS})
    endif()

    message(STATUS "Build ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} --build . --config Release -- ${BUILD_ARGS}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME build-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Build ${TARGET_TRIPLET}-rel done")

    message(STATUS "Build ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} --build . --config Debug -- ${BUILD_ARGS}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Build ${TARGET_TRIPLET}-dbg done")
endfunction()
