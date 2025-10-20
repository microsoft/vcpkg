string(REGEX REPLACE "[.]([0-9])\$" ".0\\1" upstream_version "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ip7z/7zip
    REF "${upstream_version}"
    SHA512 eb5ed600f82aca52f6dc8d2be3e4da4380670308dff2bcbfc96255d9d23bb5ca35dea073bd97070f0a1891b2f329d88a06b304f48e30f4ad89256c7664e9c1ea
    HEAD_REF main
    PATCHES
        sort-asm.diff
        fix_timespec_get_broken_on_android.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/7zip-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/DOC/License.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
