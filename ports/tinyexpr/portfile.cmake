vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO codeplea/tinyexpr
    REF v${VERSION}
    SHA512 9ba2092bbfe1b60fdb59261d8e386bc2a2a1eab97b6a8b32fe580d027ec09778306522fed02fedb3a4746fe15134a683924b2c177e86831b2c255cae21f3d9e5
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/exports.def" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
