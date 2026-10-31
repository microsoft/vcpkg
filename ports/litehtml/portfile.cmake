vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO litehtml/litehtml
    REF "v${VERSION}"
    SHA512 e561ae14711d740a966255a2d0a392864181829f8fc24891d337b8fd892368e0c34f2be617a5437b034cc42474ad770f63774d4e27640fa43f794b9d03f660fc
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
        -DLITEHTML_BUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME litehtml CONFIG_PATH lib/cmake/litehtml)


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
