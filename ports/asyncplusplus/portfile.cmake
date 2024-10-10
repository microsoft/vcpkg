vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Amanieu/asyncplusplus
    REF 4159da79e20ad6d0eb1f13baa0f10e989edd9fba
    SHA512 a7b099ce24184aa56e843d4858228196f8220374585a375a9c0d944832bd68c8aabd6b2efde5aacbb9c73f9dd8e942e97262be04550205b3fbea44d8b972d78e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake PACKAGE_NAME async++)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
