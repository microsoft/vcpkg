include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libusbmuxd
    REF a4422aa65f3635d99c3b80fad18f093ef3c5f653
    SHA512 887ab95ecb75927fc5731eead98a61cd996daa70794833a05cf8d168359d95df3def94098c02f6db6e0c304f65ee772f9fe0fdc65b7f96d0bd8e53faa2ae7b17
    HEAD_REF msvc-master
    PATCHES dllexport.patch
)

set(ENV{_CL_} "$ENV{_CL_} /GL-")
set(ENV{_LINK_} "$ENV{_LINK_} /LTCG:OFF")

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libusbmuxd.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    USE_VCPKG_INTEGRATION
    ALLOW_ROOT_INCLUDES
)

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/Makefile.am")
