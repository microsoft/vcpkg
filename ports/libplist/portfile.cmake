include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libplist
    REF f279ef534ab5adeb81f063dee5e8a8fc3ca6d3ab
    SHA512 51cd9337f7112e339b64737cfb83825d99d5c6a3ead876ea59c1cf2e71ff9bc7968142f1a07983b80141411470c2df365cfb6e2dea71c25678d8eaf5867f3478
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
