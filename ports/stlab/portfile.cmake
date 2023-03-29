vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF 9819ce0d5cf13d5a561dc1ca02a0a6e81f1002b3 # V1.7.1
    SHA512 f55d04c6ba93386db847cad8aa6d2d4c1ec74be96800ad54e29fc47592d7aff7ef534b1370541f0fece629741743ff0d0d5013e872f85683266d99507b875e87
    HEAD_REF develop
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/stlab)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/share/cmake")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/stlabConfig.cmake"
    "find_dependency(Boost 1.74.0)"
    "if(APPLE)\nfind_dependency(Boost)\nendif()"
)


file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
