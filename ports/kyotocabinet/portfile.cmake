vcpkg_download_distfile(ARCHIVE
    URLS https://dbmx.net/kyotocabinet/pkg/kyotocabinet-${VERSION}.tar.gz
    FILENAME "kyotocabinet-${VERSION}.tar.gz"
    SHA512 9fe0a92c9a76db5ce06ef4d5a551c05930f2a9c065ab695b030fdaf45692bfe88d91f1b75791f50d0772c699567744cd74f3ef407172874d4bba467989d54328
    PATCHES
        fix-vcpkg-cross-linking.patch
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_make_configure(
    COPY_SOURCE
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-opt
        --disable-lzo
        --disable-lzma
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/FOSSEXCEPTION"
    "${SOURCE_PATH}/LINKEXCEPTION"
)
