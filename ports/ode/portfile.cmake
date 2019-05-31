# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_VERSION 0.15.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ode-${SOURCE_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/odedevs/ode/downloads/ode-${SOURCE_VERSION}.tar.gz"
    FILENAME "ode-${SOURCE_VERSION}.tar.gz"
    SHA512 e30623374c8f7c45359d6d837313698ca28da7b5a2d26c7171da16ccd6f95c4a49aad731c432db6ca2911886948a2e7ea93a96ade5a1639b945a825d8ac87249
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-add-static-runtime-option.patch"
)


if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is currently not supported.")
elseif (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(premake_PLATFORM "x32")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(premake_PLATFORM ${TRIPLET_SYSTEM_ARCH})
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

# The build system of ode outputs its artifacts in this subdirectory
# of the source directory
set(DEBUG_ARTIFACTS_PATH ${SOURCE_PATH}/lib/Debug)
set(RELEASE_ARTIFACTS_PATH ${SOURCE_PATH}/lib/Release)

# To avoid contamination from previous build, we clean the directory
file(REMOVE_RECURSE ${DEBUG_ARTIFACTS_PATH} ${RELEASE_ARTIFACTS_PATH})

# Configure the project using the embedded premake4
message(STATUS "Configuring ${TARGET_TRIPLET}")
# Consistently with the debian package we only ship ODE built with double precision
set(premake_OPTIONS "--only-double")
# TODO: use vcpkg's libccd
list(APPEND premake_OPTIONS --with-libccd)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND premake_OPTIONS --only-shared)
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND premake_OPTIONS --only-static)
endif()
if(DEFINED VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL static)
    list(APPEND premake_OPTIONS --static-runtime)
endif()
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/build/premake4.exe
        --to=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}
        --platform=${premake_PLATFORM}
        ${premake_OPTIONS}
        vs2010
    WORKING_DIRECTORY ${SOURCE_PATH}/build/
    LOGNAME config-${TARGET_TRIPLET}
)
message(STATUS "Configuring ${TARGET_TRIPLET} done")

# Build the project using the generated msbuild solutions
vcpkg_build_msbuild(PROJECT_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/ode.sln
                    PLATFORM ${MSBUILD_PLATFORM}
                    WORKING_DIRECTORY ${SOURCE_PATH}/build)

# Install headers
file(GLOB HEADER_FILES ${SOURCE_PATH}/include/ode/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ode)

# Install libraries
file(GLOB LIB_DEBUG_FILES ${DEBUG_ARTIFACTS_PATH}/*.lib ${DEBUG_ARTIFACTS_PATH}/*.exp)
file(INSTALL ${LIB_DEBUG_FILES}
     DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

if (DEFINED VCPKG_LIBRARY_LINKAGE AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
   file(GLOB BIN_DEBUG_FILES ${DEBUG_ARTIFACTS_PATH}/*.dll ${DEBUG_ARTIFACTS_PATH}/*.pdb)
   file(INSTALL ${BIN_DEBUG_FILES}
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif ()

file(GLOB LIB_RELEASE_FILES ${RELEASE_ARTIFACTS_PATH}/*.lib ${RELEASE_ARTIFACTS_PATH}/*.exp)
file(INSTALL ${LIB_RELEASE_FILES}
     DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

if (DEFINED VCPKG_LIBRARY_LINKAGE AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(GLOB BIN_RELEASE_FILES ${RELEASE_ARTIFACTS_PATH}/*.dll ${RELEASE_ARTIFACTS_PATH}/*.pdb)
    file(INSTALL ${BIN_RELEASE_FILES}
         DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif ()



# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE-BSD.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/ode)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ode/LICENSE-BSD.TXT ${CURRENT_PACKAGES_DIR}/share/ode/copyright)
