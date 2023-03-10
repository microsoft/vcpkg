vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO theAeon/libleidenalg
    REF 748dfca386b997fe5a140e21b9ef0f78a6e95ee6
    SHA512 c88f0d9912981b8179d58c7084761e9123e2d7fdd4d971c348f1c0ec066b77914cf5592e0cdff21e371262fd28bbb50f2a09b06404adf2a1468f2f20c228a42f
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
