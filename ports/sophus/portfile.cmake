vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strasdat/Sophus
    REF 1.22.10
    SHA512 0b212a015d487b3a39a9c4beb4280ebd659782f527ec863f429b5aa57462d53c41976c9285894855b380baa97d5fda35b46dfd09aa31653fb35b51039816ac78
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
