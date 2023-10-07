vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            PeterScott/${PORT}
    REF             dae94be0c0f54a399d23ea6cbe54bca5a4e93ce4
    SHA512          1bc01eefc04f06704800a7448231db9f82fc809079bd3f43ef24d7dd3d8deaec2143f252a8e556dafe366401f898b676922b0c93ac181aaf38ae69ad638adbba
    HEAD_REF        master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
     DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "CC0-1.0")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" [=[
${PORT} provides CMake targets:
    find_package(unofficial-${PORT} CONFIG REQUIRED)
    target_link_libraries(main PRIVATE unofficial::${PORT}::${PORT})
]=])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
