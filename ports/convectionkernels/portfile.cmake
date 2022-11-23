vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO elasota/ConvectionKernels
    REF dc2dbbe0ae2cf2be06ef56d1021e2222a56c7fe2
    SHA512 2bf3aff1acb7b2365b882b4c1274ea8bcb9aea3015b5009e0ec50279122ecc623074d0f4fa04ddf8cd457e1f6868075a773bf8a2fa5b4fa9e2fd51d0a76d2560
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-convectionkernels)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
