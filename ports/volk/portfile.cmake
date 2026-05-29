# volk is not prepared to be a DLL.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/volk
    REF "vulkan-sdk-${VERSION}"
    SHA512 fd41231bcb23f61b9e9e63a5f6c9bb7f456c05a018e0338c7b7761e7e42d0de90f188cc891b8fbac834017bc8ddfdd523dbf9d2524a68065ec9c51e9f5135d42
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVOLK_INSTALL=ON
        -DVULKAN_HEADERS_INSTALL_DIR=${CURRENT_INSTALLED_DIR}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/volk)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
