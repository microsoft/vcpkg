vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO deniskovalchuk/libftp
        REF "v${VERSION}"
        SHA512 34e3abdbe5fbc9e422f58e50f5a6f276ffbd3abf8d2c419c294e4e7ea36fb42dbdf15dff3c3a3d9e1c7ca7164e7f6fdc77f12f722c6002294a77e46fa61e3122
        HEAD_REF master
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        DISABLE_PARALLEL_CONFIGURE # generating export header in source dir
        OPTIONS
            -DLIBFTP_BUILD_TEST=OFF
            -DLIBFTP_BUILD_EXAMPLE=OFF
            -DLIBFTP_BUILD_CMDLINE_CLIENT=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME ftp
                         CONFIG_PATH "share/cmake/ftp")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
