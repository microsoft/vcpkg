include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LASzip/LASzip
    REF 3.2.2
    SHA512 c4dac1fd525b1889fa8cc77f168bc3c83053619402ec13ac0ae58665cfd4440b9135ce30c4ade925a0ac9db7e3f717344859e511b2207841c84dc2453c6cf7f7
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LASZIP_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLASZIP_BUILD_STATIC=${LASZIP_BUILD_STATIC}
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/laszip RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Remove laszip_api3 dll since it doesn't export functions properly during build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/laszip_api3.dll)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/laszip_api3.dll)
