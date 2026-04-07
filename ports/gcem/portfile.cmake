vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kthohr/gcem
    REF "v${VERSION}"
    SHA512 b9bbf16cfc3488a99ab371db36879bdde1699f0890db609278c03fb161cdffef0fbd34dbbf6004d6352e9e90c49e08e6b77357c4a424b0b5e174198b42dc049c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gcem)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
