vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO acoustid/chromaprint
    REF "v${VERSION}"
    SHA512 ea9bf6c2542ac3648496c4a3f736b5707d98be03a4c882fb4eac00d67ea51df288b7663f31c7ae9677a02ca56db90d79619c1850a3882aaa725a260799af676b
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
