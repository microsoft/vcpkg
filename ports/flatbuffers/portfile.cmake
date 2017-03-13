# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("Building DLLs not supported. Building static instead.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()


include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/flatbuffers-1.6.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/google/flatbuffers/archive/v1.6.0.zip"
    FILENAME "flatbuffers-1.6.0.zip"
    SHA512 c23043a54d7055f4e0a0164fdafd3f1d60292e57d62d20d30f641c9da90935d14da847f86239a19f777e68b707cfb25452da9192607a3a399ab25ce06b31c282
)
vcpkg_extract_source_archive(${ARCHIVE})

set(OPTIONS)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS -DFLATBUFFERS_BUILD_SHAREDLIB=ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DFLATBUFFERS_BUILD_TESTS=OFF
        -DFLATBUFFERS_BUILD_GRPCTEST=OFF
        ${OPTIONS}
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/flatc.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/flatc.exe ${CURRENT_PACKAGES_DIR}/tools/flatc.exe)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/flatbuffers.dll)
    make_directory(${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/flatbuffers.dll ${CURRENT_PACKAGES_DIR}/bin/flatbuffers.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/flatbuffers.dll)
    make_directory(${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/flatbuffers.dll ${CURRENT_PACKAGES_DIR}/debug/bin/flatbuffers.dll)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/flatbuffers)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/flatbuffers/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/flatbuffers/copyright)
