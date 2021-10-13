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
        pc-file-libs-private.patch
        pc-file-for-msvc.patch
        make-geos-config-relocatable.patch
        fix-static-deps.patch
)

# NOTE: GEOS provides CMake as optional build configuration, it might not be actively
# maintained, so CMake build issues may happen between releases.

if(VCPKG_TARGET_IS_MINGW)
    set(_CMAKE_EXTRA_OPTIONS "-DDISABLE_GEOS_INLINE=ON")
else()
    set(_CMAKE_EXTRA_OPTIONS "")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARKS=OFF
        ${_CMAKE_EXTRA_OPTIONS}
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d # Legacy decision, hard coded in depending ports
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/GEOS)
vcpkg_fixup_pkgconfig()

function(geos_add_debug_postfix config_file)
    file(READ "${config_file}" contents)
    string(REGEX REPLACE "(-lgeos(_c)?)d?([^-_d])" "\\1d\\3" fixed_contents "${contents}")
    file(WRITE "${config_file}" "${fixed_contents}")
endfunction()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/geos.pc")
    geos_add_debug_postfix("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/geos.pc")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/geos-config")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/geos-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/geos-config")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/geos-config")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/geos-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/geos-config")
    geos_add_debug_postfix("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/geos-config")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/geos/copyright" COPYONLY)

vcpkg_copy_pdbs()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
