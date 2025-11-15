set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-ExtensionLayer
    REF "vulkan-sdk-${VERSION}"
    SHA512 db04519c442c8204de58a121306d5e1823b5d9e5e655bd5cc0c1e29f37c4e9274865dec594fcb8617c3ed2c32715bccf1813a923c2409b6c37e73fee34abd3cb
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
