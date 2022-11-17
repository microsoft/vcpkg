vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xmp/libxmp
    REF 4.4.1
    FILENAME "libxmp-lite-4.4.1.tar.gz"
    SHA512 f27e3f9fb79ff15ce90b51fb29641c01cadf7455150da57cde6860c2ba075ed497650eb44ec9143bdd3538288228c609f7db6d862c9d73f007f686eccb05543e
    PATCHES
        0001-msvc-buildfix.patch
        0002-fix-symbols.patch
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
