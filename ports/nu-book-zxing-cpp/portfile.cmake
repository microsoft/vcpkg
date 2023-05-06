vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    STACK_PROTECTOR_FIX_PATCH
    URLS https://github.com/zxing-cpp/zxing-cpp/commit/accced21bae23320aad47b295de1085ab4e561b5.patch
    FILENAME accced21bae23320aad47b295de1085ab4e561b5.patch
    SHA512 c787f7cd313d80fcaa39c171a59021453a98936a66b842b3d83389104c8398417eed42151b8f5649e339e83b7261e9caa3423d9fa7b47e1fd00c933d8b11447c
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zxing-cpp/zxing-cpp
    REF v2.0.0
    SHA512 fa22164f834a42194eafd0d3e9c09d953233c69843ac6e79c8d6513314be28d8082382b436c379368e687e0eed05cb5e566d2893ec6eb29233a36643904ae083
    HEAD_REF master
    PATCHES
        "${STACK_PROTECTOR_FIX_PATCH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_BLACKBOX_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/ZXing
    PACKAGE_NAME ZXing
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/nu-book-zxing-cpp" RENAME copyright)
