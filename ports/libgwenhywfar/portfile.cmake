vcpkg_download_distfile(ARCHIVE
    URLS "https://www.aquamaniac.de/rdm/attachments/download/364/gwenhywfar-${VERSION}.tar.gz"
    FILENAME "gwenhywfar-${VERSION}.tar.gz"
    SHA512 9875d677f49fc0a46f371fd1954d15d99c7d5994e90b16f1be7a5b8a1cbcd74ae9733e4541afd6d8251a2ba1a0a37c28e0f248952b7c917313fbf5b38b1d8d11
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
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

if(VCPKG_TARGET_IS_OSX)
    vcpkg_list(APPEND options "LDFLAGS=\$LDFLAGS -framework CoreFoundation -framework Security")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-binreloc
        ${options}
    OPTIONS_RELEASE
        "--with-qt5-qmake=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin/qmake"
        "--with-qt5-moc=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin/moc"
        "--with-qt5-uic=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin/uic"
        "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/bin/gpgrt-config"
        "gpg_error_config_args=gpg-error"
        "LIBGCRYPT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgcrypt/bin/libgcrypt-config"
    OPTIONS_DEBUG
        "--with-qt5-qmake=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/debug/bin/qmake"
        "--with-qt5-moc=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/debug/bin/moc"
        "--with-qt5-uic=${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/debug/bin/uic"
        "GPG_ERROR_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgpg-error/debug/bin/gpgrt-config"
        "gpg_error_config_args=gpg-error"
        "LIBGCRYPT_CONFIG=${CURRENT_INSTALLED_DIR}/tools/libgcrypt/debug/bin/libgcrypt-config"
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

string(REGEX MATCH "^([0-9]*[.][0-9]*)" MAJOR_MINOR "${VERSION}")
foreach(GUI IN LISTS FEATURES_GUI)
    vcpkg_cmake_config_fixup(PACKAGE_NAME gwengui-${GUI} CONFIG_PATH lib/cmake/gwengui-${GUI}-${MAJOR_MINOR} DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()
vcpkg_cmake_config_fixup(PACKAGE_NAME gwenhywfar CONFIG_PATH lib/cmake/gwenhywfar-${MAJOR_MINOR})

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin" TOOL_NAMES gct-tool gsa mklistdoc typemaker typemaker2 xmlmerge AUTO_CLEAN)
endif()

# the `dir` variable is not used in the script
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgwenhywfar/bin/gwenhywfar-config" "dir=\"${CURRENT_INSTALLED_DIR}\"" "")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgwenhywfar/debug/bin/gwenhywfar-config" "dir=\"${CURRENT_INSTALLED_DIR}/debug\"" "")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
