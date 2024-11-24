if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO deniskovalchuk/libftp
        REF "v${VERSION}"
        SHA512 7765c35884e1e4560e39018b15f441abac687afcb06942b0350ef21df8bf27d40283011397ce4a9e9125772bb9752180c225429b274fd6374e1a521ac2744b2e
        HEAD_REF master
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
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
