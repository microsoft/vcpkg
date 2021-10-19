set(OFX_VERSION 0.10.3)

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/${PORT}/${PORT}/${PORT}-${OFX_VERSION}.tar.gz"
    FILENAME "${PORT}-${OFX_VERSION}.tar.gz"
    SHA512 a46662bc425a4d343c0ac8e7885feb62f6854096b5cb2667e0f7419b380fcd8409f82bf287373bb23827b5abbee79b191edd871e434b9266e6aa7c35f2578097
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    list(APPEND PATCHES
        getopt.diff         # https://github.com/libofx/libofx/pull/50
    )
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${OFX_VERSION}
    PATCHES
        msvc.diff           # https://github.com/libofx/libofx/pull/47
        pkgconfig.patch     # https://github.com/libofx/libofx/pull/49
        ${PATCHES}
)

# libopensp requirements
if(VCPKG_TARGET_IS_OSX)
    list(APPEND EXTRA_OPTS "LIBS=-lintl -liconv \$LIBS")
    list(APPEND EXTRA_OPTS "LDFLAGS=-framework CoreFoundation \$LDFLAGS")
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --enable-doxygen=no
        --enable-html-docs=no
        --enable-latex-docs=no
        --disable-gengetopt
        "--with-opensp-includes=${CURRENT_INSTALLED_DIR}/include/OpenSP"
        ${EXTRA_OPTS}
    OPTIONS_RELEASE
        "--with-opensp-libs=${CURRENT_INSTALLED_DIR}/lib"
    OPTIONS_DEBUG
        "--with-opensp-libs=${CURRENT_INSTALLED_DIR}/debug/lib"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/html") # empty
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
