vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/ifc
    REF "${VERSION}"
    SHA512 9d6361bdb1ec78480b2be36fcff8197bc2be5fcd162b0bf31705fb69f63ba016750a9c57c264354a9c844701e04805f5d165d9a2ae37e2e6fd2b82986d59ad84
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

vcpkg_copy_tools(
    TOOL_NAMES
        ifc
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/bin/"
    "${CURRENT_PACKAGES_DIR}/debug/bin/"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
