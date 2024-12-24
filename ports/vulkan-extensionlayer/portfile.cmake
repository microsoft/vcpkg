set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-ExtensionLayer
    REF "vulkan-sdk-${VERSION}"
    SHA512 6d2722179f59558b49198acf6f0543e174ce207b7f2bf1ba4c16841da78c1f7690e706145b100232a2b226da9ad2faa5cf6565e6430aff5cd669df2de47dc7cb
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
