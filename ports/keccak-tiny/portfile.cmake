if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            coruus/${PORT}
    REF             64b6647514212b76ae7bca0dea9b7b197d1d8186
    SHA512          5cf14061efc1b3c934dfb28a08e2a478036109c449aed41d4deb975a9f0748db06f83c1de9e5d991009d04f0220a397f5f66232a4db04bbc0dea0c624522752c
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
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
