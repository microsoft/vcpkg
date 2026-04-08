vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SAP/odbc-cpp-wrapper
    REF "v${VERSION}"
    SHA512 c36d83b0ec5a560c2e845001594f549d1cc39d721e25345cbc6525458ec1591e01e5ae49cacd01807eed86db38ed717d55d63c94d7e7179010752044855bf838
    HEAD_REF master
    PATCHES
        use-vcpkg-unixodbc.patch
)

vcpkg_list(SET options)
if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    list(APPEND options -DODBCCPP_USE_UNIXODBC=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_GTest=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
       ${options}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")