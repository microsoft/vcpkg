## # vcpkg_install_cmake
##
## Build and install a cmake project.
##
## ## Usage:
## ```cmake
## vcpkg_install_cmake([MSVC_64_TOOLSET])
## ```
##
## ## Parameters:
## ### MSVC_64_TOOLSET
## This adds the `/p:PreferredToolArchitecture=x64` switch if the underlying buildsystem is MSBuild. Some large projects can run out of memory when linking if they use the 32-bit hosted tools.
##
## ## Notes:
## This command should be preceeded by a call to [`vcpkg_configure_cmake()`](vcpkg_configure_cmake.md).
##
## ## Examples:
##
## * [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
## * [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
## * [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
## * [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
function(vcpkg_install_cmake)
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
    else()
        set(BUILD_ARGS ${MSVC_EXTRA_ARGS})
    endif()

    message(STATUS "Package ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} --build . --config Release --target install -- ${BUILD_ARGS}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME package-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Package ${TARGET_TRIPLET}-rel done")

    message(STATUS "Package ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} --build . --config Debug --target install -- ${BUILD_ARGS}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME package-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Package ${TARGET_TRIPLET}-dbg done")
endfunction()
