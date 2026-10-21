set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avplayer/ucoro
    REF "v${VERSION}"
    SHA512 c3436b436ef1ebb3d47a65db9603842293bdb6451bc6fb738a63d61a63b52901e223f46625d956303566dc52dfb38ffb2c6ce20016c18b444f9cb3e2e701e613
    HEAD_REF main
    PATCHES
        cmake-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUCORO_BUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE_1_0.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
