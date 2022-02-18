vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF 0a7232a4120c2daf8ddb6621ec13f313a029e495 # V1.6.2
    SHA512 6e03a5370d02accd798fc14fd256ab593b9a33b4a9b9cda8f2233eeafacf70c389c2999d1834b7ffef6968008921d28d88bcf728a322ba7943106ddc9d8e6f16
    HEAD_REF develop
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/stlab)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/cmake)

file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/stlabConfig.cmake STLAB_CONFIG)
string(REPLACE "find_dependency(Boost 1.60.0)" "if(APPLE)\nfind_dependency(Boost)\nendif()" STLAB_CONFIG ${STLAB_CONFIG})

file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/stlabConfig.cmake "${STLAB_CONFIG}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
