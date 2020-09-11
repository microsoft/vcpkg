vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF 2e411dd5c8b7eb096e9eb04c46b569c775b126c6 # V1.5.2
    SHA512 c0e3f8b7b44a6da9734b44e5693d28b84e75a9d4844e30d26dbc65cbd6673fe7e7a45f329aadf5ac3d1e7ec9b939230d179ed150bcf4c3f3e96a3a96ed04fadb
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
