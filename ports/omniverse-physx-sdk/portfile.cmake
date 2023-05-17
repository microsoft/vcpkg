#
# Port for Omniverse PhysX 5 - NVIDIA Corporation
# Marco Alesiani <malesiani@nvidia.com>
# Note: this port is NOT officially supported by NVIDIA.
#

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA-Omniverse/PhysX
    REF 104.2-physx-5.1.3 # newest tag
    SHA512 63838192cc7da45bc7f26d6204b48c5593afd976853378e6749a6c112b9079a9586ecceb85f088ce54678fe8ccfa22cc9a5a9c255e8fa8d01cf7a84aa5b269a7
    HEAD_REF release/104.2
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" VCPKG_BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" VCPKG_LINK_CRT_STATICALLY)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM_OPTIONS
        -DPX_BUILDSNIPPETS=OFF
        -DPX_BUILDPVDRUNTIME=OFF
        -DPX_GENERATE_STATIC_LIBRARIES=${VCPKG_BUILD_STATIC_LIBS}
    )
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(PLATFORM_OPTIONS
        -DPX_BUILDSNIPPETS=OFF
        -DPX_BUILDPVDRUNTIME=OFF
        -DPX_GENERATE_STATIC_LIBRARIES=${VCPKG_BUILD_STATIC_LIBS}
    )
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM_OPTIONS
        -DPX_BUILDSNIPPETS=OFF
        -DPX_BUILDPVDRUNTIME=OFF
        -DPX_GENERATE_STATIC_LIBRARIES=${VCPKG_BUILD_STATIC_LIBS}
        -DNV_USE_STATIC_WINCRT=${VCPKG_BUILD_STATIC_LIBS}
        -DNV_USE_DEBUG_WINCRT=${VCPKG_LINK_CRT_STATICALLY}
        -DPX_FLOAT_POINT_PRECISE_MATH=OFF
    )
else()
    message(FATAL_ERROR "Unsupported platform/architecture combination")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "${PLATFORM_OPTIONS}"
)


# if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_FREEBSD)
#     if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
#         message(FATAL_ERROR "Clang and Clang++ are required for building this port.")
#     endif()
# elseif(VCPKG_TARGET_IS_WINDOWS)
#     if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8 AND MSVC AND MSVC_VERSION GREATER_EQUAL 1930)
#         message(FATAL_ERROR "Windows 64-bit with MSVC 2022+ is required for building this port.")
#     endif()
# else()
#     message(FATAL_ERROR "Unsupported architecture for this port.")
# endif()

# Release and debug directories for artifacts. These will change according to the platform.
set(COMPILER_RELEASE_DIRECTORY "linux-release")
set(COMPILER_DEBUG_DIRECTORY "linux-debug")

# Generate projects and download dependencies via packman - the official NVIDIA 3rd party package repository
message("Executing pre-build script 'generate_projects' for PhysX repo and target platform...")
set(ENV{PM_PACKAGES_ROOT} ${SOURCE_PATH}/packman-root) # set the folder where we'll download all necessary deps via packman

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_FREEBSD)

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        execute_process(COMMAND ${CMAKE_COMMAND} -E env CC=${CLANG} CXX=${CLANGXX} ./generate_projects.sh linux-aarch64
            WORKING_DIRECTORY ${SOURCE_PATH}/physx
            RESULT_VARIABLE CMD_ERROR)

        set(COMPILER_RELEASE_DIRECTORY "linux-aarch64-release")
        set(COMPILER_DEBUG_DIRECTORY "linux-aarch64-debug")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        execute_process(COMMAND ${CMAKE_COMMAND} -E env CC=${CLANG} CXX=${CLANGXX} ./generate_projects.sh linux
            WORKING_DIRECTORY ${SOURCE_PATH}/physx
            RESULT_VARIABLE CMD_ERROR)

        set(COMPILER_RELEASE_DIRECTORY "linux-release")
        set(COMPILER_DEBUG_DIRECTORY "linux-debug")
    else()
        message(FATAL_ERROR "Unhandled or not yet supported Linux architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    if (CMD_ERROR)
        message(FATAL_ERROR "Failed to generate physx projects (Error: ${CMD_ERROR})")
    endif ()

    if(NOT EXISTS "${SOURCE_PATH}/physx/compiler/${COMPILER_RELEASE_DIRECTORY}/Makefile")
        message(FATAL_ERROR "missing Makefile - build project was not generated correctly")
    endif()

elseif(VCPKG_TARGET_IS_WINDOWS)

    if (VCPKG_CRT_LINKAGE STREQUAL static)
        set(CL_FLAGS_REL "/MT")
        set(CL_FLAGS_DBG "/MTd")
    else()
        set(CL_FLAGS_REL "/MD")
        set(CL_FLAGS_DBG "/MDd")
    endif()

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        execute_process(COMMAND generate_projects.bat vc17win64
            WORKING_DIRECTORY ${SOURCE_PATH}/physx
            RESULT_VARIABLE CMD_ERROR)

        set(COMPILER_RELEASE_DIRECTORY "vc17win64")
        set(COMPILER_DEBUG_DIRECTORY "vc17win64")
    else()
        message(FATAL_ERROR "Unhandled or not yet supported Windows architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    if (CMD_ERROR)
        message(FATAL_ERROR "Failed to generate physx projects (Error: ${CMD_ERROR})")
    endif ()

    if(NOT EXISTS "${SOURCE_PATH}/physx/compiler/${COMPILER_RELEASE_DIRECTORY}/PhysXSDK.sln")
        message(FATAL_ERROR "missing source sln - build project was not generated correctly")
    endif()

else()
    message(FATAL_ERROR "Unhandled or not yet supported target platform: ${VCPKG_CMAKE_SYSTEM_NAME}")
endif()

# Build release and debug versions
if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_FREEBSD)

    message("Now building release Makefile.. please wait..")
    vcpkg_execute_build_process(
        COMMAND /usr/bin/make V=1 -j 33 -f Makefile all
        WORKING_DIRECTORY "${SOURCE_PATH}/physx/compiler/${COMPILER_RELEASE_DIRECTORY}"
        LOGNAME "build-linux-${VCPKG_TARGET_ARCHITECTURE}-release"
    )

    message("Now building debug Makefile.. please wait..")
    vcpkg_execute_build_process(
        COMMAND /usr/bin/make V=1 -j 33 -f Makefile all
        WORKING_DIRECTORY "${SOURCE_PATH}/physx/compiler/${COMPILER_DEBUG_DIRECTORY}"
        LOGNAME "build-linux-${VCPKG_TARGET_ARCHITECTURE}-debug"
    )
elseif(VCPKG_TARGET_IS_WINDOWS)

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(PLATFORM Win32)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PLATFORM x64)
    endif()

    message("Now building ${PLATFORM} solution.. please wait..")
    vcpkg_build_msbuild(
        USE_VCPKG_INTEGRATION
        PROJECT_PATH "${SOURCE_PATH}/physx/compiler/${COMPILER_RELEASE_DIRECTORY}/PhysXSDK.sln"
        RELEASE_CONFIGURATION release
        DEBUG_CONFIGURATION debug
        PLATFORM ${PLATFORM}
    )
endif()

message("[PHYSX BUILD COMPLETED] Extracting build artifacts to vcpkg installation locations..")

# Artifacts paths are similar to <compiler>/<configuration>/[artifact] however vcpkg expects
# libraries, binaries and headers to be respectively in ${CURRENT_PACKAGES_DIR}/lib or ${CURRENT_PACKAGES_DIR}/debug/lib,
# ${CURRENT_PACKAGES_DIR}/bin or ${CURRENT_PACKAGES_DIR}/debug/bin and ${CURRENT_PACKAGES_DIR}/include.
# This function accepts a DIRECTORY named variable specifying the 'lib' or 'bin' destination directory and a SUFFIXES named
# variable which specifies a list of suffixes to extract in that folder (e.g. all the .lib or .pdb)
function(copy_in_vcpkg_destination_folder_physx_artifacts)
    macro(_copy_up _IN_DIRECTORY _OUT_DIRECTORY)
        foreach(_SUFFIX IN LISTS _fpa_SUFFIXES)
            file(GLOB_RECURSE _ARTIFACTS
                LIST_DIRECTORIES false
                "${SOURCE_PATH}/physx/${_IN_DIRECTORY}/*${_SUFFIX}"
            )
            if(_ARTIFACTS)
                file(COPY ${_ARTIFACTS} DESTINATION "${CURRENT_PACKAGES_DIR}/${_OUT_DIRECTORY}")
            endif()
        endforeach()
    endmacro()

    cmake_parse_arguments(_fpa "" "DIRECTORY" "SUFFIXES" ${ARGN})
    _copy_up("bin/*/release" ${_fpa_DIRECTORY}) # could be physx/bin/linux.clang/release or physx/bin/win.x86_64.vc142.mt/release
    _copy_up("bin/*/debug" "debug/${_fpa_DIRECTORY}")
endfunction()

# Extract artifacts in the right vcpkg destinations

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
copy_in_vcpkg_destination_folder_physx_artifacts(
    DIRECTORY "lib"
    SUFFIXES ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}
)
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
copy_in_vcpkg_destination_folder_physx_artifacts(
    DIRECTORY "bin"
    SUFFIXES ${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX} ".pdb"
)

# Copy headers
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")

# Renaming trick to finally have final folder structure as ${CURRENT_PACKAGES_DIR}/include/physx
file(RENAME "${SOURCE_PATH}/physx/include" "${SOURCE_PATH}/physx/physx")
file(COPY "${SOURCE_PATH}/physx/physx" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Remove wrong compiler directories and wrong artifacts which might have been created

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin/"
        "${CURRENT_PACKAGES_DIR}/debug/bin/"
    )
else()
    file(GLOB PHYSX_ARTIFACTS LIST_DIRECTORIES true
        "${CURRENT_PACKAGES_DIR}/bin/*"
        "${CURRENT_PACKAGES_DIR}/debug/bin/*"
    )
    foreach(_ARTIFACT IN LISTS PHYSX_ARTIFACTS)
        if(IS_DIRECTORY ${_ARTIFACT})
            file(REMOVE_RECURSE ${_ARTIFACT})
        endif()
    endforeach()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/source"
    "${CURRENT_PACKAGES_DIR}/source"
)

# Install license and cmake wrapper (which will let users find_package(physx) in CMake)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

message("[VCPKG Omniverse PhysX port execution completed]")
