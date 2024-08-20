vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/ifc
    REF 0.43.1
    SHA512 c7ce8570d776f875c1a1fed929734ebc73b2cf25106e2a5e80625269f4f91d8106d19da34525cc4d7a694d750788d124e8e1ef082c54a13c9b34fe3da7f9e82d
    HEAD_REF main
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
