vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF "${VERSION}"
    SHA512 3c58ccbcd61f8102bb5d1022685b8bd2e898ea5f065e59069ff5fe2e3416e0c8c9319603f686fe484f031f2f0e2eabc1867c37ede3f1b8cd0121ed120151b830
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARGS_BUILD_UNITTESTS=OFF
        -DARGS_BUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
