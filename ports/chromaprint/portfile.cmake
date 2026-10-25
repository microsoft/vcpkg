vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO acoustid/chromaprint
    REF "v${VERSION}"
    SHA512 91d47ba733641065aa9aef30fe2825354bd76c07e74e3d8ac291b04b0d3dea31a7d80256736d0d8b627d596bae72dddc2252c8ec79931599571e989de9792a8d
    HEAD_REF master
    PATCHES
        pkgconfig-dependencies.diff
        pkgconfig-cxx-linkage.diff
        static-windows-dependencies.diff
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
