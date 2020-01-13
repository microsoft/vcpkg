include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/usbmuxd
    REF v1.2.76
    SHA512 b1bb479bf4ba0a71d7b70f55db4d01b68e024fe559265947e096d85cd736e4cc23c9ddbe07360641b63a5e1276c243e7fe2aa557323d1f5d22058c9a45de4f1a
    HEAD_REF master-msvc
    PATCHES
        fix-dependence-pthreads.patch
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH usbmuxd.vcxproj
    LICENSE_SUBPATH COPYING.GPLv2
    USE_VCPKG_INTEGRATION
)

# No headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
