vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraillt/bitsery
    REF "v${VERSION}"
    SHA512 59af7fc4b3647703fe228a7fd2a23e454e0fa42c849f718e5a731c34e1e427bc481d4ae6909f55682daf61a8d3ea5a1e37a6cf1538591a132b6b306acf06f872
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
