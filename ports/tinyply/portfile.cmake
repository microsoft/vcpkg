vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ddiakopoulos/tinyply
    REF c9bb690dfe5e9105961e9e28120c48c9ae084bc6 # 3.0
    SHA512 4df803db4494e04a3f3bd7bc47d59a18d0c6dd8b0984b36e4ef38722590fbd441f226e284108c3971eea7733e3740f0e688ebd848bff493fc9f8c56426d1dab4
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
file(READ "${SOURCE_PATH}/README.md" readme_contents)
string(FIND "${readme_contents}" "## License" license_pos)
string(SUBSTRING "${readme_contents}" ${license_pos} -1 license_contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "${license_contents}")

vcpkg_fixup_pkgconfig()
