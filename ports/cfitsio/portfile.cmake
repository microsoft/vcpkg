vcpkg_download_distfile(ARCHIVE
    URLS "http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-3.49.tar.gz"
    FILENAME "cfitsio-3.49.tar.gz"
    SHA512 9836a4af3bbbfed1ea1b4c70b9d500ac485d7c3d8131eb8a25ee6ef6662f46ba52b5161c45c709ed9a601ff0e9ec36daa5650eaaf4f2cc7d6f4bb5640f10da15
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-correct-headers-for-getcwd.patch
        0002-fix-dependency-zlib.patch
        0003-export-cmake-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-cfitsio TARGET_PATH share/unofficial-cfitsio)

file(READ ${CURRENT_PACKAGES_DIR}/share/unofficial-cfitsio/unofficial-cfitsio-config.cmake ASSIMP_CONFIG)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/unofficial-cfitsio/unofficial-cfitsio-config.cmake "
include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
${ASSIMP_CONFIG}")

# Remove duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include/unistd.h ${CURRENT_PACKAGES_DIR}/debug/share)

# cfitsio uses very common names for its headers, so they must be moved to a subdirectory
file(RENAME ${CURRENT_PACKAGES_DIR}/include ${CURRENT_PACKAGES_DIR}/cfitsio)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/cfitsio ${CURRENT_PACKAGES_DIR}/include/cfitsio)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    # move DLLs to bin directories for dynamic builds
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME  ${CURRENT_PACKAGES_DIR}/lib/cfitsio.dll ${CURRENT_PACKAGES_DIR}/bin/cfitsio.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME  ${CURRENT_PACKAGES_DIR}/debug/lib/cfitsio.dll ${CURRENT_PACKAGES_DIR}/debug/bin/cfitsio.dll)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cfitsio RENAME copyright)
