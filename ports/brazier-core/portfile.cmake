vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier
    REF "v${VERSION}"
    SHA512 254b10e917ff6dcbfbd030f1ec712a6d711f0d83b314c1c09311dc5a2a199f19e172c07e5c95d173837ae44e8409412c01fef4dcce393eb6b799c6ee6b33d20e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/brazier"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_APP=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/COPYING"
)
