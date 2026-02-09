vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO morcules/SwiftNet
    REF "${VERSION}"
    SHA512 086166fe976e52ae78a1b9a33db4cb5ef95efca022c9198585e7cf1c2129134050ceba8b4ef6c9234ac29535568e20e8d775f6811b772b68301c2e231b8b7987
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
        -DSANITIZER=none
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
