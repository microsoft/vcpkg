#header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO USCiLab/cereal
    REF 02eace19a99ce3cd564ca4e379753d69af08c2c8 # v1.3.0
    SHA512 de8a349803a6700478901b66a35b11d6d2ddeb43970cc0f92754e4b53d16c0e0b5f1ac6d8ef45cc982dc1cdad3e58816acdeb76e006532e9cb150c7fa20595bf
    HEAD_REF develop
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DJUST_INSTALL_CEREAL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/cereal)

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cereal)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cereal/LICENSE ${CURRENT_PACKAGES_DIR}/share/cereal/copyright)
