# volk is not prepared to be a DLL.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/volk
    REF "vulkan-sdk-${VERSION}"
    SHA512 5c61448c93171917c55a9fc50f102a2d52165a150eb0c3cfd31e41a32e38c673b597888b82685f3bb1e23883f7218e8ae6326f08c4c257ebddd42b0492bdf466
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
