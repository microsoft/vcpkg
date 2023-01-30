vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AngusJohnson/Clipper2
    REF "Clipper2_${VERSION}"
    SHA512 b2b35cf4d03a387f43ee65ea49a30ec194d75ecf1b9b7431263c9073ee35ac63419ae3714f15220e5865e437b2bb5d9863cc01c5a3844304bb61933ae8c03c5b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/CPP"
    OPTIONS
        -DCLIPPER2_EXAMPLES=OFF
        -DCLIPPER2_TESTS=OFF
        -DCLIPPER2_UTILS=OFF
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
