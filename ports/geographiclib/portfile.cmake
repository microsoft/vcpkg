set(GEOGRAPHICLIB_VERSION 1.50.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/geographiclib/files/distrib/GeographicLib-${GEOGRAPHICLIB_VERSION}.tar.gz"
    FILENAME "geographiclib-${GEOGRAPHICLIB_VERSION}.tar.gz"
    SHA512 1db874f30957a0edb8a1df3eee6db73cc993629e3005fe912e317a4ba908e7d7580ce483bb0054c4b46370b8edaec989609fb7e4eb6ba00c80182db43db436f1
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        remove-tools-and-fix-version.patch
        fix-usage.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(GEOGRAPHICLIB_LIB_TYPE SHARED)
else()
    set(GEOGRAPHICLIB_LIB_TYPE STATIC)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DGEOGRAPHICLIB_LIB_TYPE=${GEOGRAPHICLIB_LIB_TYPE}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/GeographicLib)
endif()
vcpkg_copy_pdbs()

file(COPY ${CURRENT_PACKAGES_DIR}/lib/pkgconfig DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)