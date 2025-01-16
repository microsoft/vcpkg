vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO UPC-ViRVIG/SdfLib
    REF c32eb7b133f8c05fee5605499b7f5bd36039dd08
    SHA512 86c4aeb66da3f59c4110abd96ac659aadddb8f67eacb0c7a5557e3741aeb56c8f5ef464c0d7fbe5853c86b523198dd2876e87473e3903ba00e03e489684ae06f
    PATCHES
        add_export.patch
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
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-sdflib CONFIG_PATH share/unofficial-sdflib)

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-sdflib/unofficial-SdfLibConfig.cmake" SDFLIB_CONFIG)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-sdflib/unofficial-SdfLibConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(glm CONFIG)
find_dependency(spdlog CONFIG)
find_dependency(cereal CONFIG)
${SDFLIB_CONFIG}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
