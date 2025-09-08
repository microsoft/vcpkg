###############################################################################################################
# Port for Omniverse PhysX 5 - NVIDIA Corporation
# Written by Marco Alesiani <malesiani@nvidia.com>
# Note: this port is NOT officially supported by NVIDIA.
# This port is also not a replacement for the old 'physx' port: the newest Omniverse PhysX dropped support
# for many platforms so older versions are still needed to support all previous platforms.
###############################################################################################################

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA-Omniverse/PhysX
    REF 106.4-physx-5.5.0 # newest tag
    SHA512 93ad438db81e9dc095741c837c0e797b56b35d6b77c7d1b1367b11bcbcb4ee1b8ff2affc27624d06829ac5e979f08d506fe727851fc383724e6633b775752d82
    HEAD_REF main
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(VCPKG_BUILD_STATIC_LIBS TRUE)
else()
    set(VCPKG_BUILD_STATIC_LIBS FALSE)
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(VCPKG_LINK_CRT_STATICALLY TRUE)
else()
    set(VCPKG_LINK_CRT_STATICALLY FALSE)
endif()

# Adjust CMake options settings based on the target platform
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
        -DNV_USE_STATIC_WINCRT=${VCPKG_LINK_CRT_STATICALLY}
        -DPX_FLOAT_POINT_PRECISE_MATH=OFF
    )
else()
    message(FATAL_ERROR "Unsupported platform/architecture combination")
endif()

######################## Download required deps ##############################

set($ENV{PM_PATHS} "")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://d4i3qtqj3r0z5.cloudfront.net/PhysXGpu%405.5.0.2aa3c8a3-release-106.4-windows-public.7z"
        FILENAME "PhysXGpu.7z"
        SHA512 84f2ba50ae89ebc959d8e35e99750a9fefddd51ba13d0bd96eac08d91b3de658508cb712e4ba253ed2d1be68589e0860747bf0bb324cbb2312574eb686aca06b
    )

    # 7z might not be preinstalled on Win machines
    vcpkg_find_acquire_program(7Z)
    set(ENV{PM_PhysXGpu_PATH} "${CURRENT_BUILDTREES_DIR}/PhysXGpu_dep")
    file(MAKE_DIRECTORY "$ENV{PM_PhysXGpu_PATH}")
    vcpkg_execute_required_process(
        COMMAND "${7Z}" x "${ARCHIVE}" "-o$ENV{PM_PhysXGpu_PATH}" "-y" "-bso0" "-bsp0"
        WORKING_DIRECTORY "$ENV{PM_PhysXGpu_PATH}"
        LOGNAME "extract-PhysXGpu"
    )
else()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        vcpkg_download_distfile(ARCHIVE
            URLS "https://d4i3qtqj3r0z5.cloudfront.net/PhysXGpu%405.5.0.2aa3c8a3-release-106.4-linux-aarch64-public.7z"
            FILENAME "PhysXGpu.7z"
            SHA512 92f47df4b7d6e1da21249acd4d13ce54a8ad6d5d21d9bb65e6a1af8b83494d22eb621fe77cde2fcea61ad56048894c9b73cded7193c7519ff62ee7e23c6d83e3
        )
    else()
        vcpkg_download_distfile(ARCHIVE
            URLS "https://d4i3qtqj3r0z5.cloudfront.net/PhysXGpu%405.5.0.2aa3c8a3-release-106.4-linux-x86_64-public.7z"
            FILENAME "PhysXGpu.7z"
            SHA512 4728bd0c37f1c931e31b1aa3354d45f157ca4930199840cb98524f02fa0422f7e6f72dce860111c6494b0bde8944a758e9dd8940d7015057e528d4db98d6bd0c
        )
    endif()

    vcpkg_extract_source_archive(PHYSXGPU_SOURCE_PATH
        NO_REMOVE_ONE_LEVEL
        ARCHIVE "${ARCHIVE}"
        BASE_DIRECTORY PhysXGpu_dep
    )
    set(ENV{PM_PhysXGpu_PATH} "${PHYSXGPU_SOURCE_PATH}")
endif()
message(STATUS "Extracted dependency to $ENV{PM_PhysXGpu_PATH}")
list(APPEND ENV{PM_PATHS} $ENV{PM_PhysXGpu_PATH})

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://d4i3qtqj3r0z5.cloudfront.net/PhysXDevice%4018.12.7.6.7z"
        FILENAME "PhysXDevice.7z"
        SHA512 0b75ea060a63f307a63ebfd5867cec06ab431a4b1a41e65d0a1ff7be115daf9ce080222128bdeb6d424ffa0aa9343c495455e814be424db1ce11cce8e760d5ff
    )

    set(ENV{PM_PhysXDevice_PATH} "${CURRENT_BUILDTREES_DIR}/PhysXDevice_dep")
    file(MAKE_DIRECTORY "$ENV{PM_PhysXDevice_PATH}")
    vcpkg_find_acquire_program(7Z)
    vcpkg_execute_required_process(
        COMMAND "${7Z}" x "${ARCHIVE}" "-o$ENV{PM_PhysXDevice_PATH}" "-y" "-bso0" "-bsp0"
        WORKING_DIRECTORY "$ENV{PM_PhysXDevice_PATH}"
        LOGNAME "extract-PhysXDevice"
    )
endif()
message(STATUS "Extracted dependency to $ENV{PM_PhysXDevice_PATH}")
list(APPEND ENV{PM_PATHS} $ENV{PM_PhysXDevice_PATH})

if(VCPKG_TARGET_IS_WINDOWS)
    set(ENV{PM_freeglut_PATH} "${CURRENT_BUILDTREES_DIR}/freeglut_dep")
    file(MAKE_DIRECTORY "$ENV{PM_freeglut_PATH}")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://d4i3qtqj3r0z5.cloudfront.net/freeglut-windows%403.4_1.1.7z"
        FILENAME "freeglut.7z"
        SHA512 c01cb75dd466d6889a72d7236669bfce841cc6da9e0edb4208c4affb5ca939f28d64bc3d988bc85d98c589b0b42ac3464f606c89f6c113106669fc9fe84000e5
    )
    vcpkg_find_acquire_program(7Z)
    vcpkg_execute_required_process(
        COMMAND "${7Z}" x "${ARCHIVE}" "-o$ENV{PM_freeglut_PATH}" "-y" "-bso0" "-bsp0"
        WORKING_DIRECTORY "$ENV{PM_freeglut_PATH}"
        LOGNAME "extract-freeglut"
    )
    message(STATUS "Extracted dependency to $ENV{PM_freeglut_PATH}")
    list(APPEND ENV{PM_PATHS} $ENV{PM_freeglut_PATH})
endif()

######################## Now generate ALL CMake parameters according to our distribution ##############################

set(PHYSX_ROOT_DIR "${SOURCE_PATH}/physx")

# Set common parameters
set(common_params -DCMAKE_PREFIX_PATH=$ENV{PM_PATHS} -DPHYSX_ROOT_DIR=${PHYSX_ROOT_DIR} -DPX_OUTPUT_LIB_DIR=${PHYSX_ROOT_DIR} -DPX_OUTPUT_BIN_DIR=${PHYSX_ROOT_DIR})

# Set platform and compiler specific parameters (physx expects binaries to live in these locations)
if(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/linux-aarch64/PhysX)
    set(platformCMakeParams -DTARGET_BUILD_PLATFORM=linux -DPX_OUTPUT_ARCH=arm)
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/linux/PhysX)
    set(platformCMakeParams -DTARGET_BUILD_PLATFORM=linux -DPX_OUTPUT_ARCH=x86)
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64") # Note: this will work for any Win64, default is vc17win64
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/vc17win64/PhysX)
    set(platformCMakeParams -DTARGET_BUILD_PLATFORM=windows -DPX_OUTPUT_ARCH=x86)
endif()

# Also make sure the downloaded GPU driver is found as a binary
list(APPEND platformCMakeParams -DPHYSX_PHYSXGPU_PATH=$ENV{PM_PhysXGpu_PATH}/bin)

set(cmakeParams ${platformCMakeParams} ${common_params} ${cmakeParams})

# Finally invoke physx's CMake to configure the PhysX project
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/physx/compiler/public"
    GENERATOR "${generator}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DCMAKE_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}
        ${PLATFORM_OPTIONS}
        -DPHYSX_ROOT_DIR=${PHYSX_ROOT_DIR}
        ${cmakeParams}
    OPTIONS_DEBUG
        -DNV_USE_DEBUG_WINCRT=TRUE
    DISABLE_PARALLEL_CONFIGURE
    MAYBE_UNUSED_VARIABLES
        PX_OUTPUT_ARCH
        PHYSX_PHYSXGPU_PATH
)

# Compile and install in vcpkg's final installation directories all of the include headers and binaries for debug/release
vcpkg_cmake_install()

######################## Extract to final vcpkg install locations and fixup artifacts in wrong dirs ##############################

message("[PHYSX BUILD COMPLETED] Extracting build artifacts to vcpkg installation locations..")

# Artifacts paths are similar to <compiler>/<configuration>/[artifact] however vcpkg expects
# libraries, binaries and headers to be respectively in ${CURRENT_PACKAGES_DIR}/lib or ${CURRENT_PACKAGES_DIR}/debug/lib,
# ${CURRENT_PACKAGES_DIR}/bin or ${CURRENT_PACKAGES_DIR}/debug/bin and ${CURRENT_PACKAGES_DIR}/include.
# This function accepts a variable named DIRECTORY specifying the 'lib' or 'bin' destination directory and a SUFFIXES named
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
    _copy_up("bin/*/release" "${_fpa_DIRECTORY}") # could be physx/bin/linux.clang/release or physx/bin/win.x86_64.vc142.mt/release
    if(NOT VCPKG_BUILD_TYPE)
      _copy_up("bin/*/debug" "debug/${_fpa_DIRECTORY}")
    endif()
endfunction()

# Create output directories
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
if(NOT VCPKG_BUILD_TYPE)
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # We'll also place the Gpu driver shared library in bin and debug/bin
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    if(NOT VCPKG_BUILD_TYPE)
      file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()

copy_in_vcpkg_destination_folder_physx_artifacts(
    DIRECTORY "lib"
    SUFFIXES ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}
)

if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Also copy whatever .so/.dll were built. Remember that there should be NO /bin directory (nor debug/bin)
    # when using static linkage
    copy_in_vcpkg_destination_folder_physx_artifacts(
        DIRECTORY "bin"
        SUFFIXES ${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX} ".pdb"
    )
endif()

# Special treatment is reserved for the PhysXGpu_64 shared library (downloaded by packman).
# This is a 3rd party "optional functionality" dependency.
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
set(GPULIBNAMES "")
if(VCPKG_TARGET_IS_LINUX) # Both for arm and x64
    list(APPEND GPULIBNAMES "libPhysXGpu_64.so" "libPhysXDevice64.so")
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND GPULIBNAMES "PhysXGpu_64.dll" "PhysXDevice64.dll")
endif()

function(_copy_single_files_from_dir_to_destdir _IN_FILES _IN_DIR _OUT_DIR)
    file(GLOB_RECURSE _ARTIFACTS
        LIST_DIRECTORIES false
        "${_IN_DIR}"
    )
    foreach(_ARTIFACT IN LISTS _ARTIFACTS)
        foreach(_FILE IN LISTS _IN_FILES)
            if("${_ARTIFACT}" MATCHES "${_FILE}")
                file(COPY "${_ARTIFACT}" DESTINATION "${_OUT_DIR}")
            endif()
        endforeach()
    endforeach()
endfunction()

# Put it in binary directories, it's an optional component (only release binaries should go in tools/)
_copy_single_files_from_dir_to_destdir("${GPULIBNAMES}" "${SOURCE_PATH}/physx/bin/*/release/*" "${CURRENT_PACKAGES_DIR}/tools")

# Copy headers to port's destination folder
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")

# Renaming trick to finally have final folder structure as ${CURRENT_PACKAGES_DIR}/include/physx
file(RENAME "${SOURCE_PATH}/physx/include" "${SOURCE_PATH}/physx/physx")
file(COPY "${SOURCE_PATH}/physx/physx" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Remove useless build directories
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/source"
    "${CURRENT_PACKAGES_DIR}/source"
)

# Install the cmake config that users will use, replace -if any- only @variables@
configure_file("${CMAKE_CURRENT_LIST_DIR}/omniverse-physx-sdk-config.cmake" "${CURRENT_PACKAGES_DIR}/share/omniverse-physx-sdk/unofficial-omniverse-physx-sdk-config.cmake" @ONLY)

if(NOT VCPKG_BUILD_TYPE)
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share")
  file(COPY "${CURRENT_PACKAGES_DIR}/share/omniverse-physx-sdk" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/")
endif()
# Fixup to repackage the CMake config as 'unofficial-omniverse-physx-sdk'
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-omniverse-physx-sdk
                         CONFIG_PATH share/omniverse-physx-sdk)

# Remove fixup wrong directories
file(REMOVE_RECURSE
     "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_TARGET_IS_WINDOWS)
    # Remove freeglut (cannot be skipped in public release builds, but unnecessary)
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/bin/freeglut.dll"
        "${CURRENT_PACKAGES_DIR}/debug/bin/freeglutd.dll"
    )
endif()

# Install license and usage file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

message("[VCPKG Omniverse PhysX port execution completed]")
