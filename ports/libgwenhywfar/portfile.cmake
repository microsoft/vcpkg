vcpkg_download_distfile(ARCHIVE
    URLS "https://www.aquamaniac.de/rdm/attachments/download/529/gwenhywfar-5.12.0.tar.gz"
    FILENAME "gwenhywfar-${VERSION}.tar.gz"
    SHA512 0075eb626f0022ecd4ffdd59de7f0817d2def685e1d2cfbca9a32faa4b8d4d213bea631f24c5385da0b8c7743fd6d1887a46f08afa371195d911409ec7655791
)

vcpkg_download_distfile(osx_patch
    URLS "https://www.aquamaniac.de/rdm/projects/gwenhywfar/repository/revisions/55d4b7b526df30e4003c92e2f504f480c01021f0/diff?format=diff"
    FILENAME "gwenhywfar-5.12.0-55d4b7b.diff"
    SHA512 87fa9ff3e9027c5a6839f800990b420a824efbd115ed67eeaef3c909b14c59c0b9bae41c539d400166862c0353ad730313ee4f9366928c333883d41429912731
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
    PATCHES
        control-openssl.diff
        pkgconfig.diff
        static-link-order.diff
        ${osx_patch}
)

vcpkg_list(SET options)
if ("libxml2" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--with-libxml2-code=yes")
endif()

if ("cpp" IN_LIST FEATURES)
    list(APPEND FEATURES_GUI "cpp")
endif()
if ("qt5" IN_LIST FEATURES)
    list(APPEND FEATURES_GUI "qt5")
endif()
list(JOIN FEATURES_GUI " " GUIS)
vcpkg_list(APPEND options "--with-guis=${GUIS}")

if ("openssl" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--with-openssl=yes")
endif()

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/libgpg-error/aclocal/\" -I \"${CURRENT_INSTALLED_DIR}/share/libgcrypt/aclocal/\" -I \"${CURRENT_HOST_INSTALLED_DIR}/share/gettext/aclocal/\"")
set(ENV{AUTOPOINT} true)
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --disable-binreloc
        --disable-network-checks
        --disable-nls
        ${options}
    OPTIONS_RELEASE
        "--with-qt5-qmake=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin/qmake"
        "--with-qt5-moc=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin/moc"
        "--with-qt5-uic=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin/uic"
        "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpgrt-config gpg-error"
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpgrt-config"
        "LIBGCRYPT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgcrypt/bin/libgcrypt-config"
    OPTIONS_DEBUG
        "--with-qt5-qmake=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/debug/bin/qmake"
        "--with-qt5-moc=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/debug/bin/moc"
        "--with-qt5-uic=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/debug/bin/uic"
        "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpgrt-config gpg-error"
        "GPGRT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpgrt-config"
        "LIBGCRYPT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgcrypt/debug/bin/libgcrypt-config"
)

vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REGEX MATCH "^([0-9]*[.][0-9]*)" MAJOR_MINOR "${VERSION}")
    foreach(GUI IN LISTS FEATURES_GUI)
        vcpkg_cmake_config_fixup(PACKAGE_NAME gwengui-${GUI} CONFIG_PATH lib/cmake/gwengui-${GUI}-${MAJOR_MINOR} DO_NOT_DELETE_PARENT_CONFIG_PATH)
    endforeach()
    vcpkg_cmake_config_fixup(PACKAGE_NAME gwenhywfar CONFIG_PATH lib/cmake/gwenhywfar-${MAJOR_MINOR})
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
endif()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/gwenhywfar-config" [[dir="[^"]*"]] [[dir=""]] REGEX) # unused abs path
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
