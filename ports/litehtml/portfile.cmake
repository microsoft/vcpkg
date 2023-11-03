vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO litehtml/litehtml
    REF "v${VERSION}"
    SHA512 e2df205258c4e6f48cc0d8f900fb62c2da1b18c9ca007f1e222e51a59a632eb122eb2dc6136de6641ed96b3c6c823f7f90d098f2f40f9966b0cb831b180776a4
    PATCHES 
      use-vcpkg-gumbo.patch
      fix-relative-includes.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DLITEHTML_UTF8=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME litehtml CONFIG_PATH lib/cmake/litehtml)


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
