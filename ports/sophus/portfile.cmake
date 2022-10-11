vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strasdat/Sophus
    REF 49a7e1286910019f74fb4f0bb3e213c909f8e1b7
    SHA512 d415aff722a6aff91b4f787804496fb534ad44ada8ce6f03adcf9e23dbf2e080af8d3d973b8cd2b5a024da856b76e4f5e45e60bf7c2a0500f9a77aa7b4e938e0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_SOPHUS_TESTS=OFF
        -DBUILD_SOPHUS_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/sophus/cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
