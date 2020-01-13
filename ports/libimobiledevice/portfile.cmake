include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libimobiledevice
    REF d6b24aae971b990d2777a88ec3a1e31b40d6152f
    SHA512 75e45162fecd80464846ff51c9b3e722017f738de8f6b55e9f41f5eadcd93730b12512087d427badbc0c2b54a76a66359a472ab5bc5be5fa02826db1171565d0
    HEAD_REF msvc-master
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libimobiledevice.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    REMOVE_ROOT_INCLUDES
    USE_VCPKG_INTEGRATION
)
