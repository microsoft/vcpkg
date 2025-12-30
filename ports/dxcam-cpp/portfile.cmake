vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Fidelxyz/DXCam-CPP
    HEAD_REF main
    REF "v${VERSION}"
    SHA512 1e5f8e0d1c92197a87280c901a81fb9b9f21cc754113de72f590525dcec3879536431cb15acc79190e9e39a3d429bb06badf9f5cf24a4eed8af9eea797bbcd52
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/dxcam)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
