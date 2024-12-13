vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO deniskovalchuk/libftp
        REF "v${VERSION}"
        SHA512 017c809c19e32b0ddb3b4d7f5cc4cb5cc0f27a4c2be0640ddf115d869f9dbfa4b7cc77845193fed9058885bb38d33f0cff436c18c35e9611ca4f299afefe3b9d
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
