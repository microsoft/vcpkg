vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LASzip/LASzip
    REF 1ab671e42ff1f086e29d5b7e300a5026e7b8d69b # 3.4.3
    SHA512 7ec20d6999b16e6a74a64d1dc3e9f1b1b4510acd306d30ccae34a543ca0dc52e1d1d989279fafdda321616ba1e0ceb59a093d8c61ba5a586b760efa0d00a0184
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LASZIP_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLASZIP_BUILD_STATIC=${LASZIP_BUILD_STATIC}
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/laszip" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# Remove laszip_api3 dll since it doesn't export functions properly during build.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/laszip_api3.dll")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/laszip_api3.dll")
