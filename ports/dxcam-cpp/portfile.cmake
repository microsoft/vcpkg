vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Fidelxyz/DXCam-CPP
    HEAD_REF main
    REF "v${VERSION}"
    SHA512 f12e243d2d37557d34c9041faee7bc3c82e57084c58d3588ea69dc2a662aa278611d75250a86fa51f6a4c911d0744bdfa723258c7015b28a1759a8457f12fae5
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/dxcam)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
