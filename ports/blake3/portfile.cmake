vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE3-team/BLAKE3
    REF 1.3.1
    SHA512 9906673a9eca100a6ad8c369f4c380ac66b59ed055cb8358fe99bb67ebbcc98e24da5860b257136a1f9cc8ece5733b2ac68c55b9be65ae6f2904ffd92ef34ce6
    HEAD_REF main
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
