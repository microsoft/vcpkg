if("udev" IN_LIST FEATURES)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    libudev\n\nThese can be installed on Ubuntu systems via apt-get install libudev-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/libusb-cmake
    REF v${VERSION}
    SHA512 d2be6014542e7063013b27b95c0cfa83bc57b9cae6d390d26e62ff2806a36a9ba42edc23b9052c2b06f2c49956491602761a589a84e9d64a5a0f6d9879b829de
    HEAD_REF master
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

configure_file("${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${SOURCE_PATH}/libusb/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
