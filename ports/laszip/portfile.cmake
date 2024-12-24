vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LASzip/LASzip
    REF ${VERSION}
    SHA512 163204a4d0bb4b4371a1a63eb8ba9477dc504d7e171ec3d75c3120ace7ab682df517b4583efd951c8c7ac1be03bde8c8c327586e36c8884cbf7e98ec1e1c27bf
    HEAD_REF master
    PATCHES
        compiler-options.diff
        format-string.diff
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
