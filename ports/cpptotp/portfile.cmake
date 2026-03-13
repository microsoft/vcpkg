vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RavuAlHemio/cpptotp
    REF "696f618aec5c97970dd0948fef11cf46f7dfa255"
    SHA512 02fa5f4c555be1a4a64ac3546ff3a5ec47af5ea78893f65a6e2ee2f41cf64e1081a7fc438398e8fdc967ce50800ca8910a0a299fff6687c7c3e6d6dd861778f0
    PATCHES fix-cmake-for-vcpkg.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/cpptotp-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

