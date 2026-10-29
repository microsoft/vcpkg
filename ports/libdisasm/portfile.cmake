vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bastard/libdisasm
    REF 0.23
    FILENAME "libdisasm-0.23.tar.gz"
    SHA512 29eecfbfd8168188242278a1a38f0c90770d0581a52d4600ae6343829dd0d6607b98329f12a3d7409d43dd56dca6a7d1eb25d58a001c2bfd3eb8474c0e7879e7
    PATCHES sizeofvoid.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
