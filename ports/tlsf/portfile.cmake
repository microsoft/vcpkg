vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattconte/tlsf
    REF deff9ab509341f264addbd3c8ada533678591905
    SHA512 06fccc2265c648945b124a3a3a7fb40619440a0717b7088b777ceb34d03d1bfb70dcccab799640bab8041a2daa944a4f448f7fd52e11d9530a76662343d9df31
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Upstream has no standalone license file; the BSD-3-Clause text lives in the header.
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/tlsf.h")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
