###############################################################################################################
# Port for Omniverse PhysX 5 - NVIDIA Corporation
# Written by Marco Alesiani <malesiani@nvidia.com>
# Note: this port is NOT officially supported by NVIDIA.
# This port is also not a replacement for the 'physx' port: the newest Omniverse PhysX dropped support
# for many platforms so the old one will continue to be community maintained to support all previous platforms.
###############################################################################################################

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA-Omniverse/PhysX
    REF 104.2-physx-5.1.3 # newest tag
    SHA512 63838192cc7da45bc7f26d6204b48c5593afd976853378e6749a6c112b9079a9586ecceb85f088ce54678fe8ccfa22cc9a5a9c255e8fa8d01cf7a84aa5b269a7
    HEAD_REF release/104.2
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

# Target platform detection for packman (the NVIDIA dependency downloader) and CMake options settings
if(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM_OPTIONS
        -DPX_BUILDSNIPPETS=OFF
        -DPX_BUILDPVDRUNTIME=OFF
        -DPX_GENERATE_STATIC_LIBRARIES=${VCPKG_BUILD_STATIC_LIBS}
    )
    set(targetPlatform "linux")
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(PLATFORM_OPTIONS
        -DPX_BUILDSNIPPETS=OFF
        -DPX_BUILDPVDRUNTIME=OFF
        -DPX_GENERATE_STATIC_LIBRARIES=${VCPKG_BUILD_STATIC_LIBS}
    )
    set(targetPlatform "linuxAarch64")
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")

    set(PLATFORM_OPTIONS
        -DPX_BUILDSNIPPETS=OFF
        -DPX_BUILDPVDRUNTIME=OFF
        -DPX_GENERATE_STATIC_LIBRARIES=${VCPKG_BUILD_STATIC_LIBS}
        -DNV_USE_STATIC_WINCRT=${VCPKG_LINK_CRT_STATICALLY}
        -DPX_FLOAT_POINT_PRECISE_MATH=OFF
    )
    set(PLATFORM_OPTIONS_RELEASE "")
    set(PLATFORM_OPTIONS_DEBUG "")

    # if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    #     list(APPEND PLATFORM_OPTIONS_RELEASE -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL)
    #     list(APPEND PLATFORM_OPTIONS_RELEASE -DWINCRT_NDEBUG="/MD")
    #     list(APPEND PLATFORM_OPTIONS_DEBUG -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebugDLL)
    #     list(APPEND PLATFORM_OPTIONS_DEBUG -DWINCRT_DEBUG="/MDd")
    # else()
    #     list(APPEND PLATFORM_OPTIONS_RELEASE -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded)
    #     # list(APPEND PLATFORM_OPTIONS_RELEASE -DWINCRT_NDEBUG="/MT")
    #     list(APPEND PLATFORM_OPTIONS_DEBUG -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug)
    #     list(APPEND PLATFORM_OPTIONS_DEBUG -DWINCRT_DEBUG="/MTd")
    # endif()

    # Note: it would have been more correct to specify "win64" here, but we specify this so that packman can download
    # the right dependencies on windows (see the "platforms" field in the dependencies.xml), that will also later
    # set up the correct PM_xxx environment variables that we can pass to the cmake generation invocation to find
    # whatever the PhysX project needs. Note that vc17(2022) is not required: the latest repo is guaranteed to work
    # with vc15, vc16 and vc17 on x64 Windows. The binaries for these platforms downloaded by packman should be the same.
    set(targetPlatform "vc17win64")
else()
    message(FATAL_ERROR "Unsupported platform/architecture combination")
endif()








######################## TENTATIVE TO DOWNLOAD AND CACHE!!! ##############################

set($ENV{PM_PATHS} "")

set(ENV{PM_CMakeModules_PATH} "${CURRENT_BUILDTREES_DIR}/temp/CMakeModules")
list(APPEND ENV{PM_PATHS} $ENV{PM_CMakeModules_PATH})

# Create temporary directory
file(MAKE_DIRECTORY "$ENV{PM_CMakeModules_PATH}")

# Download file
vcpkg_download_distfile(ARCHIVE
    URLS "https://d4i3qtqj3r0z5.cloudfront.net/CMakeModules%401.28.trunk.32494385.7z"
    FILENAME "CMakeModules.7z"
    SHA512 cccb0347d27a2b1391ffd3285fa19ca884fed91d8bf2e1683f86efad8aa0151a6e27080a6bec8975be585e4a51dd92cf85ac0cacf12ba28dce6e6efe74f57202
)

# Find 7zip program
vcpkg_find_acquire_program(7Z)

# Extract the file
message(STATUS "Extracting $ENV{PM_CMakeModules_PATH} file")
vcpkg_execute_required_process(
    COMMAND "${7Z}" x "${ARCHIVE}" "-o$ENV{PM_CMakeModules_PATH}" "-y" "-bso0" "-bsp0"
    WORKING_DIRECTORY "$ENV{PM_CMakeModules_PATH}"
    LOGNAME "extract-CMakeModules"
)



set(ENV{PM_PhysXGpu_PATH} "${CURRENT_BUILDTREES_DIR}/temp/PhysXGpu")
list(APPEND ENV{PM_PATHS} $ENV{PM_PhysXGpu_PATH})

# Create temporary directory
file(MAKE_DIRECTORY "$ENV{PM_PhysXGpu_PATH}")

# Download file
vcpkg_download_distfile(ARCHIVE
    URLS "https://d4i3qtqj3r0z5.cloudfront.net/PhysXGpu%40104.2-5.1.264.32487460-public.zip"
    FILENAME "PhysXGpu.zip"
    SHA512 6bd0384c134d909b0c2d32b9639dde5d8a90b3de74e1971b913d646f284d3dd042e3cfd0d4a868e57370621e23e76001b3eac47ac235c6dd798328e199471502
)

# Find 7zip program
vcpkg_find_acquire_program(7Z)

# Extract the file
message(STATUS "Extracting $ENV{PM_PhysXGpu_PATH} file")
vcpkg_execute_required_process(
    COMMAND "${7Z}" x "${ARCHIVE}" "-o$ENV{PM_PhysXGpu_PATH}" "-y" "-bso0" "-bsp0"
    WORKING_DIRECTORY "$ENV{PM_PhysXGpu_PATH}"
    LOGNAME "extract-PhysXGpu"
)






set(ENV{PM_PhysXDevice_PATH} "${CURRENT_BUILDTREES_DIR}/temp/PhysXDevice")
list(APPEND ENV{PM_PATHS} $ENV{PM_PhysXDevice_PATH})

# Create temporary directory
file(MAKE_DIRECTORY "$ENV{PM_PhysXDevice_PATH}")

# Download file
vcpkg_download_distfile(ARCHIVE
    URLS "https://d4i3qtqj3r0z5.cloudfront.net/PhysXDevice%4018.12.7.4.7z"
    FILENAME "PhysXDevice.7z"
    SHA512 c20eb2f1e0dcb9d692cb718ca7e3a332291e72a09614f37080f101e5ebc1591033029f0f1e6fba33a17d4c9f59f13e561f3fc81cee34cd53d50b579c01dd3f3c
)

# Find 7zip program
vcpkg_find_acquire_program(7Z)

# Extract the file
message(STATUS "Extracting $ENV{PM_PhysXDevice_PATH} file")
vcpkg_execute_required_process(
    COMMAND "${7Z}" x "${ARCHIVE}" "-o$ENV{PM_PhysXDevice_PATH}" "-y" "-bso0" "-bsp0"
    WORKING_DIRECTORY "$ENV{PM_PhysXDevice_PATH}"
    LOGNAME "extract-PhysXDevice"
)




if(targetPlatform STREQUAL "vc17win64")

    set(ENV{PM_freeglut_PATH} "${CURRENT_BUILDTREES_DIR}/temp/freeglut")
    list(APPEND ENV{PM_PATHS} $ENV{PM_freeglut_PATH})

    # Create temporary directory
    file(MAKE_DIRECTORY "$ENV{PM_freeglut_PATH}")

    # Download file
    vcpkg_download_distfile(ARCHIVE
        URLS "https://d4i3qtqj3r0z5.cloudfront.net/freeglut-windows%403.4_1.1.7z"
        FILENAME "freeglut.7z"
        SHA512 c01cb75dd466d6889a72d7236669bfce841cc6da9e0edb4208c4affb5ca939f28d64bc3d988bc85d98c589b0b42ac3464f606c89f6c113106669fc9fe84000e5
    )

    # Find 7zip program
    vcpkg_find_acquire_program(7Z)

    # Extract the file
    message(STATUS "Extracting $ENV{PM_freeglut_PATH} file")
    vcpkg_execute_required_process(
        COMMAND "${7Z}" x "${ARCHIVE}" "-o$ENV{PM_freeglut_PATH}" "-y" "-bso0" "-bsp0"
        WORKING_DIRECTORY "$ENV{PM_freeglut_PATH}"
        LOGNAME "extract-freeglut"
    )

endif()


# # All of the following code mimicks generate_projects.sh

set(PHYSX_ROOT_DIR "${SOURCE_PATH}/physx")
# set(PACKMAN_CMD "${PHYSX_ROOT_DIR}/buildtools/packman/packman")

# # Check if packman command exists

# if(VCPKG_TARGET_IS_WINDOWS)
#     set(PACKMAN_CMD "${PACKMAN_CMD}.cmd")
# endif()

# if(NOT EXISTS ${PACKMAN_CMD})
#     message(FATAL_ERROR "Cannot find packman (the NVIDIA package manager to download PhysX deps) searched location: ${PACKMAN_CMD}")
# endif()

# # Pull the dependencies using the found packman
# if(VCPKG_TARGET_IS_LINUX)
#     execute_process(
#         COMMAND bash -c  "source ${PACKMAN_CMD} pull ${PHYSX_ROOT_DIR}/dependencies.xml --platform ${targetPlatform}; env"
#         RESULT_VARIABLE result # return code or error string
#         OUTPUT_VARIABLE output_envs
#         ERROR_VARIABLE error_output
#         WORKING_DIRECTORY ${PHYSX_ROOT_DIR}
#     )
# elseif(VCPKG_TARGET_IS_WINDOWS)
#     execute_process(
#         COMMAND cmd /c "set PM_DISABLE_VS_WARNING=1 & ${PACKMAN_CMD} pull ${PHYSX_ROOT_DIR}/dependencies.xml --platform ${targetPlatform} & set"
#         RESULT_VARIABLE result # return code or error string
#         OUTPUT_VARIABLE output_envs
#         ERROR_VARIABLE error_output
#         WORKING_DIRECTORY ${PHYSX_ROOT_DIR}
#     )
# endif()

# if(NOT ${result} EQUAL 0)
#     message(FATAL_ERROR "Error '${result}' occurred while pulling dependencies using packman (stdout: ${output_envs}, stderr: ${error_output})")
# endif()

# # Packman downloads the deps and also sets environment variables with paths on where to find these:
# # let's parse the stdout for environment variables and inject them into ours (hacky)
# string(REPLACE "\n" ";" output_envs ${output_envs})
# foreach(env ${output_envs})
#     if(env MATCHES "^([^=]+)=(.*)$")
#         set(ENV{${CMAKE_MATCH_1}} "${CMAKE_MATCH_2}")
#     endif()
# endforeach()

# if(NOT EXISTS $ENV{PM_CMakeModules_PATH}) # Mandatory on every supported platform
#     message(FATAL_ERROR "CMake modules path was not found (packman dependency pull failure?)")
# endif()

# Now generate ALL cmake parameters according to our distribution

# Set common parameters
set(common_params -DCMAKE_PREFIX_PATH=$ENV{PM_PATHS} -DPHYSX_ROOT_DIR=${PHYSX_ROOT_DIR} -DPX_OUTPUT_LIB_DIR=${PHYSX_ROOT_DIR} -DPX_OUTPUT_BIN_DIR=${PHYSX_ROOT_DIR})

# if(DEFINED ENV{GENERATE_SOURCE_DISTRO} AND "$ENV{GENERATE_SOURCE_DISTRO}" STREQUAL "1")
#     list(APPEND common_params -DPX_GENERATE_SOURCE_DISTRO=1)
# endif()

# Set platform and compiler specific parameters
if(targetPlatform STREQUAL "linuxAarch64")
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/linux-aarch64/PhysX)
    set(platformCMakeParams -DTARGET_BUILD_PLATFORM=linux -DPX_OUTPUT_ARCH=arm)
elseif(targetPlatform STREQUAL "linux")
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/linux/PhysX)
    set(platformCMakeParams -DTARGET_BUILD_PLATFORM=linux -DPX_OUTPUT_ARCH=x86)
elseif(targetPlatform STREQUAL "vc17win64") # Again: this will work for any Win64
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/vc17win64/PhysX)
    set(platformCMakeParams -DTARGET_BUILD_PLATFORM=windows -DPX_OUTPUT_ARCH=x86)
endif()

# Also make sure the packman-downloaded GPU driver is found as a binary
list(APPEND platformCMakeParams -DPHYSX_PHYSXGPU_PATH=${PM_PhysXGpu_PATH}/bin)

# Anyway the above only works for clang, see
# source/compiler/cmake/linux/CMakeLists.txt:164
# to avoid problems, we copy _immediately_ the extra binaries
if(targetPlatform STREQUAL "linuxAarch64")
    file(COPY "$ENV{PM_PhysXGpu_PATH}/bin/linux.aarch64/checked/libPhysXGpu_64.so" DESTINATION "${SOURCE_PATH}/physx/bin/linux.aarch64/debug")
    file(COPY "$ENV{PM_PhysXGpu_PATH}/bin/linux.aarch64/release/libPhysXGpu_64.so" DESTINATION "${SOURCE_PATH}/physx/bin/linux.aarch64/release")
elseif(targetPlatform STREQUAL "linux")
    file(COPY "$ENV{PM_PhysXGpu_PATH}/bin/linux.clang/checked/libPhysXGpu_64.so" DESTINATION "${SOURCE_PATH}/physx/bin/linux.clang/debug")
    file(COPY "$ENV{PM_PhysXGpu_PATH}/bin/linux.clang/release/libPhysXGpu_64.so" DESTINATION "${SOURCE_PATH}/physx/bin/linux.clang/release")
elseif(targetPlatform STREQUAL "vc17win64")
    file(COPY "$ENV{PM_PhysXGpu_PATH}/bin/win.x86_64.vc141.mt/checked/PhysXGpu_64.dll" DESTINATION "${SOURCE_PATH}/physx/bin/vc17win64/debug")
    file(COPY "$ENV{PM_PhysXGpu_PATH}/bin/win.x86_64.vc141.mt/release/PhysXGpu_64.dll" DESTINATION "${SOURCE_PATH}/physx/bin/vc17win64/release")
endif()

set(cmakeParams ${platformCMakeParams} ${common_params} ${cmakeParams})

# Finally invoke cmake to configure the PhysX project
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/physx/compiler/public"
    GENERATOR "${generator}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        ${PLATFORM_OPTIONS}
        -DPHYSX_ROOT_DIR=${PHYSX_ROOT_DIR}
        ${cmakeParams}
    OPTIONS_RELEASE
        ${PLATFORM_OPTIONS_RELEASE}
    OPTIONS_DEBUG
        ${PLATFORM_OPTIONS_DEBUG}
    DISABLE_PARALLEL_CONFIGURE
    MAYBE_UNUSED_VARIABLES
        PX_OUTPUT_ARCH
        PHYSX_PHYSXGPU_PATH
)

# Compile and install in vcpkg's final installation directories all of the include headers and binaries for debug/release
vcpkg_cmake_install()

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
    _copy_up("bin/*/release" "${_fpa_DIRECTORY}") # could be physx/bin/linux.clang/release or physx/bin/win.x86_64.vc142.mt/release
    _copy_up("bin/*/debug" "debug/${_fpa_DIRECTORY}")
endfunction()

# Extract artifacts in the right vcpkg destinations

# Create output directories
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Packman also downloads the Gpu driver shared library, so we'll place it in bin and debug/bin
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
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
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/debug")
set(GPULIBNAMES "")
if(targetPlatform STREQUAL "linuxAarch64" OR targetPlatform STREQUAL "linux")
    list(APPEND GPULIBNAMES "libPhysXGpu_64.so" "libPhysXDevice64.so")
elseif(targetPlatform STREQUAL "vc17win64") # Again: this will work for any Win64
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

# Put it in 'tools', it's an optional component
_copy_single_files_from_dir_to_destdir("${GPULIBNAMES}" "${SOURCE_PATH}/physx/bin/*/release/*" "${CURRENT_PACKAGES_DIR}/tools")
_copy_single_files_from_dir_to_destdir("${GPULIBNAMES}" "${SOURCE_PATH}/physx/bin/*/debug/*" "${CURRENT_PACKAGES_DIR}/tools/debug")

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
configure_file("${CMAKE_CURRENT_LIST_DIR}/omniverse-physx-sdk-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/unofficial-omniverse-physx-sdk-config.cmake" @ONLY)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share")
file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/")
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-omniverse-physx-sdk
                         CONFIG_PATH share/omniverse-physx-sdk)

# Remove fixup wrong directories
file(REMOVE_RECURSE
     "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(targetPlatform STREQUAL "vc17win64")
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
