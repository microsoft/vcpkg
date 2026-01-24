vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO UPC-ViRVIG/SdfLib
    REF 8db373ef71d65be24badf6ae10750a932bbc223b
    SHA512 1231128e66b19923f78e2e3d9b827376c79abb22fe86bb200874a2ce3c283b4d6b8a077a1ab6749cd64b6d81f71a7d2f96d1f6dcc252a3a4aefaeb2145bbacf4
    PATCHES
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
