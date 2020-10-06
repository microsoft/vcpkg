set(GEOS_VERSION 3.8.1)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2"
    FILENAME "geos-${GEOS_VERSION}.tar.bz2"
    SHA512 1d8d8b3ece70eb388ea128f4135c7455899f01828223b23890ad3a2401e27104efce03987676794273a9b9d4907c0add2be381ff14b8420aaa9a858cc5941056
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
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
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DBUILD_TESTING=OFF
        ${_CMAKE_EXTRA_OPTIONS}
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/GEOS)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/geos-config)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/geos)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/geos-config ${CURRENT_PACKAGES_DIR}/share/geos/geos-config)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/geos-config)
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/geos/copyright COPYONLY)

vcpkg_copy_pdbs()
