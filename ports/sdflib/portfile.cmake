vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO UPC-ViRVIG/SdfLib
    REF 109e9828710fa581616f7fdd6ed1c87d5cb11e2b
    SHA512 6908fb57de26da32de2b04c1202531d5e01f5135357e94a4a1141d9588c19d51be2d8b9a11f89b6f2c7884a46778775cc4f1156966cdcb3095578de0478792ec
    PATCHES 
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDFLIB_USE_ASSIMP=OFF
        -DSDFLIB_USE_OPENMP=OFF
        -DSDFLIB_USE_ENOKI=OFF
        -DSDFLIB_USE_SYSTEM_GLM=ON
        -DSDFLIB_USE_SYSTEM_SPDLOG=ON
        -DSDFLIB_USE_SYSTEM_CEREAL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
