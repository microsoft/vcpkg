string(REGEX REPLACE "[.]([0-9])\$" ".0\\1" upstream_version "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ip7z/7zip
    REF "${upstream_version}"
    SHA512 5f4922efd94e12776e531f77053981978a0d9f8c6da50f51bdb750a54436b07ddccafa6a1180fd234a7fcaf4d2a5b0ab7c2a9267da2ea8e68407bf432ff0f76c
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
