vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(TARGET_BUILD_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sago007/PlatformFolders
    REF ${VERSION}
    SHA512 0c5221581f6cb8ce44ee0200c6a9b9ddb85f1065f0f7dc48b33b8d380483094efba8c089f3d1fc8b6cef51c4f6b70497861e77ac2309a37d1ded9317085a06ae
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPLATFORMFOLDERS_BUILD_TESTING=OFF
)

vcpkg_cmake_install()
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${TARGET_BUILD_PATH}-rel/platform_folders.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin/")
    file(INSTALL "${TARGET_BUILD_PATH}-dbg/platform_folders.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/")
endif()

if (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_MinGW)
    vcpkg_cmake_config_fixup(PACKAGE_NAME platform_folders CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME platform_folders CONFIG_PATH lib/cmake/platform_folders)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()
