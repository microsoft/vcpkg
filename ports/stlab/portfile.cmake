vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF 0a7232a4120c2daf8ddb6621ec13f313a029e495 # V1.6.2
    SHA512 6e03a5370d02accd798fc14fd256ab593b9a33b4a9b9cda8f2233eeafacf70c389c2999d1834b7ffef6968008921d28d88bcf728a322ba7943106ddc9d8e6f16
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
    "find_dependency(Boost 1.60.0)"
    "if(APPLE)\nfind_dependency(Boost)\nendif()"
)


file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
