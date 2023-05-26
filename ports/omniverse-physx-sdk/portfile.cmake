#
# Port for Omniverse PhysX 5 - NVIDIA Corporation
# Marco Alesiani <malesiani@nvidia.com>
# Note: this port is NOT officially supported by NVIDIA.
# This port is also not a replacement for the 'physx' port: the newest Omniverse PhysX dropped support
# for many platforms so the old one will continue to be community maintained to support all previous platforms.
#

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
        -DPX_COPY_EXTERNAL_DLL=OFF
    )
    set(targetPlatform "linux")
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(PLATFORM_OPTIONS
        -DPX_BUILDSNIPPETS=OFF
        -DPX_BUILDPVDRUNTIME=OFF
        -DPX_GENERATE_STATIC_LIBRARIES=${VCPKG_BUILD_STATIC_LIBS}
        -DPX_COPY_EXTERNAL_DLL=OFF
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

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        list(APPEND PLATFORM_OPTIONS_RELEASE -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL)
        list(APPEND PLATFORM_OPTIONS_RELEASE -DWINCRT_NDEBUG="/MD")
        list(APPEND PLATFORM_OPTIONS_DEBUG -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebugDLL)
        list(APPEND PLATFORM_OPTIONS_DEBUG -DWINCRT_DEBUG="/MDd")
    else()
        list(APPEND PLATFORM_OPTIONS_RELEASE -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded)
        # list(APPEND PLATFORM_OPTIONS_RELEASE -DWINCRT_NDEBUG="/MT")
        list(APPEND PLATFORM_OPTIONS_DEBUG -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDebug)
        list(APPEND PLATFORM_OPTIONS_DEBUG -DWINCRT_DEBUG="/MTd")
    endif()

    # Note: it would have been more correct to specify "win64" here, but we specify this so that packman can download
    # the right dependencies on windows (see the "platforms" field in the dependencies.xml), that will also later
    # set up the correct PM_xxx environment variables that we can pass to the cmake generation invocation to find
    # whatever the PhysX project needs. Note that vc17(2022) is not required: the latest repo is guaranteed to work
    # with vc15, vc16 and vc17 on x64 Windows. The binaries for these platforms downloaded by packman should be the same.
    set(targetPlatform "vc17win64")
else()
    message(FATAL_ERROR "Unsupported platform/architecture combination")
endif()


# All of the following code mimicks generate_projects.sh

set(PHYSX_ROOT_DIR "${SOURCE_PATH}/physx")
set(PACKMAN_CMD "${PHYSX_ROOT_DIR}/buildtools/packman/packman")

# Check if packman command exists

if(VCPKG_TARGET_IS_WINDOWS)
    set(PACKMAN_CMD "${PACKMAN_CMD}.cmd")
endif()

if(NOT EXISTS ${PACKMAN_CMD})
    message(FATAL_ERROR "Cannot find packman (the NVIDIA package manager to download PhysX deps) searched location: ${PACKMAN_CMD}")
endif()

# Pull the dependencies using the found packman
if(VCPKG_TARGET_IS_LINUX)
    execute_process(
        COMMAND bash -c  "source ${PACKMAN_CMD} pull ${PHYSX_ROOT_DIR}/dependencies.xml --platform ${targetPlatform}; env"
        RESULT_VARIABLE result # return code or error string
        OUTPUT_VARIABLE output_envs
        ERROR_VARIABLE error_output
        WORKING_DIRECTORY ${PHYSX_ROOT_DIR}
    )
elseif(VCPKG_TARGET_IS_WINDOWS)
    execute_process(
        COMMAND cmd /c "set PM_DISABLE_VS_WARNING=1 & ${PACKMAN_CMD} pull ${PHYSX_ROOT_DIR}/dependencies.xml --platform ${targetPlatform} & set"
        RESULT_VARIABLE result # return code or error string
        OUTPUT_VARIABLE output_envs
        ERROR_VARIABLE error_output
        WORKING_DIRECTORY ${PHYSX_ROOT_DIR}
    )
endif()

if(NOT ${result} EQUAL 0)
    message(FATAL_ERROR "Error '${result}' occurred while pulling dependencies using packman (stdout: ${output_envs}, stderr: ${error_output})")
endif()

# Packman downloads the deps and also sets environment variables with paths on where to find these:
# let's parse the stdout for environment variables and inject them into ours (hacky)
string(REPLACE "\n" ";" output_envs ${output_envs})
foreach(env ${output_envs})
    if(env MATCHES "^([^=]+)=(.*)$")
        set(ENV{${CMAKE_MATCH_1}} "${CMAKE_MATCH_2}")
    endif()
endforeach()

if(NOT EXISTS $ENV{PM_CMakeModules_PATH}) # Mandatory on every supported platform
    message(FATAL_ERROR "CMake modules path was not found (packman dependency pull failure?)")
endif()

# Now generate ALL cmake parameters according to our distribution

# Set common parameters
set(common_params -DCMAKE_PREFIX_PATH=$ENV{PM_PATHS} -DPHYSX_ROOT_DIR=${PHYSX_ROOT_DIR} -DPX_OUTPUT_LIB_DIR=${PHYSX_ROOT_DIR} -DPX_OUTPUT_BIN_DIR=${PHYSX_ROOT_DIR})

if(DEFINED ENV{GENERATE_SOURCE_DISTRO} AND "$ENV{GENERATE_SOURCE_DISTRO}" STREQUAL "1")
    list(APPEND common_params -DPX_GENERATE_SOURCE_DISTRO=1)
endif()

# Set platform and compiler specific parameters
if(targetPlatform STREQUAL "linuxAarch64")
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/linux-aarch64/PhysX)
    set(platformCMakeParams "-G Unix Makefiles" -DTARGET_BUILD_PLATFORM=linux -DPX_OUTPUT_ARCH=arm -DCMAKE_TOOLCHAIN_FILE=$ENV{PM_CMakeModules_PATH}/linux/LinuxAarch64.cmake)
    set(generator "Unix Makefiles")
elseif(targetPlatform STREQUAL "linux")
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/linux/PhysX)
    set(platformCMakeParams "-G Unix Makefiles" -DTARGET_BUILD_PLATFORM=linux -DPX_OUTPUT_ARCH=x86)
    if(compiler STREQUAL "clang")
        list(APPEND platformCMakeParams -DCMAKE_C_COMPILER=$ENV{PM_clang_PATH}/bin/clang -DCMAKE_CXX_COMPILER=$ENV{PM_clang_PATH}/bin/clang++)
    endif()
    set(generator "Unix Makefiles")
elseif(targetPlatform STREQUAL "vc17win64") # Again: this will work for any Win64
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/vc17win64/PhysX)
    set(platformCMakeParams -DTARGET_BUILD_PLATFORM=windows -DPX_OUTPUT_ARCH=x86)
endif()

# Also make sure the packman-downloaded GPU driver is found as a binary
list(APPEND platformCMakeParams -DPHYSX_PHYSXGPU_PATH=$ENV{PM_PhysXGpu_PATH}/bin)

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
        PX_COPY_EXTERNAL_DLL
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

# Install license and cmake wrapper (which will let users find_package(physx) in CMake)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
# Install the cmake config that users will use, replace -if any- only @variables@
configure_file("${CMAKE_CURRENT_LIST_DIR}/omniverse-physx-sdk-config.cmake" "${CURRENT_PACKAGES_DIR}/share/omniverse-physx-sdk/omniverse-physx-sdk-config.cmake" @ONLY)

message("[VCPKG Omniverse PhysX port execution completed]")
