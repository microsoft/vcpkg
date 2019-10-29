include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://sourceforge.net/projects/xmp/files/libxmp/4.4.1/libxmp-lite-4.4.1.tar.gz"
    FILENAME "libxmp-lite-4.4.1.tar.gz"
    SHA512 f27e3f9fb79ff15ce90b51fb29641c01cadf7455150da57cde6860c2ba075ed497650eb44ec9143bdd3538288228c609f7db6d862c9d73f007f686eccb05543e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-msvc-buildfix.patch
        0002-fix-symbols.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
