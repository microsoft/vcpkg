vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfgitpr/cpp-kana
    REF "${VERSION}"
    SHA512 06e5bcc7ddc2a13ae691a3fd6faf187deda2f553647306d9ab7f12bcb229ef80aeced4d236b2104f7223642527d15f6078b5dc971f3e481a8c3f7474764a1bcd
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
