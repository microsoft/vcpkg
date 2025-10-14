vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sushant-wayal/stringhash
    REF v1.1.0
    SHA512 AA87E56BA37AD0155307376C2778E327D37F7B6E26C67A83796B9294B484E790D7403EC8C444D8D1391343A68EB03D1E358EB664E4A2DB744FD172097B68DAB5
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sushant-wayal-stringhash)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)