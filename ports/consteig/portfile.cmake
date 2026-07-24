set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MitchellThompkins/consteig
    REF "${VERSION}"
    SHA512 8cb4d324eb11b1dd873e60ca47ddcc082fdfffa08723387fc47abd93f7eb14cb27eb148d66be7a59588f4ee55c4aac585752ffcb9c0f95fac6f42cb8a11e1a92
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCONSTEIG_VERSION=${VERSION}"
        -DCONSTEIG_BUILD_TESTS=OFF
        -DCONSTEIG_BUILD_EXAMPLES=OFF
        -DCONSTEIG_BUILD_PROFILING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/consteig)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
