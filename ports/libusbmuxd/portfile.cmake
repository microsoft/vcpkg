include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libusbmuxd
    REF 1.0.109
    SHA512 104205ebcac96765f4bf0b42dbe5df084be4f87fc64454b4e02049fbd18caf9282d070f8949935977eda76fba68b6a909571afea58d4ad4091f02d0e6b7a08e0
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
