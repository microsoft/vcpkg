vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO minio/minio-cpp
    REF v0.1.1
    SHA512 88bd07688f27ca1b1cd7cba592ffe13e08619f0a1f8aa11a37276e455e1dcf025c347452819980452d67e6e4899af11e8f7b1662dc05a87db03000e876d1155b
    HEAD_REF main
)

vcpkg_cmake_configure(
   SOURCE_PATH "${SOURCE_PATH}"
   DISABLE_PARALLEL_CONFIGURE
   OPTIONS
     -DBUILD_DOC=OFF
     -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
