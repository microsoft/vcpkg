vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NadmanKhan/Open-C37.118
    REF d724fbbce60060a7e1e9fb7be4c64117d6dd24ca
    SHA512 242b3137b7d9953475d5d7123a527a9220b0a8c16220566e20cec474ac12dd32479ab9a9076e5e71fcdc4718c12b49e718acce1fa24c9e5a45f0810476d1571c
    HEAD_REF master
)


vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
