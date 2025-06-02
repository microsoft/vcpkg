vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Fidelxyz/DXCam-CPP
    HEAD_REF main
    REF "v${VERSION}"
    SHA512 cd8463a687030da020ffaa8c8438c90185f4bf41f14b50e72ba3aea695828dd12c52e249d290ad0f0fdc1e1109a8a800d9ddf954e38037ff9da90d9ab5fa01cc
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/dxcam)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
