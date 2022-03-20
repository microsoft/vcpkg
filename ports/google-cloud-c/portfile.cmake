vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             895465bb5606ab2bf6bced949494457d3506663f
    SHA512          e45ab652c02787a37385f490acd2d4eed9b86ade97bb65288608dd07a2bb9d993356503727d501de0020371f150b86787dfc1ba916f389ffeaaf38dfad500c07
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
