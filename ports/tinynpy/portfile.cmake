include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/TinyNPY
    REF 12d8519c1b139e536c88bcb8660605caeb1374da
    SHA512 00da528051422ccf7d5a3295b365e1f2f24a9181806c16dee181975b8d660e2edb150fe977f2abc78cb40abcbbe04c8974f40c02ad98cbc4745298ab5c9c42fa
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DBUILD_DEMO=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/tinynpy")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinynpy RENAME copyright)
