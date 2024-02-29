vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO conorwilliams/libfork
    REF "v${VERSION}"
    SHA512 dcd1c81833deda519da7483b1b35087856c118db7de8b780018fa251d4b6ef4f02c9d3a7e60d61607bbe0946e157e382d3023baedf9254e42f614080e4b43069
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "libfork")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
