vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541pp/open62541pp
    REF "v${VERSION}"
    SHA512 77dbcc26330271ddffe1fc58a192f01fca43d18de1df4e36fae65f86b6fa3af30f22589beb0a56f654830946ee3ab0518e37246deff4df99cb9950ec1f60f2bf
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
