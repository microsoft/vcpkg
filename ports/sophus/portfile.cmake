vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strasdat/Sophus
    REF 1.24.6-rc1
    SHA512 c1ba40b823cabce3fe83f528837ac111f4d746d6679fb920abd7be32de149c0937bb9a5049da156aec28a9b9fedbebae76a056de12707c01c5cb40dc9197c3e4
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_SOPHUS_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/sophus/cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
