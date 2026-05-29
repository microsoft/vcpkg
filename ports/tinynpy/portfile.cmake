vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/TinyNPY
    REF "v${VERSION}"
    SHA512 3510c1da36a6260e0e3d0a2f0c4c9c12b673574a221ea6e217e5ed2c1c14d4f2937ef00dd9bd8407e52e3961821ccf1301c74691ac562f242c9b80bc8ddd4314
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" LINK_CRT_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLINK_CRT_STATIC_LIBS=${LINK_CRT_STATIC}
        -DBUILD_DEMO=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TinyNPY)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
