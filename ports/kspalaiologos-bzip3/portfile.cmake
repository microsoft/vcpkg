vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kspalaiologos/bzip3
    REF ${VERSION}
    SHA512 4010194b5cadf94356a9be8f9b87b287c8d098b02377ad106038f469a90812abef7ae05b5ca87896b71f0e0ad304b8971b75e45136f0d9fabf83d0cc21cf9202
    HEAD_REF master
    PATCHES
        disable-man.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        threads  BZIP3_ENABLE_PTHREAD
        tools    BZIP3_BUILD_APPS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME bzip3 CONFIG_PATH lib/cmake/bzip3)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
