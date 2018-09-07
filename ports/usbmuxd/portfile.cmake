include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/usbmuxd
    REF 1.1.1.133
    SHA512 1a5f9abc239deeb15e2aab419ba9e88ef41ffa80396546fb65bc06b0f419cbabc80cdf95995caf71d5628d1537fb0329a73d923202e91ea43fcc7c32b840d047
    HEAD_REF master-msvc
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH usbmuxd.vcxproj
    LICENSE_SUBPATH COPYING.GPLv2
    USE_VCPKG_INTEGRATION
)

# No headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
