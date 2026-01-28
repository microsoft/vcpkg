vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LASzip/LASzip
    REF ${VERSION}
    SHA512 6cdc38249ace8191dae454817fe5f5a3cd22b24c7065daa0e4a3eaaca4d698540c56affa06e15de88aea2912a82033d1dc93f5d3904190a896edf1204af865f5
    HEAD_REF master
    PATCHES
        compiler-options.diff
        include-cstdint.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LASZIP_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLASZIP_BUILD_STATIC=${LASZIP_BUILD_STATIC}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# Remove laszip_api3 dll since it doesn't export functions properly during build.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/laszip_api3.dll")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/laszip_api3.dll")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.txt")
