vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfgitpr/cpp-kana
    REF "${VERSION}"
    SHA512 b1e992f7172f080f74612e515713c3fd74d15d25d088923b834563c6ee06155bb0b073a39a480e82cb6d87c4066b10e65d45f913e26975ece88bf1f4d24dcc2b
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CPP_KANA_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPP_KANA_BUILD_STATIC=${CPP_KANA_BUILD_STATIC}
        -DCPP_KANA_BUILD_TESTS=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
