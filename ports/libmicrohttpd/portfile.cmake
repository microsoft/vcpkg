vcpkg_download_distfile(ARCHIVE
    URLS
        "https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-${VERSION}.tar.gz"
        "https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${VERSION}.tar.gz"
    FILENAME "libmicrohttpd-${VERSION}.tar.gz"
    SHA512 7ed3e81f0c4253a409f5e825446c8d2d8b975c0eb6f381b6867796bbdcf4890004a24659e95b8ec8c39e8df0a9885cc08a0ba75f953893ee1455ae180dc89391
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

    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTORECONF
        OPTIONS
            --disable-doc
            --disable-examples
            --disable-curl
            --disable-tools
            ${config_args}
        OPTIONS_DEBUG --enable-asserts
        OPTIONS_RELEASE --disable-asserts
    )

    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
