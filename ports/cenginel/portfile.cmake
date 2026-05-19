vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Morgaxo/mchain
    REF "v${VERSION}"
    SHA512 bffccb72c7a1a3544035171462334ebd1d77fbe4f1ef68446d43d0e6ca3fa99c86c4dd30f241ad675bb17373a23180bfe1a9c688d5bee30ed522374956250a8d
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCENGINEL_BUILD_TESTS=OFF
        -DCENGINEL_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME cenginel CONFIG_PATH lib/cmake/cenginel)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
