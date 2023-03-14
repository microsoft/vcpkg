vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/status-code
    REF 5be338838d278e730b78c07f6306ae71f6c1959c
    SHA512 61685b7ba40fd2e8a985a8135065b335655aac7aee7778ca3317004c9730078361cfa4bd1b9ac2f9002efc707bfb6168c0275f11e0c5a6b079d42c8240528a90
    HEAD_REF master
    PATCHES
)

# Because status-code's deployed files are header-only, the debug build is not necessary
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/status-code)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Licence.txt")
