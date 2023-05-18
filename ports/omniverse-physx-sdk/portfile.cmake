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

# Allows for
# vcpkg_cmake_get_vars(cmake_vars_file)
# include("${cmake_vars_file}")

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
        -DNV_USE_STATIC_WINCRT=${VCPKG_BUILD_STATIC_LIBS}
        -DNV_USE_DEBUG_WINCRT=${VCPKG_LINK_CRT_STATICALLY}
        -DPX_FLOAT_POINT_PRECISE_MATH=OFF
    )
    # It would have been more correct to specify "win64" here, but we specify this so that packman can download
    # the right dependencies on windows (see the "platforms" field in the dependencies.xml), that will also later
    # set up the correct PM_xxx environment variables that we can pass to the cmake generation invocation to find
    # whatever the PhysX project needs. Note that vc17(2022) is not required: the latest repo is guaranteed to work
    # with vc15, vc16 and vc17 on x64 Windows. The binaries for these platforms downloaded by packman should be the same.
    set(targetPlatform "vc17win64")
else()
    message(FATAL_ERROR "Unsupported platform/architecture combination")
endif()
#message(WARNING "JUST SET PLATFORM_OPTIONS")
# The following mimicks generate_projects.sh

set(PHYSX_ROOT_DIR "${SOURCE_PATH}/physx")
set(PACKMAN_CMD "${PHYSX_ROOT_DIR}/buildtools/packman/packman")

# Check if packman command exists
if(NOT EXISTS ${PACKMAN_CMD})
    if(VCPKG_TARGET_IS_LINUX)
        set(PACKMAN_CMD "${PACKMAN_CMD}.sh")
    elseif(VCPKG_TARGET_IS_WINDOWS)
        set(PACKMAN_CMD "${PACKMAN_CMD}.bat")
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
        set(PACKMAN_CMD "${PACKMAN_CMD}.cmd")
endif()

message(WARNING "NOW PULLING DEPS WITH PACKMAN!!! ${PACKMAN_CMD} pull ${PHYSX_ROOT_DIR}/dependencies.xml --platform ${targetPlatform} ")
# Pull the dependencies using packman
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

# Parsing the new env variables
string(REPLACE "\n" ";" output_envs ${output_envs})
foreach(env ${output_envs})
    if(env MATCHES "^([^=]+)=(.*)$")
        set(ENV{${CMAKE_MATCH_1}} "${CMAKE_MATCH_2}")
        # message(WARNING "HERE IS A NEW ENV VAR: ${CMAKE_MATCH_1} ${CMAKE_MATCH_2}")
    endif()
endforeach()

# # Now initialize packman before launching cmake (this finds environment variables, cmake module paths, etc.)
# execute_process(
#     COMMAND bash -c "${PACKMAN_CMD} init"
#     OUTPUT_VARIABLE packman_env
# )

# if(NOT ${result} EQUAL 0)
#     message(FATAL_ERROR "Error '${packman_env}' occurred while packman init")
# endif()
# message(WARNING "JUST EXECUTED PACKMAN INIT, NOW PARSING ENV VARS")

# message(FATAL_ERROR "HERE IS OUTPUT: ${packman_env}")

# # Parse the output of the `env` command to get the environment variables and 'inject' it into our envblock
# string(REPLACE "\n" ";" packman_env ${packman_env})
# foreach(env ${packman_env})
#     if(env MATCHES "^([^=]+)=(.*)$")
#         set(ENV{${CMAKE_MATCH_1}} "${CMAKE_MATCH_2}")
#         # message(WARNING "----  HERE IS A NEW ENV VAR: ${CMAKE_MATCH_1} $ENV{${CMAKE_MATCH_1}} ")
#     endif()
# endforeach()

#message(WARNING "READY TO CMAKE CONFIGURE!!! do we have PM_CMakeModules_PATH? -> $ENV{PM_CMakeModules_PATH}")

if(NOT EXISTS $ENV{PM_CMakeModules_PATH})
    message(FATAL_ERROR "CMake modules path was not found (packman dependency pull failure?)")
endif()



# now that we have all the environment that we need, execute the PhysX cmake for all the needed presets







# First generate ALL cmake parameters according to our distribution

# Set common parameters
set(common_params -DCMAKE_PREFIX_PATH=${PM_PATHS} -DPHYSX_ROOT_DIR=${PHYSX_ROOT_DIR} -DPX_OUTPUT_LIB_DIR=${PHYSX_ROOT_DIR} -DPX_OUTPUT_BIN_DIR=${PHYSX_ROOT_DIR})

if(DEFINED ENV{GENERATE_SOURCE_DISTRO} AND "$ENV{GENERATE_SOURCE_DISTRO}" STREQUAL "1")
    list(APPEND common_params -DPX_GENERATE_SOURCE_DISTRO=1)
endif()

# Set platform and compiler specific parameters
set(targetPlatform ${targetPlatform})
set(compiler ${CMAKE_CXX_COMPILER})
#message(WARNING "targetPlatform set to ${targetPlatform} and compiler set to ${compiler}")

if(targetPlatform STREQUAL "linuxAarch64")
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/linux-aarch64/PhysX)
    set(platformCMakeParams "-G Unix Makefiles" -DTARGET_BUILD_PLATFORM=linux -DPX_OUTPUT_ARCH=arm -DCMAKE_TOOLCHAIN_FILE=${PM_CMakeModules_PATH}/linux/LinuxAarch64.cmake)
    set(generator "Unix Makefiles")
elseif(targetPlatform STREQUAL "linux")
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/linux/PhysX)
    set(platformCMakeParams "-G Unix Makefiles" -DTARGET_BUILD_PLATFORM=linux -DPX_OUTPUT_ARCH=x86)
    if(compiler STREQUAL "clang")
        list(APPEND platformCMakeParams -DCMAKE_C_COMPILER=${PM_clang_PATH}/bin/clang -DCMAKE_CXX_COMPILER=${PM_clang_PATH}/bin/clang++)
    endif()
    set(generator "Unix Makefiles")
elseif(targetPlatform STREQUAL "vc17win64")
    set(cmakeParams -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/vc17win64/PhysX)
    set(platformCMakeParams -DTARGET_BUILD_PLATFORM=windows -DPX_OUTPUT_ARCH=x86)
endif()

# Combine all parameters
set(cmakeParams ${platformCMakeParams} ${common_params} ${cmakeParams})
# message(WARNING "ALL GENERATED CMake Parameters: ${cmakeParams}")
# message(WARNING "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")

# message(FATAL_ERROR "here are the options: ${PLATFORM_OPTIONS}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/physx/compiler/public"
    GENERATOR "${generator}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        ${PLATFORM_OPTIONS}
        -DPHYSX_ROOT_DIR=${PHYSX_ROOT_DIR}
        ${cmakeParams}
    DISABLE_PARALLEL_CONFIGURE
    MAYBE_UNUSED_VARIABLES
        PX_OUTPUT_ARCH
)

# Release and debug directories for artifacts. These will change according to the platform.
# set(COMPILER_RELEASE_DIRECTORY "linux-release")
# set(COMPILER_DEBUG_DIRECTORY "linux-debug")
# vcpkg_execute_build_process(
#     COMMAND /usr/bin/make V=1 -j 33 -f Makefile all
#     WORKING_DIRECTORY "${SOURCE_PATH}/physx/compiler/${COMPILER_RELEASE_DIRECTORY}"
#     LOGNAME "build-linux-${VCPKG_TARGET_ARCHITECTURE}-release"
# )

# Compile and install in vcpkg's final installation directories all of the include headers and binaries for debug/release
vcpkg_cmake_install()

# vcpkg_cmake_config_fixup()
# vcpkg_copy_pdbs()


# message(FATAL_ERROR "ALL RIGHT WE GOT TO THE ENDDDDDDDDDDDDDDDDDDDDDDD")

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

# # Release and debug directories for artifacts. These will change according to the platform.
# set(COMPILER_RELEASE_DIRECTORY "linux-release")
# set(COMPILER_DEBUG_DIRECTORY "linux-debug")

# # Generate projects and download dependencies via packman - the official NVIDIA 3rd party package repository
# message("Executing pre-build script 'generate_projects' for PhysX repo and target platform...")
# set(ENV{PM_PACKAGES_ROOT} ${SOURCE_PATH}/packman-root) # set the folder where we'll download all necessary deps via packman

# if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_FREEBSD)

#     if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
#         execute_process(COMMAND ${CMAKE_COMMAND} -E env CC=${CLANG} CXX=${CLANGXX} ./generate_projects.sh linux-aarch64
#             WORKING_DIRECTORY ${SOURCE_PATH}/physx
#             RESULT_VARIABLE CMD_ERROR)

#         set(COMPILER_RELEASE_DIRECTORY "linux-aarch64-release")
#         set(COMPILER_DEBUG_DIRECTORY "linux-aarch64-debug")
#     elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
#         execute_process(COMMAND ${CMAKE_COMMAND} -E env CC=${CLANG} CXX=${CLANGXX} ./generate_projects.sh linux
#             WORKING_DIRECTORY ${SOURCE_PATH}/physx
#             RESULT_VARIABLE CMD_ERROR)

#         set(COMPILER_RELEASE_DIRECTORY "linux-release")
#         set(COMPILER_DEBUG_DIRECTORY "linux-debug")
#     else()
#         message(FATAL_ERROR "Unhandled or not yet supported Linux architecture: ${VCPKG_TARGET_ARCHITECTURE}")
#     endif()

#     if (CMD_ERROR)
#         message(FATAL_ERROR "Failed to generate physx projects (Error: ${CMD_ERROR})")
#     endif ()

#     if(NOT EXISTS "${SOURCE_PATH}/physx/compiler/${COMPILER_RELEASE_DIRECTORY}/Makefile")
#         message(FATAL_ERROR "missing Makefile - build project was not generated correctly")
#     endif()

# elseif(VCPKG_TARGET_IS_WINDOWS)

#     if (VCPKG_CRT_LINKAGE STREQUAL static)
#         set(CL_FLAGS_REL "/MT")
#         set(CL_FLAGS_DBG "/MTd")
#     else()
#         set(CL_FLAGS_REL "/MD")
#         set(CL_FLAGS_DBG "/MDd")
#     endif()

#     if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
#         execute_process(COMMAND generate_projects.bat vc17win64
#             WORKING_DIRECTORY ${SOURCE_PATH}/physx
#             RESULT_VARIABLE CMD_ERROR)

#         set(COMPILER_RELEASE_DIRECTORY "vc17win64")
#         set(COMPILER_DEBUG_DIRECTORY "vc17win64")
#     else()
#         message(FATAL_ERROR "Unhandled or not yet supported Windows architecture: ${VCPKG_TARGET_ARCHITECTURE}")
#     endif()

#     if (CMD_ERROR)
#         message(FATAL_ERROR "Failed to generate physx projects (Error: ${CMD_ERROR})")
#     endif ()

#     if(NOT EXISTS "${SOURCE_PATH}/physx/compiler/${COMPILER_RELEASE_DIRECTORY}/PhysXSDK.sln")
#         message(FATAL_ERROR "missing source sln - build project was not generated correctly")
#     endif()

# else()
#     message(FATAL_ERROR "Unhandled or not yet supported target platform: ${VCPKG_CMAKE_SYSTEM_NAME}")
# endif()

# # Build release and debug versions
# if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_FREEBSD)

#     message("Now building release Makefile.. please wait..")
#     vcpkg_execute_build_process(
#         COMMAND /usr/bin/make V=1 -j 33 -f Makefile all
#         WORKING_DIRECTORY "${SOURCE_PATH}/physx/compiler/${COMPILER_RELEASE_DIRECTORY}"
#         LOGNAME "build-linux-${VCPKG_TARGET_ARCHITECTURE}-release"
#     )

#     message("Now building debug Makefile.. please wait..")
#     vcpkg_execute_build_process(
#         COMMAND /usr/bin/make V=1 -j 33 -f Makefile all
#         WORKING_DIRECTORY "${SOURCE_PATH}/physx/compiler/${COMPILER_DEBUG_DIRECTORY}"
#         LOGNAME "build-linux-${VCPKG_TARGET_ARCHITECTURE}-debug"
#     )
# elseif(VCPKG_TARGET_IS_WINDOWS)

#     if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
#         set(PLATFORM Win32)
#     elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
#         set(PLATFORM x64)
#     endif()

#     message("Now building ${PLATFORM} solution.. please wait..")
#     vcpkg_build_msbuild(
#         USE_VCPKG_INTEGRATION
#         PROJECT_PATH "${SOURCE_PATH}/physx/compiler/${COMPILER_RELEASE_DIRECTORY}/PhysXSDK.sln"
#         RELEASE_CONFIGURATION release
#         DEBUG_CONFIGURATION debug
#         PLATFORM ${PLATFORM}
#     )
# endif()

# message("[PHYSX BUILD COMPLETED] Extracting build artifacts to vcpkg installation locations..")

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
