string(REGEX REPLACE "[.]([0-9])\$" ".0\\1" upstream_version "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ip7z/7zip
    REF "${upstream_version}"
    SHA512 74a8a909dcf4f50480c2737d333ec16da431a2f95439efe5a364804e47be19daf0ed56f96c63f8fb7e9484b746d45a324e0b4c0921c160037bba6f643eaeb8fa
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
