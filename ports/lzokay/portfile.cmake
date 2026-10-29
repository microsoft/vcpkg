vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AxioDL/lzokay
    REF db2df1fcbebc2ed06c10f727f72567d40f06a2be
    SHA512 0e0c597cb74985ef2fc3329392dadf87c0ffc84287cdb2f04e6a70d2e74dcc79732de18872ff05d0906fac2d53749c3db6f2ccd32b906f5a8b81310810eae8eb
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)