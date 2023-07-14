# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polycam/open3d
    REF 7d094c210c6f15cc2dd9f9bd0b49a88c5c630b3b
    SHA512 3a421b1c34f8e38d4802ff7fadc994c9f2b0bcbe03c51b97402661115c0a088294731fbdf7a67217f38b111c6e24e20d8c293daf03a0fbc1b5993135dfc1ae75
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
