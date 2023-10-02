# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmcode/libosmium
    REF "v${VERSION}"
    SHA512 72e881e221dc3e62d7459b5cd84bf65de4fc0149bed66fe0534107d0d4dc30e5d474df685b44af07e6065a690dd7b31b877b5b040b8e0b4b0b971738175c34a3
)
set(BOOST_ROOT "${CURRENT_INSTALLED_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")