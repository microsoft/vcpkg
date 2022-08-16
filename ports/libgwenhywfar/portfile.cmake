set(VERSION_MAJOR 5)
set(VERSION_MINOR 7)
set(VERSION_PATCH 3)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.aquamaniac.de/rdm/attachments/download/390/gwenhywfar-${VERSION}.tar.gz"
    FILENAME "gwenhywfar-${VERSION}.tar.gz"
    SHA512 c005c0af36786a000cf317647440304f6779b531256cdbd5d67180b7b0b2056c230391a3845057d6061875c505f88f9f23fe086dc7e8a04d35fed33c61a0fb47
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES
        0001-Add-support-for-static-builds.patch
        0001-Use-pkg-config-to-find-libgcrypt-gpg-error.patch
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
    AUTOCONFIG
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
    vcpkg_cmake_config_fixup(PACKAGE_NAME  gwengui-cpp CONFIG_PATH lib/cmake/gwengui-${GUI}-${VERSION_MAJOR}.${VERSION_MINOR} DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()
vcpkg_cmake_config_fixup(PACKAGE_NAME gwenhywfar CONFIG_PATH lib/cmake/gwenhywfar-${VERSION_MAJOR}.${VERSION_MINOR})

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(SEARCH_DIR ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin TOOL_NAMES gct-tool gsa mklistdoc typemaker typemaker2 xmlmerge AUTO_CLEAN)
endif()

# the `dir` variable is not used in the script
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgwenhywfar/bin/gwenhywfar-config" "dir=\"${CURRENT_INSTALLED_DIR}\"" "")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgwenhywfar/debug/bin/gwenhywfar-config" "dir=\"${CURRENT_INSTALLED_DIR}/debug\"" "")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

