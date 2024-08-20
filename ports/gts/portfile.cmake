vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gts/gts
    REF 0.7.6
    FILENAME gts-0.7.6.tar.gz
    SHA512 645123b72dba3d04dad3c5d936d7e55947826be0fb25e84595368919b720deccddceb7c3b30865a5a40f2458254c2af793b7c014e6719cf07e7f8e6ff30890f8
    PATCHES
        fix-dllexport.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/predicates_init.h" DESTINATION "${SOURCE_PATH}/src")

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DVERSION=${VERSION}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
