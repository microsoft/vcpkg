vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports unix platforms" ON_TARGET "Windows")

set(VERSION_MAJOR 5)
set(VERSION_MINOR 6)
set(VERSION_PATCH 0)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.aquamaniac.de/rdm/attachments/download/364/gwenhywfar-${VERSION}.tar.gz"
    FILENAME "gwenhywfar-${VERSION}.tar.gz"
    SHA512 9875d677f49fc0a46f371fd1954d15d99c7d5994e90b16f1be7a5b8a1cbcd74ae9733e4541afd6d8251a2ba1a0a37c28e0f248952b7c917313fbf5b38b1d8d11
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    REF ${VERSION}
)

if ("libxml2" IN_LIST FEATURES)
   set(WITH_LIBXML2_CODE "--with-libxml2-code=yes")
endif()
if ("cpp" IN_LIST FEATURES)
   list(APPEND FEATURES_GUI "cpp")
endif()
if ("qt5" IN_LIST FEATURES)
   list(APPEND FEATURES_GUI "qt5")
endif()

list(JOIN FEATURES_GUI " " GUIS)

if(VCPKG_TARGET_IS_OSX)
    set(LDFLAGS "-framework CoreFoundation -framework Security")
else()
    set(LDFLAGS "")
endif()

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-silent-rules
        --disable-binreloc 
        --with-guis=${GUIS}
        --with-libgpg-error-prefix=${CURRENT_INSTALLED_DIR}/tools/libgpg-error
        --with-libgcrypt-prefix=${CURRENT_INSTALLED_DIR}/tools/libgcrypt
        --with-qt5-qmake=${CURRENT_INSTALLED_DIR}/tools/qt5/bin/qmake
        --with-qt5-moc=${CURRENT_INSTALLED_DIR}/tools/qt5/bin/moc
        --with-qt5-uic=${CURRENT_INSTALLED_DIR}/tools/qt5/bin/uic
        ${WITH_LIBXML2_CODE}
        "LDFLAGS=${LDFLAGS}"
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

foreach(GUI IN LISTS FEATURES_GUI)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/gwengui-${GUI}-${VERSION_MAJOR}.${VERSION_MINOR} TARGET_PATH share/gwengui-${GUI}-${VERSION_MAJOR}.${VERSION_MINOR} DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/gwenhywfar-${VERSION_MAJOR}.${VERSION_MINOR})

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(SEARCH_DIR ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin TOOL_NAMES gct-tool gsa mklistdoc typemaker typemaker2 xmlmerge AUTO_CLEAN)
endif()    

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
