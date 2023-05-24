vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Cbc
    REF 133f1171f1667c930e46efd350f4be8ad995b231
    SHA512 0433715b0d08a3b6862b61371cbbf9956bc98b350c61b9fafe6526feb3d90aad04757d380467cc2b6c8014898ca850fa0d2b325849326e16751de1d68d54b270
    ## PATCHES fix-c1083-error.patch
)

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")
#file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
#file(COPY ${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)