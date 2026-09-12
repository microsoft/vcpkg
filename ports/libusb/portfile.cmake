if("udev" IN_LIST FEATURES)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    libudev\n\nThese can be installed on Ubuntu systems via apt-get install libudev-dev")
endif()

vcpkg_acquire_msys(MSYS_ROOT)
vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/libusb-cmake
    REF bea6567b63796ab27c1c33257d230284fb2d8316
    SHA512 a093b82c9cebca3dd1cd4be13e7dfe6e68a550e7bcc6649357722a7ea00a6cefa8044a62e26360c41721cdf427726b9000a93da2340a4f50119929d8d323f0fe
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLIBUSB_EXPORT_INSTALL_TARGETS=ON
        -DLIBUSB_INSTALL_TARGETS=ON
        -DLIBUSB_INSTALL_PKGCONFIG=ON
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libusb)
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/libusb/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
