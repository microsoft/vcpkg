vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(TARGET_BUILD_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sago007/PlatformFolders
    REF 4.2.0
    SHA512 50a9acd37b8b491e8938190b3b7ed1af2d3cc70bb6e59708dc1928269d5e4b8d52ec02f9330f3d9439099029ac61d193dadbca198e1d561432e02e488e103f7c
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
    vcpkg_cmake_config_fixup(PACKAGE_NAME platform_folders CONFIG_PATH lib/cmake)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()
