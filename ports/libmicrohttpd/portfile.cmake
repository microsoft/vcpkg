vcpkg_download_distfile(ARCHIVE
    URLS
        "https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${VERSION}.tar.gz"
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${VERSION}.tar.gz"
    FILENAME "libmicrohttpd-${VERSION}.tar.gz"
    SHA512 c99b8b93cae5feee8debcc5667ee3ff043412a84b30696fe852e6c138f3c890bb43c8fcd7199f1d2f809d522fef159e83b607c743d6cf3401a57050fbdf9b5c1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES remove_pdb_install.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(CFG_SUFFIX "dll")
    else()
        set(CFG_SUFFIX "static")
    endif()

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH w32/VS-Any-Version/libmicrohttpd.vcxproj
        RELEASE_CONFIGURATION "Release-${CFG_SUFFIX}"
        DEBUG_CONFIGURATION "Debug-${CFG_SUFFIX}"
    )
    
    file(GLOB MICROHTTPD_HEADERS "${SOURCE_PATH}/src/include/microhttpd.h")
    file(COPY ${MICROHTTPD_HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include")
else()
    vcpkg_list(SET config_args)
    if(VCPKG_TARGET_IS_OSX AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(ENV{LIBS} "$ENV{LIBS} -framework Foundation -framework AppKit") # TODO: Get this from the extracted cmake vars somehow
    endif()
    if("https" IN_LIST FEATURES)
        vcpkg_list(APPEND config_args "--enable-https")
    else()
        vcpkg_list(APPEND config_args "--disable-https")
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            --disable-doc
            --disable-nls
            --disable-examples
            --disable-curl
            ${config_args}
        OPTIONS_DEBUG --enable-asserts
        OPTIONS_RELEASE --disable-asserts
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
