vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/idevicerestore
    REF 1.0.12
    SHA512 ba623be56c2f37853516d7d4c32e16f1ec72f33d512f18aa812ce6830af4b9e389f7af5321888dd0ddd168e282b652e379b60f90970680e213eabf489f406915
    HEAD_REF msvc-master
    PATCHES
        fix-vcxproj.patch
        fix-libgen.h-cannot-be-found.patch
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH idevicerestore.vcxproj
    LICENSE_SUBPATH COPYING
    USE_VCPKG_INTEGRATION
)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
