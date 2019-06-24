include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF v6.0.0
    SHA512 482eb7b52961878877d1e4a4f1e1a5a867ff5b83f0df3ce47c0eb68f43eabcde720ea7ccb2eeb960dbc29fc61c888db62751984425e9b27c7498dfa4441aa801
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREPROC++=ON
        -DREPROC++_INSTALL=ON
        -DREPROC_INSTALL=ON
)

vcpkg_install_cmake()

file(GLOB REPROC_CMAKE_FILES ${CURRENT_PACKAGES_DIR}/lib/cmake/reproc++/*)
file(COPY ${REPROC_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib/cmake/reproc)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/reproc)

# Debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle License
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/reproc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/reproc/LICENSE ${CURRENT_PACKAGES_DIR}/share/reproc/copyright)
