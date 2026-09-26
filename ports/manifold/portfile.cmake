vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO elalish/manifold
    REF "v${VERSION}"
    SHA512 8a6e192a9ca26d7b90b0b960a770dcb4ca1f651526f6beea9ad490aaf05e63d9e64ab591cdbeced34a5117dd676328e5ceab5f783acb609b76f3a18a7586775d
    PATCHES
        fix-pkgconfig-cflags.patch # https://github.com/elalish/manifold/pull/1824
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMANIFOLD_TEST=OFF
        -DMANIFOLD_CROSS_SECTION=ON
        -DMANIFOLD_CBIND=ON
        -DMANIFOLD_PYBIND=OFF
        -DMANIFOLD_JSBIND=OFF
        -DMANIFOLD_STRICT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/manifold)
foreach(dir IN ITEMS lib/pkgconfig debug/lib/pkgconfig)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/${dir}/manifold.pc")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/${dir}/manifold.pc" "Requires-private:" "Requires.private:")
    endif()
endforeach()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
