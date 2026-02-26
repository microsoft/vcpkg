vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cieslarmichal/faker-cxx
    REF "v${VERSION}"
    SHA512 610933b09e5f77c0bb07f25e24a783b1d28f6c7183b24d93a54cf32275cac100248e8488b8b0768300f3b7c34fd653ba74c398e917925a20ce209e3dac97b814
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFAKER_BUILD_TESTING=OFF
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME faker-cxx
    CONFIG_PATH "lib/cmake"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/LICENSES.md")
