#header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO USCiLab/cereal
    REF v1.2.2
    SHA512 9567b2e19add9446b24f8afd122eea09ba6ecd1a090335cf0ab31fdc8f64c6c97daa3d9eaf0801c36a770737488e0eebf81d96d7b7a65deed30da6130f2d47eb
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
