set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-ExtensionLayer
    REF "vulkan-sdk-${VERSION}"
    SHA512 69699c0fa3e3d66c3eb3ef8206c5d530d0c46a850b182ab011f75b1a6e3fa6076b3f3ff9aee0f329416753a74e8eeff232a3c2df7fc94b6e486acd870b88c0d9
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_TARGET_IS_ANDROID)
    set(VCPKG_POLICY_SKIP_USAGE_INSTALL_CHECK enabled)
else()
    file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

file(GLOB LICENSE_FILES
     LIST_DIRECTORIES false
     "${SOURCE_PATH}/LICENSES/*")
if(EXISTS "${SOURCE_PATH}/LICENSE")
    list(APPEND LICENSE_FILES "${SOURCE_PATH}/LICENSE")
endif()
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
