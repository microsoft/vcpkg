set(MICROHTTPD_VERSION 0.9.75)

vcpkg_download_distfile(ARCHIVE
    URLS
        "https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
    FILENAME "libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
    SHA512 4dc62ed191342a61cc2767171bb1ff4050f390db14ef7100299888237b52ea0b04b939c843878fe7f5daec2b35a47b3c1b7e7c11fb32d458184fe6b19986a37c
)

vcpkg_extract_source_archive_ex(
    ARCHIVE "${ARCHIVE}"
    OUT_SOURCE_PATH SOURCE_PATH
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(CFG_SUFFIX "dll")
    else()
        set(CFG_SUFFIX "static")
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH w32/VS2015/libmicrohttpd.vcxproj
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
