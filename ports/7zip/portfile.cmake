vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ip7z/7zip
    REF "${VERSION}"
    SHA512 7c2fb18261ce9185d29b690ccb7694d7926abe3af0619dbe42b7ab43b400ee71c1eb79c31f892aea2fbdb55036225f31ee393287cce91afd17f20cff8f6cb949
    HEAD_REF main
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/7zip-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/DOC/License.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
