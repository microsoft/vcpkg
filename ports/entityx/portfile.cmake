# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/entityx-1.2.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/alecthomas/entityx/archive/1.2.0.zip"
    FILENAME "entityx-1.2.0.zip"
    SHA512 4d7009f0412fbccd7bee72713d53424c3b4fa39da62b87729dd84a710a059db27e65ca27b927285c82af09997caea125d85571824133d9b71b4e3c4eebd9917c
)
vcpkg_extract_source_archive(${ARCHIVE})

if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
    SET(SHARED_FLAG ON)
else()
    SET(SHARED_FLAG OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
    -DENTITYX_BUILD_SHARED=${SHARED_FLAG}
    -DENTITYX_BUILD_TESTING=false
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/entityx)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/entityx/COPYING ${CURRENT_PACKAGES_DIR}/share/entityx/copyright)
