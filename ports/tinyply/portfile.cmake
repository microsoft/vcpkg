vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ddiakopoulos/tinyply
    REF 40aa4a0ae9e9c203e11893f78b8bcaf8a50e65f0 # 2.3.4
    SHA512 c99bdfcfbcbb13af2e662763f15771d7d5905267fb72ad93b40aad83785e8fbb48feb2359ce2542fe838fcb22a42f8a65cebd9c22963a383638be1ef0100269a
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" TINYPLY_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSHARED_LIB=${TINYPLY_BUILD_SHARED}
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License
file(READ "${SOURCE_PATH}/readme.md" readme_contents)
string(FIND "${readme_contents}" "## License" license_pos)
string(SUBSTRING "${readme_contents}" ${license_pos} -1 license_contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "${license_contents}")

vcpkg_fixup_pkgconfig()
