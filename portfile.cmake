vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF 8bec44964e6d477237d230d826b73cb54860068e # V1.6.0
    SHA512 7cc059a4bb666f05c3d33b19dd0d91737f5bcb9d93c40e1e078f080616b6afb4dcfe3c9fd0210aee15e02a5e848df445a320299bbccc1edf7d65f6155f20ba10
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
