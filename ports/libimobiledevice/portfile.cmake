include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libimobiledevice
    REF d6b24aae971b990d2777a88ec3a1e31b40d6152f
    SHA512 3e9e2e60cf442095b363786269e259373de0d33b9b0fa8f9ac7f43721b8b97d6c497b4ca670f37ec503bb142c9a707ab6fe01cf68ac925e8143c54c536328a57
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
