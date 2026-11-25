vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
string(REPLACE "." "_" version_tag "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adah1972/libunibreak
    REF "libunibreak_${version_tag}"
    SHA512 d452bb5f2ff8db489e6020157bbcd1943bea12b5863c9e68c444fd09846ec25ca178c6a2149a8cbaee9f2b166e4ad0924cdca049b5ef6c02ce463ae49b77a9ae
    HEAD_REF master
    PATCHES
        fix_export.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DUNIBREAK_VERSION=${VERSION}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

configure_file("${CMAKE_CURRENT_LIST_DIR}/libunibreak-config.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/libunibreak-config.cmake" @ONLY)

vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENCE"
    COMMENT "The compiled Unicode data tables are licensed under Unicode-3.0. The upstream release does not include the full notice; see https://www.unicode.org/license.txt."
)
