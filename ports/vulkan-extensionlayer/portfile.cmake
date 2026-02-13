set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-ExtensionLayer
    REF "vulkan-sdk-${VERSION}"
    SHA512 5771c8b8ab47abd9a3235ec1434af2bfcdceb5bf7b41785f22aacaacde9e4f3661af01f8336f669403dbfb1b627097b68cc34367e3f0c802c362e6b862b054a7
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
