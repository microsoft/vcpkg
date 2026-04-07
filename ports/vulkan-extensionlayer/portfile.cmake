set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-ExtensionLayer
    REF "vulkan-sdk-${VERSION}"
    SHA512 4df899af58b9dad6f5bc933af18b39f6296add738f80828b239b4cd8f516b3bcae22d52e8a2217f7d907c261f3f0f489a6cad3039d351e9dd3f9282b870dba7c
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
