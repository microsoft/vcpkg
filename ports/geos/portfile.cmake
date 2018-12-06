include(vcpkg_common_functions)

set(GEOS_VERSION 3.6.3)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2"
    FILENAME "geos-${GEOS_VERSION}.tar.bz2"
    SHA512 f88adcf363433e247a51fb1a2c0b53f39b71aba8a6c01dd08aa416c2e980fe274a195e6edcb5bb5ff8ea81b889da14a1a8fb2849e04669aeba3b6d55754dc96a
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GEOS_VERSION}
    PATCHES geos_c-static-support.patch
)

# NOTE: GEOS provides CMake as optional build configuration, it might not be actively
# maintained, so CMake build issues may happen between releases.

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DGEOS_ENABLE_TESTS=False
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/geos-config)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/geos)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/geos-config ${CURRENT_PACKAGES_DIR}/share/geos/geos-config)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/geos-config)
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/geos/copyright COPYONLY)

vcpkg_copy_pdbs()
