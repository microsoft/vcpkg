vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO crossdb-org/crossdb
    REF "${VERSION}"
    SHA512 ad0d1c4eb02016d4d1eb8b8f3dbbacc800c1ac02a2fd39e832225e7d17d4f9938da4b49cd6ca226555819a17bb23cdf8c6d5945eeb612fe8e7e140eedd902d8f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_copy_tools(TOOL_NAMES xdb-cli DESTINATION "${CURRENT_PACKAGES_DIR}/tools" AUTO_CLEAN)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
