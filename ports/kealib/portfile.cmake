vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ubarsc/kealib
    REF "kealib-${VERSION}"
    SHA512 82399f1332ff2aeb6342732e9e5c897c813109fd18e77cfc8d866f06adf4faa7f080f1f3c0a3b777fb3a679912dacf4851b7ad09a338d6087dd1d26eb2d1689f
    HEAD_REF master
    PATCHES hdf5_include.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBKEA_WITH_GDAL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_GDAL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libkea)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
