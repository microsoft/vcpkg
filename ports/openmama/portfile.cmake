vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(GIT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO finos/OpenMAMA
    REF OpenMAMA-${VERSION}-release
    SHA512 bf6a9343546ace80b8a72072f97aa85988a3d0d047e2a60d05de638afce89b4e4f2bcae28b8e93ca808e8c0e4a83de9035ff785f69f9b4ac4ccd2616e792fa08
    HEAD_REF next
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DOPENMAMA_DEPENDENCY_ROOT=${CURRENT_INSTALLED_DIR}"
        -DINSTALL_RUNTIME_DEPENDENCIES=OFF
        -DFLEX_EXECUTABLE=${FLEX}
        -DGIT_BIN=${GIT}
        -DOPENMAMA_VERSION=${VERSION}
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTTOOLS=OFF
)

vcpkg_cmake_install()

# Copy across license files and copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md" "${SOURCE_PATH}/LICENSE-3RD-PARTY.txt")

# Clean up LICENSE file - vcpkg doesn't expect it to be there
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE.md" "${CURRENT_PACKAGES_DIR}/debug/LICENSE.md")

# Vcpkg does not expect include files to be in the debug directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME OpenMAMA
    CONFIG_PATH lib/cmake/OpenMAMA
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake" "${CURRENT_PACKAGES_DIR}/lib/cmake")