vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/mp
    REF d2dbdf89e543624be8351fd52308a9cf73374dbc
    SHA512 15d56bf0dca2e4bfb9128b8552a6aa01ed6b1431ab9c152ed51473f6fa237c31fbf3d5baa22523e3786d14fd716acb5436ed26fe89d46812ba9375e2417bc67a
    HEAD_REF main
    PATCHES fix-build-flags.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME mp CONFIG_PATH "share/cmake/mp-0.0.1")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
