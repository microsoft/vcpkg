vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Reflect
    REF "vulkan-sdk-${VERSION}"
    SHA512 b09a9c6ea4fb28bf860026e0dd7a95db30c191da29a3fb936d80f9b95d1e1ac665e3a9a8941687eb4a8d1a85447209c718d310241d41c0779aef8d33851bc7ba
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DSPIRV_REFLECT_STATIC_LIB=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_copy_tools(TOOL_NAMES spirv-reflect-pp spirv-reflect AUTO_CLEAN)
