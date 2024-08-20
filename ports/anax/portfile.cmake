vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO miguelmartin75/anax
    REF v2.1.0
    SHA512 b573733b5f9634bf8cfc5b0715074f9a8ee29ecb48dc981d9371254a1f6ff8afbbb9ba6aa0877d53e518e5486ecc398a6d331fb9b5dbfd17d8707679216e11a3
    HEAD_REF master
    PATCHES 
        Add-bin-output.patch
        osx-arm.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
