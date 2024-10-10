vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO michaelrsweet/mxml
    REF fd47c7d115191c8a6bce2c781ffee41e179530f2 # 3.3.1
    SHA512 0
    HEAD_REF master
)

# Build:
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "vcnet/mxml1.vcxproj"
        TARGET Build
    )
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
    )
    vcpkg_install_make()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
