set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO saadshams/nanojsonc
        REF "${VERSION}"
        SHA512 a434c0090926e6dd6d78f5b6d839539ed517f1d133d7078bfbdc118c43edd3e354a4a045632cb64d53af06bca34041aff972700541d4131bb45d70601311af4c
        HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DNANOJSONC_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/nanojsonc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
