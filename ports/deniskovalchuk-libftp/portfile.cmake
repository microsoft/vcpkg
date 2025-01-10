vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO deniskovalchuk/libftp
        REF "v${VERSION}"
        SHA512 c0fe6f174d0bcb200f7b3a933671f5b6ab63599ba9c7a4cadd2219866d246c0ab11bb9c9bfdfe6bf9adfebb9132c2378c7912cb7cb80489e29c05c9710e839c3
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
