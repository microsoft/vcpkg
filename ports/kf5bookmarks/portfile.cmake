vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kbookmarks
    REF v5.89.0
    SHA512 590b95c049600745995c76c2c7b8033eb591f8b7c1a2b832068a0e0d668858e04b1ed4a1fc8d2ef3c7fe43c5f3b7b311a7d0626a1053706fd46cbc5506c222b8
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Bookmarks CONFIG_PATH lib/cmake/KF5Bookmarks)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
