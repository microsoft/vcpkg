#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO USCiLab/cereal
    REF v1.3.1
    SHA512 5beafdd95b16344d5db43a0e26fd670a770e2c2a661ae117c9593db86697ca1034e2bf004fe6dc3c2a690e8a682f60d8b6121211d898009e59361ebef33f6fc9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DJUST_INSTALL_CEREAL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cereal)

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cereal)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cereal/LICENSE ${CURRENT_PACKAGES_DIR}/share/cereal/copyright)
