if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pjsip/pjproject
    REF "${VERSION}"
    SHA512 2f83ed32f16c27808d3b9cc8f3b364c68fe88caae9765012b385a0fea70ba8ef4dcfebe3b130156047546720351a527e17d6a1e967877d6a44a6ff3a1f695599
    PATCHES
        add-required-windows-libs.patch
)

file(MAKE_DIRECTORY "${SOURCE_PATH}/pjlib/include/pj")
file(WRITE "${SOURCE_PATH}/pjlib/include/pj/config_site.h" [=[
#ifndef PJ_CONFIG_SITE_H
#define PJ_CONFIG_SITE_H

#define PJ_HAS_SSL_SOCK                    1
#define PJSUA_HAS_VIDEO                    1
#define PJMEDIA_HAS_VIDEO                  1
#define PJMEDIA_HAS_FFMPEG                 1
#define PJMEDIA_HAS_OPUS_CODEC             1
#define PJMEDIA_HAS_VPX_CODEC              1
#define PJMEDIA_HAS_VPX_CODEC_VP9          1
#define PJMEDIA_VIDEO_DEV_HAS_SDL          1

#ifdef _MSC_VER
    #define PJMEDIA_VIDEO_DEV_HAS_DSHOW    1
#else
    #define PJMEDIA_VIDEO_DEV_HAS_DSHOW    0    
#endif

#ifdef _WIN32
    #define PJ_HAS_WINDOWS_H               1
    #define PJ_WIN32_WINCE                 0
#endif

#endif /* PJ_CONFIG_SITE_H */
]=])

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string(
        "${SOURCE_PATH}/pjmedia/src/pjmedia-codec/opus.c"
        "#    pragma comment(lib, \"libopus.a\")"
        "#    pragma comment(lib, \"opus.lib\")"
    )

    vcpkg_replace_string(
        "${SOURCE_PATH}/pjmedia/src/pjmedia-videodev/sdl_dev.c"
        "#       pragma comment( lib, \"sdl2.lib\")"
        "// #       pragma comment( lib, \"sdl2.lib\") // Disabled for vcpkg - SDL2 is linked via pkg-config"
    )

    file(COPY "${CURRENT_INSTALLED_DIR}/include/SDL2/" DESTINATION "${CURRENT_INSTALLED_DIR}/include/")

    set(CONFIGURATION_RELEASE Release-Static)
    set(CONFIGURATION_DEBUG Debug-Static)

    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(RuntimeLibraryExt "")
    else()
        set(RuntimeLibraryExt "DLL")
    endif()

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "pjsip-apps/build/libpjproject.vcxproj"
        PLATFORM ${VCPKG_TARGET_ARCHITECTURE}
        RELEASE_CONFIGURATION ${CONFIGURATION_RELEASE}
        DEBUG_CONFIGURATION ${CONFIGURATION_DEBUG}
        OPTIONS_RELEASE "/p:RuntimeLibrary=MultiThreaded${RuntimeLibraryExt}"
        OPTIONS_DEBUG "/p:RuntimeLibrary=MultiThreadedDebug${RuntimeLibraryExt}"
    )

    file(INSTALL "${SOURCE_PATH}/pjlib/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL "${SOURCE_PATH}/pjlib-util/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL "${SOURCE_PATH}/pjnath/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL "${SOURCE_PATH}/pjmedia/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL "${SOURCE_PATH}/pjsip/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

    set(PREFIX "\${pcfiledir}/../..")
    set(LIBDIR "\${prefix}/lib")
    set(INCLUDEDIR "\${prefix}/include") 
    set(PJ_VERSION "${VERSION}")

    set(PJ_INSTALL_LDFLAGS "-lpjproject-x86_64-x64-vc14-Release-Static")
    set(PJ_INSTALL_LDFLAGS_PRIVATE "-lversion -lsetupapi -lmfuuid -lbcrypt -lcfgmgr32 -limm32 -lswresample -lswscale -lavformat -lavcodec -lavutil -lavdevice -lavfilter -lopus -lcrypto -lssl -lvpx -lSDL2 -lws2_32 -lole32 -loleaut32 -luuid -lodbc32 -lodbccp32 -lwinmm -ldsound -lstrmiids -ldxguid -lquartz")
    set(PJ_INSTALL_CFLAGS "-I\${includedir}")
    configure_file("${SOURCE_PATH}/libpjproject.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpjproject.pc" @ONLY)

    if(NOT VCPKG_BUILD_TYPE)
        set(LIBDIR "\${prefix}/debug/lib")
        set(INCLUDEDIR "\${prefix}/include")
        set(PJ_INSTALL_LDFLAGS "-lpjproject-x86_64-x64-vc14-Debug-Static")
        configure_file("${SOURCE_PATH}/libpjproject.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpjproject.pc" @ONLY)
    endif()

    vcpkg_copy_pdbs()
else()
    set(ENV{PKG_CONFIG} "${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf")

    set(_shimdir "${CURRENT_BUILDTREES_DIR}/sdl2-config-shim")
    file(MAKE_DIRECTORY "${_shimdir}")
    set(_shim "${_shimdir}/sdl2-config")
    file(WRITE "${_shim}" [=[
    #!/usr/bin/env sh
    pc="${PKG_CONFIG:-pkg-config} sdl2"
    case "$1" in
    --cflags)      exec $pc --cflags ;;
    --libs)        exec $pc --libs ;;
    --static-libs) exec $pc --libs --static ;;
    --version)     exec $pc --modversion ;;
    --prefix)      exec $pc --variable=prefix ;;
    *)             exec $pc "$@" ;;
    esac
    ]=])
    file(CHMOD "${_shim}" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ WORLD_READ)

    set(ENV{SDL_CONFIG} "${_shim}")
    set(ENV{PATH} "${_shimdir}:$ENV{PATH}")

    if (VCPKG_TARGET_IS_MINGW)
        set(ENV{LIBS} "-lssl -lcrypto -lcrypt32 -lncrypt")
    endif()

    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        OPTIONS
            "--with-ssl=${CURRENT_INSTALLED_DIR}"
            "--with-opus=${CURRENT_INSTALLED_DIR}"
            "--with-vpx=${CURRENT_INSTALLED_DIR}"
            "--with-sdl=${CURRENT_INSTALLED_DIR}"
            "--with-ffmpeg=${CURRENT_INSTALLED_DIR}"
            "--enable-video"
    )

    vcpkg_make_install(
        TARGETS "dep" "lib" "install"
        OPTIONS
            "LD=\\$\\(CXX\\)" "CXXLD=\\$\\(CXX\\)"
    )
endif()

vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")