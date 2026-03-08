vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO acoustid/chromaprint
    REF "v${VERSION}"
    SHA512 c556b3e9b67affaabadadaabc0a26fbbf32f89e271cde0843057166d0b02f054cbe44a6707c6c8cc9eb70d808821295ce4ea526a293f345e0b98af035a24234b
    HEAD_REF master
    PATCHES
        pkgconfig-dependencies.diff
        pkgconfig-cxx-linkage.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/src/3rdparty")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME Chromaprint CONFIG_PATH "lib/cmake/Chromaprint")
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/chromaprint.h" "ifdef CHROMAPRINT_NODLL" "if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
