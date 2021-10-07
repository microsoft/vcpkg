set(FREEXL_VERSION_STR "1.0.6")

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-${FREEXL_VERSION_STR}.tar.gz"
    FILENAME "freexl-${FREEXL_VERSION_STR}.tar.gz"
    SHA512 efbbe261e57d5c05167ad8e1d5a5b348a7e702c0a4030b18dd2a8c60a38332caccbb073ff604bdf5bafac827310b41c7b79f9fa519ea512d6de2eafd9c1f71f6
)

vcpkg_extract_source_archive_ex(
    ARCHIVE "${ARCHIVE}"
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        fix-makefiles.patch
        fix-sources.patch
        fix-pc-file.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(OPTFLAGS "/nologo /fp:precise /W3 /D_CRT_SECURE_NO_WARNINGS /DDLL_EXPORT")
    set(LIBS_ALL "iconv.lib charset.lib")
    if(VCPKG_TARGET_IS_UWP)
        string(APPEND OPTFLAGS " /DWINAPI_FAMILY=WINAPI_FAMILY_APP")
        string(APPEND LIBS_ALL " WindowsApp.lib /APPCONTAINER")
    endif()
    cmake_path(NATIVE_PATH CURRENT_PACKAGES_DIR INSTDIR)
    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            "OPTFLAGS=${OPTFLAGS}"
            "CFLAGS=-I. -Iheaders ${OPTFLAGS}"
            "LIBS_ALL=${LIBS_ALL}"
        OPTIONS_DEBUG
            "INSTDIR=${INSTDIR}\\debug"
            "LINK_FLAGS=/debug /LIBPATH:\"${CURRENT_INSTALLED_DIR}/debug/lib\""
        OPTIONS_RELEASE
            "INSTDIR=${INSTDIR}"
            "LINK_FLAGS=/LIBPATH:\"${CURRENT_INSTALLED_DIR}/lib\""
    )
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/freexl_i.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/freexl_i.lib")
    else()
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/freexl.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/freexl.lib")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/freexl_i.lib" "${CURRENT_PACKAGES_DIR}/lib/freexl.lib")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/freexl_i.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/freexl.lib")
        endif()
    endif()

    set(VERSION "${FREEXL_VERSION_STR}")
    set(libdir [[${prefix}/lib]])
    set(exec_prefix [[${prefix}]])
    set(ICONV_LIBS "-liconv -lcharset")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(includedir [[${prefix}/include]])
        set(outfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freexl.pc")
        configure_file("${SOURCE_PATH}/freexl.pc.in" "${outfile}" @ONLY)
        vcpkg_replace_string("${outfile}" " -lm" "")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(includedir [[${prefix}/../include]])
        set(outfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freexl.pc")
        configure_file("${SOURCE_PATH}/freexl.pc.in" "${outfile}" @ONLY)
        vcpkg_replace_string("${outfile}" " -lm" "")
    endif()

else()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
    )
    vcpkg_install_make()

endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
