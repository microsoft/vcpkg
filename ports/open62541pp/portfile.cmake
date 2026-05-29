vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541pp/open62541pp
    REF "v${VERSION}"
    SHA512 6b908772bb9b6d157b9cac13693118f4359b59cb32294d207b1ed87ee35a38bd7d22e3c3b6229115a42259fc9f8dc7ce51ec315a8233773f035ea2974c737fc5
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUAPP_INTERNAL_OPEN62541=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
