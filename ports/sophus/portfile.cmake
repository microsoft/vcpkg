vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strasdat/Sophus
    REF 1.24.6
    SHA512 cbc01e92c8361937194bed320ac84a7cfd8b71ecc3a842d3d3c9796ff52a08d13aa0b4f30184c4c7ddc223da0141a80176382c8b25a328e53fa00c4627511ec3
    HEAD_REF main
    PATCHES
        0001-support-eigen3-5.patch
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
