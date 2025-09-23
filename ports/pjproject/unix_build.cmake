function(build_unix)
    setup_unix_environment()

    build_unix_configure_options(CONFIGURE_OPTIONS)

    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        OPTIONS ${CONFIGURE_OPTIONS}
    )
    
    vcpkg_make_install(
        TARGETS "dep" "lib" "install"
        OPTIONS
            "LD=\\$\\(CXX\\)"
            "CXXLD=\\$\\(CXX\\)"
    )
endfunction()

function(setup_unix_environment)
    if("video" IN_LIST FEATURES)
        create_sdl2_config_shim()
    endif()

    if(VCPKG_TARGET_IS_MINGW)
        setup_mingw_environment()
    endif()
endfunction()

function(create_sdl2_config_shim)
    set(SHIMDIR "${CURRENT_BUILDTREES_DIR}/sdl2-config-shim")
    file(MAKE_DIRECTORY "${SHIMDIR}")
    
    set(SHIM "${SHIMDIR}/sdl2-config")
    file(WRITE "${SHIM}" [=[
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
    
    file(CHMOD "${SHIM}" 
         PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ WORLD_READ)
    
    set(ENV{SDL_CONFIG} "${SHIM}")
    set(ENV{PATH} "${SHIMDIR}:$ENV{PATH}")
endfunction()

function(setup_mingw_environment)
    set(MINGW_LIBS "")
    
    if("ssl" IN_LIST FEATURES)
        string(APPEND MINGW_LIBS "-lssl -lcrypto -lcrypt32 -lncrypt ")
    endif()
    
    if(MINGW_LIBS)
        set(ENV{LIBS} "${MINGW_LIBS}")
    endif()
endfunction()

function(build_unix_configure_options OUTPUT_VAR)
    set(OPTIONS)

    set(FEATURE_OPTIONS
        "ssl:--with-ssl=${CURRENT_INSTALLED_DIR}"
        "opus:--with-opus=${CURRENT_INSTALLED_DIR}"
        "video:--with-vpx=${CURRENT_INSTALLED_DIR}"
        "video:--with-sdl=${CURRENT_INSTALLED_DIR}"
        "video:--with-ffmpeg=${CURRENT_INSTALLED_DIR}"
        "video:--enable-video"
    )
    
    foreach(FEATURE_OPTION ${FEATURE_OPTIONS})
        string(REPLACE ":" ";" FEATURE_OPTION_LIST "${FEATURE_OPTION}")
        list(GET FEATURE_OPTION_LIST 0 FEATURE)
        list(GET FEATURE_OPTION_LIST 1 OPTION)
        
        if("${FEATURE}" IN_LIST FEATURES)
            list(APPEND OPTIONS "${OPTION}")
        endif()
    endforeach()

    list(REMOVE_DUPLICATES OPTIONS)
    
    set(${OUTPUT_VAR} ${OPTIONS} PARENT_SCOPE)
endfunction()