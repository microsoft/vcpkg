
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/protozero
    SHA512 0b7a3acae851b06eddbe1fc040bce94292dbf9d4b0f68c520634ceb44009bef24d3d579508d655353f418e6ef491b97a52af72cb8639c558c032c8ff43b15887
    REF "v${VERSION}"
    HEAD_REF master
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
