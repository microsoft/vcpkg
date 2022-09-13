vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sogou/srpc
    REF v0.9.7
    SHA512  768b36ab355996fea46dd92950f151150c4b2e550b3ab99174780f32a40d378c46b0e4e992801ac96e6c2640bbdcc34ef1efd9b104d3ff194fb83409f573c390
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/srpc)
vcpkg_copy_pdbs()
vcpkg_copy_tools(
    TOOL_NAMES srpc_generator
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
