vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NadmanKhan/Open-C37.118
    REF aa7fa8ddab85d50c853bc67ffe9c07503bded2e3
    SHA512 2d25766d4a76fe03fc1d08886b6c2ee5ade7b1f320fb95453e0bfa82ecf871d5f165aa322e184c9fa0b9f05552e2fd69f4fcfa0e9e6a41de9a78f87b37c7e134
    HEAD_REF master
)


vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
