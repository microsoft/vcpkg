vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brunocodutra/metal
    REF v2.1.4
    SHA512 c1a2c1e64ae28f3de982d4c9615881b2b2881df36a485b924091ea310e532a400c8f73c8fb13a683b823784fe92a27635edbf162bb3d03d5d3c009ca3688cb72
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DMETAL_BUILD_DOC=OFF
        -DMETAL_BUILD_EXAMPLES=OFF
        -DMETAL_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Metal)

# This is a header only library
file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib"
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
