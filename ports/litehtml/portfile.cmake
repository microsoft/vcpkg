vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO litehtml/litehtml
    REF v0.6
    SHA512 b774ed96e53780865e789875f571f96ebce1cd2ff0c05a06ae68a67aec44375cc282c07f77fc87131d422aceddba32bbf3e8e498c870883d8e042adb30834c39
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
