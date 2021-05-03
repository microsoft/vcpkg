set(GEOS_VERSION 3.9.1)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2"
    FILENAME "geos-${GEOS_VERSION}.tar.bz2"
    SHA512 7ea131685cd110ec5e0cb7c214b52b75397371e75f011e1410b6770b6a48ca492a02337d86a7be35c852ef94604fe9d6f49634c79d4946df611aaa4f5cbaee28
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${GEOS_VERSION}
    PATCHES
        dont-build-docs.patch
        dont-build-astyle.patch
)

# NOTE: GEOS provides CMake as optional build configuration, it might not be actively
# maintained, so CMake build issues may happen between releases.

if(VCPKG_TARGET_IS_MINGW)
    set(_CMAKE_EXTRA_OPTIONS "-DDISABLE_GEOS_INLINE=ON")
else()
    set(_CMAKE_EXTRA_OPTIONS "")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DBUILD_TESTING=OFF
        ${_CMAKE_EXTRA_OPTIONS}
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/GEOS)

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/geos-config")
    file(READ "${CURRENT_PACKAGES_DIR}/bin/geos-config" GEOS_CONFIG)
    string(REGEX REPLACE "(\nprefix=)[^\n]*" [[\1$(CDPATH= cd -- "$(dirname -- "$0")"/../.. && pwd -P)]] GEOS_CONFIG "${GEOS_CONFIG}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/bin/geos-config" "${GEOS_CONFIG}")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/geos-config ${CURRENT_PACKAGES_DIR}/share/${PORT}/geos-config)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin/geos-config)
    file(READ "${CURRENT_PACKAGES_DIR}/debug/bin/geos-config" GEOS_CONFIG)
    string(REGEX REPLACE "(\nprefix=)[^\n]*" [[\1$(CDPATH= cd -- "$(dirname -- "$0")"/../.. && pwd -P)]] GEOS_CONFIG "${GEOS_CONFIG}")
    string(REGEX REPLACE "(-lgeos(_c)?)d?( |\n)" "\\1d\\3" GEOS_CONFIG "${GEOS_CONFIG}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/bin/geos-config" "${GEOS_CONFIG}")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/geos-config ${CURRENT_PACKAGES_DIR}/share/${PORT}/geos-config-debug)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/geos/copyright" COPYONLY)

vcpkg_copy_pdbs()
