include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_CRT ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libplist
    REF f279ef534ab5adeb81f063dee5e8a8fc3ca6d3ab
    SHA512 52001a46935693e3ac5f0b8c3d13d9bf51c5f34189f6f006bd697d7e965f402460060708c4fb54ed43f49a217ac442fcb8dca252fcbccd3e6a154b6c9a8c2104
    HEAD_REF msvc-master
    PATCHES dllexport.patch
)

set(ENV{_CL_} "$ENV{_CL_} /GL-")
set(ENV{_LINK_} "$ENV{_LINK_} /LTCG:OFF")

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(ENV{_LINK_} "$ENV{_LINK_} /APPCONTAINER")
endif()

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libplist.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING.lesser
    REMOVE_ROOT_INCLUDES
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()