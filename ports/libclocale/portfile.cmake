set(LIB_FILENAME libclocale-alpha-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libclocale/releases/download/${VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 690f40e8292b233f8a0dd84554286979093496ad880cc0bcd4c2d5242107e62668fd98444fcc31168b85cc2a4b5885522f198900403c08b1e8c46fd7a7ecb129
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

    vcpkg_libyal_msvscpp_convert(
        OUT_PROJECT_SUBPATH project_subpath
        SOURCE_PATH "${SOURCE_PATH}"
        SOLUTION "msvscpp/libclocale.sln"
    )

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "${project_subpath}"
        DEBUG_CONFIGURATION VSDebug
    )

    file(GLOB headers "${SOURCE_PATH}/include/libclocale/*.h")
    file(INSTALL ${headers} DESTINATION "${CURRENT_PACKAGES_DIR}/include/libclocale")
    file(INSTALL "${SOURCE_PATH}/include/libclocale.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

    file(GLOB tests "${CURRENT_PACKAGES_DIR}/tools/${PORT}/clocale_test*.exe")
    file(REMOVE_RECURSE ${tests})

    block(SCOPE_FOR VARIABLES)
        set(prefix [[unused]])
        set(exec_prefix [[${prefix}]])
        set(libdir [[${prefiix}/lib]])
        set(includedir [[${prefix}/include]])
        configure_file("${SOURCE_PATH}/libclocale.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libclocale.pc" @ONLY)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libclocale.pc" " -lclocale" " -llibclocale")
        if(NOT VCPKG_BUILD_TYPE)
            set(includedir [[${prefix}/../include]])
            configure_file("${SOURCE_PATH}/libclocale.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libclocale.pc" @ONLY)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libclocale.pc" " -lclocale" " -llibclocale")
        endif()
    endblock()

else()
vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    vcpkg_list(APPEND options "--disable-nls")
endif()

if(VCPKG_TARGET_IS_ANDROID)
    list(APPEND options --with-pthread=no) # may have pthread but not -lpthread
endif()

vcpkg_configure_make(
    COPY_SOURCE
    DETERMINE_BUILD_TRIPLET
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        
        # Avoiding bundled libraries.
        --with-libcerror=yes
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

endif()

file(INSTALL "${CURRENT_PORT_DIR}/unofficial-libclocale-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libclocale")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${SOURCE_PATH}/include/libclocale/extern.h" "defined( LIBCLOCALE_DLL_IMPORT )" "1")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man3"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
