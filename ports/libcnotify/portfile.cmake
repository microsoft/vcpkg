set(LIB_FILENAME libcnotify-beta-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libcnotify/releases/download/${VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 ba1599ae28f8a8fb9471317768d9cea1adfc1eec216239bfa672d1fc0bbb72979edcc2538e46228c1fd2d13a0ac14755fcdf74baa9250d9f8fec63c048397bcf
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

    vcpkg_libyal_msvscpp_convert(
        OUT_PROJECT_SUBPATH project_subpath
        SOURCE_PATH "${SOURCE_PATH}"
        SOLUTION "msvscpp/libcnotify.sln"
    )

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "${project_subpath}"
        DEBUG_CONFIGURATION VSDebug
    )

    file(GLOB headers "${SOURCE_PATH}/include/libcnotify/*.h")
    file(INSTALL ${headers} DESTINATION "${CURRENT_PACKAGES_DIR}/include/libcnotify")
    file(INSTALL "${SOURCE_PATH}/include/libcnotify.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

    file(GLOB tests "${CURRENT_PACKAGES_DIR}/tools/${PORT}/cerror_test*.exe")
    file(REMOVE_RECURSE ${tests})

    block(SCOPE_FOR VARIABLES)
        set(prefix [[unused]])
        set(exec_prefix [[${prefix}]])
        set(libdir [[${prefiix}/lib]])
        set(includedir [[${prefix}/include]])
        configure_file("${SOURCE_PATH}/libcnotify.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libcnotify.pc" @ONLY)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libcnotify.pc" " -lcnotify" " -llibcnotify")
        if(NOT VCPKG_BUILD_TYPE)
            set(includedir [[${prefix}/../include]])
            configure_file("${SOURCE_PATH}/libcnotify.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libcnotify.pc" @ONLY)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libcnotify.pc" " -lcnotify" " -llibcnotify")
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

file(INSTALL "${CURRENT_PORT_DIR}/unofficial-libcnotify-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libcnotify")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${SOURCE_PATH}/include/libcnotify/extern.h" "defined( LIBCNOTIFY_DLL_IMPORT )" "1")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man3"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
