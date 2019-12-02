#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO USCiLab/cereal
    REF v1.3.0
    SHA512 2bb640a222d4efe7c624c6ec3e755fecae00ef59e91c4db462e233546c5afe73c065ba1d16d9600f7cd3cc185593109148008b0b2b870208e2f1d6984fd40c72
    HEAD_REF master
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
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)