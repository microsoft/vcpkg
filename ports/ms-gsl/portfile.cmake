#header-only library with an install target
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 0f6dbc9e2915ef5c16830f3fa3565738de2a9230
    SHA512 f72d7d9a18b8055401feb99d99f17c70c0c2015b1a2112ae13fedd27949ff7f9b30718b6afd0b5730ed5573390cb1cc987cd45b7e7fbb92f4134f11d1637ddb7
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_TEST=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH share/cmake/Microsoft.GSL
    TARGET_PATH share/Microsoft.GSL
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
