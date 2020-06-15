vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/qwt/files/qwt/6.1.4/qwt-6.1.4.zip"
    FILENAME "qwt-6.1.4.zip"
    SHA512 711256ec4d1d54d201650e9c63b584b17a61dbedde5a581e0b6227fdbee149cdbe2a889aa58f67777125b6471fc1fe248992ec845eb6481a2dfc2c4276701d7f
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES fix-dynamic-static.patch
            build.patch
)

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        CONFIG+=${VCPKG_LIBRARY_LINKAGE}
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_install_qmake(
        RELEASE_TARGETS sub-src-release_ordered
        DEBUG_TARGETS sub-src-debug_ordered
    )
else ()
    vcpkg_install_qmake(
        RELEASE_TARGETS sub-src-all-ordered
        DEBUG_TARGETS sub-src-all-ordered
    )
endif()

#Install the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
