include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libusbmuxd
    REF a4422aa65f3635d99c3b80fad18f093ef3c5f653
    SHA512 9446bbcd6b901e6183f6e86d7fe7301c01182ae5b9330182fbca529bb1db54250cd6012256a420d457a7243388811c94bb2ecf5a0747238714d00b3850e60e8e
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
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()