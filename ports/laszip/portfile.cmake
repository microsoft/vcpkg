include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LASzip/LASzip
    REF 3.4.1
    SHA512 875303d4672c61778694b8a969cc1e4239564f2fa81b35cba472f7eb28c71ca9bf052ca633dcdc8cbfb486a6c6849caed9833669fd1ba0aa5ee0065e7e2013f1
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
