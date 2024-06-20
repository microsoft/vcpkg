vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kokke/tiny-AES-c
    REF ca85e00de963102d3999ea5fa865c0deff6370d3
    SHA512 538d5d9cee8cecbf801d3553f2425f8a1331b59c652c11ee56c6e46a23450c1e9a59e3e1833f4384b7a4d992a93f30635855a47e2414b9293e0d27c426b6a4f3
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/unlicense.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
