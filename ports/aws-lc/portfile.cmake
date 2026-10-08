vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/aws-lc
    REF "v5.11.0"
    SHA512 195eb6962c31e6f69db0f361ca65b9475077c05ac05b1f9a0b473c9e6df084783a13ccce4aad5981d8d7a3255377581545a354231544c471bc17b796bdb84770
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_TOOL=OFF
        -DDISABLE_PERL=ON
        -DDISABLE_GO=ON
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/AWSLC)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
