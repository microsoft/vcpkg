vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
set(ADDITIONAL_OPTIONS -DSHARED=OFF)

vcpkg_download_distfile(ARCHIVE
    URLS "http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/parmetis-4.0.3.tar.gz"
    FILENAME "parmetis-4.0.3.tar.gz"
    SHA512 454a91921ca35c981df11c9846a11963ff8fd8407a25179453af33f8fe69493f6dd7f2a0b8feed9a7d3f121e45b715749dd7a94873eaac2bae4cad1e535ca132
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-metis-vs14-math.patch
        fix-gklib-vs14-math.patch
        fix-root-cmakelist.patch
        fix-libparmetis-cmakelist.patch
        use_stdint.patch
        fix-root-cmakelist-2.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/parmetis)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/parmetis/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/parmetis/copyright)
