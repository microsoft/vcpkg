vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/yojimbo
    REF "v${VERSION}"
    SHA512 206dc0fd20ca93a406744057a2a9b276e785770b5e9b27f9875ea6d17c52e36d706b27b2da6d446eecd032d380f636b8c44959190310e8c1251cac5208b565bc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DYOJIMBO_SYSTEM_DEPS=ON
        -DYOJIMBO_SYSTEM_TLSF=ON
        -DYOJIMBO_BUILD_TESTS=OFF
        -DYOJIMBO_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
