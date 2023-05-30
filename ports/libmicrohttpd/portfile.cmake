vcpkg_download_distfile(ARCHIVE
    URLS
        "https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${VERSION}.tar.gz"
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${VERSION}.tar.gz"
    FILENAME "libmicrohttpd-${VERSION}.tar.gz"
    SHA512 001025c023dd94c4a0cf017ed575e65a577b5ce595e7e450346bfb75def77eaa8a4cfbeffb9f4b912e34165c2cfca147c02c895e067a4f6c5a321a12035758a5
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(CFG_SUFFIX "dll")
    else()
        set(CFG_SUFFIX "static")
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH w32/VS-Any-Version/libmicrohttpd.vcxproj
        RELEASE_CONFIGURATION "Release-${CFG_SUFFIX}"
        DEBUG_CONFIGURATION "Debug-${CFG_SUFFIX}"
    )
    
    file(GLOB MICROHTTPD_HEADERS "${SOURCE_PATH}/src/include/microhttpd*.h")
    file(COPY ${MICROHTTPD_HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include")
else()
    if(VCPKG_TARGET_IS_OSX AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(ENV{LIBS} "$ENV{LIBS} -framework Foundation -framework AppKit") # TODO: Get this from the extracted cmake vars somehow
    endif()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            --disable-doc
            --disable-nls
            --disable-examples
            --disable-curl
            --disable-https
            --with-gnutls=no
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
