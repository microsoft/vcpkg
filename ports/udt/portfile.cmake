vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO udt/udt
    REF "${VERSION}"
    FILENAME "udt.sdk.${VERSION}.tar.gz"
    SHA512 fc555ce1ddde2a8bd92c8adf470fd69a9a35d0a679def32b6ddbb18d67dc8b7d9dd928d772dc8598f08b350130f1e90bb4be58c46252a0a79ecc99f61eca8a92
    PATCHES
        fix_defs.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-udt)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
