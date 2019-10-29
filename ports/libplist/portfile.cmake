include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_CRT ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libplist
    REF f1b85c037693b5749a38473aa6c013ca45a663bf # v1.2.137
    SHA512 b38d6dc3f4d480d35d847afeab4c90f90edf249fe506c95a30af40acfb7ecbd978334fa5557cf1421716054db748f6d1d540f2405001b9b597cd56cfbfe2c671
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