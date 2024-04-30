set(LIB_FILENAME libcerror-beta-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libcerror/releases/download/${VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 9fd06098e7d789040ccdbad0d9d824a456cfb6cd90d355a7ea44bbd04bc3d53370025df84721a70fd542b2d691833c4447d4a2230071c3cd987c108a41b73a9b
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

    vcpkg_libyal_msvscpp_convert(
        OUT_PROJECT_SUBPATH project_subpath
        SOURCE_PATH "${SOURCE_PATH}"
        SOLUTION "msvscpp/libcerror.sln"
    )

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "${project_subpath}"
        DEBUG_CONFIGURATION VSDebug
    )

    file(GLOB headers "${SOURCE_PATH}/include/libcerror/*.h")
    file(INSTALL ${headers} DESTINATION "${CURRENT_PACKAGES_DIR}/include/libcerror")
    file(INSTALL "${SOURCE_PATH}/include/libcerror.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

    file(GLOB tests "${CURRENT_PACKAGES_DIR}/tools/${PORT}/cerror_test*.exe")
    file(REMOVE_RECURSE ${tests})

    block(SCOPE_FOR VARIABLES)
        set(prefix [[unused]])
        set(exec_prefix [[${prefix}]])
        set(libdir [[${prefiix}/lib]])
        set(includedir [[${prefix}/include]])
        configure_file("${SOURCE_PATH}/libcerror.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libcerror.pc" @ONLY)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libcerror.pc" " -lcerror" " -llibcerror")
        if(NOT VCPKG_BUILD_TYPE)
            set(includedir [[${prefix}/../include]])
            configure_file("${SOURCE_PATH}/libcerror.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libcerror.pc" @ONLY)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libcerror.pc" " -lcerror" " -llibcerror")
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
        # Don't use system lib
        --with-libfuse=no
        # "no" means: use vendored libyal lib
        --with-libbfio=no
        --with-libcdata=no
        --with-libcerror=no
        --with-libcfile=no
        --with-libclocale=no
        --with-libcnotify=no
        --with-libcpath=no
        --with-libcsplit=no
        --with-libcthreads=no
        --with-libfcache=no
        --with-libfdata=no
        --with-libfguid=no
        --with-libuna=no
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

endif()

file(INSTALL "${CURRENT_PORT_DIR}/unofficial-libcerror-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libcerror")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${SOURCE_PATH}/include/libcerror/extern.h" "defined( LIBCERROR_DLL_IMPORT )" "1")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man3"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
