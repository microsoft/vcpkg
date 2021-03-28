set(VERSION_MAJOR 6)
set(VERSION_MINOR 2)
set(VERSION_PATCH 9)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.aquamaniac.de/rdm/attachments/download/366/aqbanking-${VERSION}.tar.gz"
    FILENAME "aqbanking-${VERSION}.tar.gz"
    SHA512 6649e0851d28374a4dc650a8a93d55bf10cff953a0a3c1ceffd0d5bbf4c9c0625b9a6daec8599c2f062092f996d0727187e5409555941b93f05862e6a28861e1
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    REF ${VERSION}
)

list(REMOVE_ITEM FEATURES core)
list(TRANSFORM FEATURES PREPEND "aq")
list(JOIN FEATURES " " BACKENDS)

if(VCPKG_TARGET_IS_OSX)
    set(LDFLAGS "-framework CoreFoundation -framework Security")
else()
    set(LDFLAGS "")
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-silent-rules
        --enable-cli=no
        --with-backends=${BACKENDS}
        --with-typemaker2-exe=${CURRENT_INSTALLED_DIR}/tools/libgwenhywfar/bin/typemaker2
        --with-xmlmerge=${CURRENT_INSTALLED_DIR}/tools/libgwenhywfar/bin/xmlmerge
        "LDFLAGS=${LDFLAGS}"
        "XMLSEC_LIBS=-lxmlsec1"
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

foreach(GUI IN LISTS FEATURES)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/gwengui-${GUI}-${VERSION_MAJOR}.${VERSION_MINOR} TARGET_PATH share/gwengui-${GUI}-${VERSION_MAJOR}.${VERSION_MINOR} DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/gwenhywfar-${VERSION_MAJOR}.${VERSION_MINOR})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
