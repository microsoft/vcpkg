vcpkg_download_distfile(ADD_CSTDINT_FIX
    URLS https://github.com/microsoft/ifc/commit/48659fbaed5f971aecb1a0c8264e0cb2e9fe235f.diff?full_index=1
    FILENAME ms-ifc-sdk-cstdint-48659fbaed5f971aecb1a0c8264e0cb2e9fe235f.diff
    SHA512 56b97bf7cfcc37ddf31bc6f4eabe579197a7e4d259ac3df4dbcf8fdd2263215b7c9a3b1905a223c73f0f7f92d3e4d782f069a88cf4d114674bc56d5980634a94
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/ifc
    REF 0.43.1
    SHA512 c7ce8570d776f875c1a1fed929734ebc73b2cf25106e2a5e80625269f4f91d8106d19da34525cc4d7a694d750788d124e8e1ef082c54a13c9b34fe3da7f9e82d
    HEAD_REF main
    PATCHES
        "${ADD_CSTDINT_FIX}"
)

set(config_path share/cmake/Microsoft.IFC)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DIFC_INSTALL_CMAKEDIR:PATH=${config_path}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME Microsoft.IFC
    CONFIG_PATH "${config_path}"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
