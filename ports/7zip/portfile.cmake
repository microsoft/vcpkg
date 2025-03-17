vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ip7z/7zip
    REF "${VERSION}"
    SHA512 dc0241ed96907965445550912d1171fe32230a52997b089558a4cc73a662fc6a17940db8dcb0794b805268964899d9e5a48ddb444e92b56fd243bbaa17c20a1c
    HEAD_REF main
    PATCHES
        fix_timespec_get_broken_on_android.patch
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
