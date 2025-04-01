vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mysvac/cpp-jsonlib
    REF "${VERSION}"
    SHA512 b1f017d5ce5e3ea67640048fd5b84a9efe64d6cfc599696838af4d264d3638e2f52f58aec727d78a20dc1f2a9d076615c72956180b5bfd7a0c1a487cc264a319
    HEAD_REF main
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_cmake_config_fixup(PACKAGE_NAME "cpp-jsonlib")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
