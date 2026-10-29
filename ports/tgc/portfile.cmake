vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orangeduck/tgc
    REF 35207051557c79ea25942c021fb18856c72af8e3
    SHA512 d56153cfb00ad4941c7c88e6cc54b54812466e95b61581e9f71e41b6200746e2143344f0d292032e92f7c90eaa60d0df91120b36e3aad0e354836df6d28e2c35
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE.md" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
