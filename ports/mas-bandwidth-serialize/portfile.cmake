# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/serialize
    REF "v${VERSION}"
    SHA512 16342bd5114c3a4bfde6479d897b49aeaccba2a3f18f3738c64e52a58957eeae29e100362e36e1d852666d72ee437513e6ea5bf7196e9d9db1e06f0fc94684bf
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSERIALIZE_BUILD_TESTS=OFF
        -DSERIALIZE_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME serialize CONFIG_PATH lib/cmake/serialize)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
