include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_CRT ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libusbmuxd
    REF b9643ca81b8274fbb2411d3c66c4edf103f6a711 # v1.2.137
    SHA512 f4c9537349bfac2140c809be24cc573d92087a57f20d90e2abd46d0a2098e31ccd283ab776302b61470fb08d45f8dc2cfb8bd8678cba7db5b2a9b51c270a3cc8
    HEAD_REF msvc-master
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