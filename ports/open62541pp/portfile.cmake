vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541pp/open62541pp
    REF "v${VERSION}"
    SHA512 07cef9ac07c140baa512b4fd8fa51da228d06616a047ec4f553d04fbb8b555ed4277471fd52856ea71ed2f66424a68377f4b5ed75e52c0e6e6220dc4f9754ccd
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
