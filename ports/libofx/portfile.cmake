set(OFX_VERSION 0.10.3)

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/${PORT}/${PORT}/${PORT}-${OFX_VERSION}.tar.gz"
    FILENAME "${PORT}-${OFX_VERSION}.tar.gz"
    SHA512 a46662bc425a4d343c0ac8e7885feb62f6854096b5cb2667e0f7419b380fcd8409f82bf287373bb23827b5abbee79b191edd871e434b9266e6aa7c35f2578097
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${OFX_VERSION}
)

# libopensp requirements
list(APPEND EXTRA_OPTS "LIBS=-lintl -liconv \$LIBS")
if(VCPKG_TARGET_IS_OSX)
    list(APPEND EXTRA_OPTS "LDFLAGS=-framework CoreFoundation \$LDFLAGS") 
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --enable-doxygen=no
        --enable-html-docs=no
        --enable-latex-docs=no
        --with-opensp-includes="${CURRENT_INSTALLED_DIR}/include/OpenSP"
        --with-opensp-libs="${CURRENT_INSTALLED_DIR}/lib"
        ${EXTRA_OPTS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/html") # empty
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
