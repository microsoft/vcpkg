vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ubarsc/kealib
    REF  4984102cf5867105a28ae754689566217309d120 #1.4.14
    SHA512 06628996757bc9cffc5af0f03468ec32246980b6f72f7f1c88a489a8a2aed70924115df0726fcbb9851e44030c6a44ee0f3137660de43af421dec1eab81cc147
    HEAD_REF master
    PATCHES hdf5_include.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBKEA_WITH_GDAL=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
