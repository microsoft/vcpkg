include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF v1.0.0
    SHA512 f567de9d6cd8bca0b34f1f48231a59c6698730c5b63f1d733de14fecf09991de74e4b3a99cc98ae7f62dcba8b2b7831d5e617fd32ca38b296b9073bc07fb2d92
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREPROC_BUILD_CXX_WRAPPER=ON
        -DREPROC_INSTALL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/reproc)


# Debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle License
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/reproc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/reproc/LICENSE ${CURRENT_PACKAGES_DIR}/share/reproc/copyright)