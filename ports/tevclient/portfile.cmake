vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO westlicht/tevclient
    REF aae4d33472bcf23a5b66af27dcea7ca299b61976
    SHA512 e452b6b6cfbe7fc56e0f4794c8a4ecdd5695da2a8ae006ea02fed0a4c5a13a411042e66f6996a7e49b789a5ff86cdfb771cb55ba0a30465649ed1c4f5f7062c4
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
 )

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/tevclient)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
