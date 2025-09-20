function(build_windows_msvc)
    apply_windows_patches()

    set(CONFIGURATION_RELEASE "Release-Static")
    set(CONFIGURATION_DEBUG "Debug-Static")
    
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

    install_headers()
    generate_windows_pkgconfig()
    vcpkg_copy_pdbs()
endfunction()

function(apply_windows_patches)
    if("opus" IN_LIST FEATURES)
        vcpkg_replace_string(
            "${SOURCE_PATH}/pjmedia/src/pjmedia-codec/opus.c"
            "#    pragma comment(lib, \"libopus.a\")"
            "#    pragma comment(lib, \"opus.lib\")"
        )
    endif()
    
    if("video" IN_LIST FEATURES)
        vcpkg_replace_string(
            "${SOURCE_PATH}/pjmedia/src/pjmedia-videodev/sdl_dev.c"
            "#       pragma comment( lib, \"sdl2.lib\")"
            "// #       pragma comment( lib, \"sdl2.lib\") // Disabled for vcpkg - SDL2 is linked via pkg-config"
        )

        file(COPY "${CURRENT_INSTALLED_DIR}/include/SDL2/" 
             DESTINATION "${CURRENT_INSTALLED_DIR}/include/")
    endif()
endfunction()

function(install_headers)
    set(HEADER_DIRS 
        "pjlib/include"
        "pjlib-util/include"
        "pjnath/include"
        "pjmedia/include"
        "pjsip/include"
    )
    
    foreach(HEADER_DIR ${HEADER_DIRS})
        file(INSTALL "${SOURCE_PATH}/${HEADER_DIR}/" 
             DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    endforeach()
endfunction()

function(generate_windows_pkgconfig)
    set(PREFIX "\${pcfiledir}/../..")
    set(PJ_VERSION "${VERSION}")
    set(PJ_INSTALL_CFLAGS "-I\${includedir}")

    set(CONFIGS "RELEASE")
    if(NOT VCPKG_BUILD_TYPE)
        list(APPEND CONFIGS "DEBUG")
    endif()
    
    foreach(CONFIG ${CONFIGS})
        if(CONFIG STREQUAL "DEBUG")
            set(LIBDIR "\${prefix}/debug/lib")
            set(CONFIG_SUFFIX "Debug")
            set(PKG_PATH "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpjproject.pc")
        else()
            set(LIBDIR "\${prefix}/lib")
            set(CONFIG_SUFFIX "Release")
            set(PKG_PATH "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpjproject.pc")
        endif()
        
        set(INCLUDEDIR "\${prefix}/include")
        set(PJ_INSTALL_LDFLAGS "-lpjproject-x86_64-x64-vc14-${CONFIG_SUFFIX}-Static")

        build_windows_ldflags_private(PJ_INSTALL_LDFLAGS_PRIVATE)

        configure_file("${SOURCE_PATH}/libpjproject.pc.in" "${PKG_PATH}" @ONLY)
    endforeach()
endfunction()

function(build_windows_ldflags_private OUTPUT_VAR)
    set(LIBS "version setupapi mfuuid bcrypt cfgmgr32 imm32 ws2_32 ole32 oleaut32 uuid odbc32 odbccp32 winmm")

    if("video" IN_LIST FEATURES)
        list(APPEND LIBS "swresample swscale avformat avcodec avutil avdevice avfilter vpx SDL2 dsound strmiids dxguid quartz")
    endif()
    
    if("ssl" IN_LIST FEATURES)
        list(APPEND LIBS "crypto ssl")
    endif()
    
    if("opus" IN_LIST FEATURES)
        list(APPEND LIBS "opus")
    endif()

    list(TRANSFORM LIBS PREPEND "-l")
    string(JOIN " " LDFLAGS_STRING ${LIBS})
    
    set(${OUTPUT_VAR} "${LDFLAGS_STRING}" PARENT_SCOPE)
endfunction()