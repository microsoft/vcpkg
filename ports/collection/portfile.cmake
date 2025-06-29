vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-patterns/collection
    REF "${VERSION}"
    SHA512 edca588652c919fd6e6dd4eb552816a6906b7a9a556e110ea38cac24882a4ac60d34ca9ee3f8193af2fe1ccc12ee849495e4dba41ddfe9fb964df44bcb8a5bc6
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup() # removes /debug/share

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") # removes debug/include
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") # usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE") # LICENSE
