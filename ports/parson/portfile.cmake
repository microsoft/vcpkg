vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kgabis/parson
    REF 1314bf8ad6f22edd2feb9d8c867756f41db21f2a # accessed on 2022-11-13
    SHA512 5f6003caea40c093dedfbd85dfe6d33202708b37b59ad9eeb815a5d287dd7b37f3522d3bf35fb718eab13260bb0c129b691703f04b9f1c3dbe7bef4b494928be
    HEAD_REF master
    PATCHES
        fix-cmake-files-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
