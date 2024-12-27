vcpkg_download_distfile(ARCHIVE
    URLS https://github.com/jstedfast/gmime/releases/download/${VERSION}/gmime-${VERSION}.tar.xz
    FILENAME "gmime-${VERSION}.tar.xz"
    SHA512 cafb89854b2441508bf940fd6f991739d30fb137b8928ad33e8e4d2a0293a6460e4d1318e73c3ee9e5a964b692f36e7a4eb5f2930c6998698bd9edf866629655
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/aclocal/\"")
set(ENV{GTKDOCIZE} true)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-crypto
        --disable-glibtest
        --disable-introspection
        --disable-vala
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(COPY "${SOURCE_PATH}/build/vs2017/unistd.h" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${SOURCE_PATH}/build/vs2017/unistd.h" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    endif()
endif()

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
