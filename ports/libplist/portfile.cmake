include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libplist
    REF 2.0.1.197
    SHA512 55e1817c61d608b11646eb9c28c445f9ee801c7beb2121bd810235561117262adb73dbecb23b9ef5b0c54b0fc8089e0a46acc0e8f4845329a50a663ab004052c
    HEAD_REF msvc-master
    PATCHES dllexport.patch
)

set(ENV{_CL_} "$ENV{_CL_} /GL-")
set(ENV{_LINK_} "$ENV{_LINK_} /LTCG:OFF")

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libplist.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING.lesser
    REMOVE_ROOT_INCLUDES
)
