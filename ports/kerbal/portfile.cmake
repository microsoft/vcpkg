vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO WentsingNee/Kerbal
        REF "v${VERSION}"
        SHA512 076bf118a0adeec78738ad5b47261d397705cc43b5bf7049ac1ec47716d15ba498ee6e153b257174a032990209319355b6f77a0f2a034964e5408ac325b21cce
        HEAD_REF main
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
        CONFIG_PATH "share/cmake/Kerbal"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
