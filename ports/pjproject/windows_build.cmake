function(build_windows_msvc)
    if("video" IN_LIST FEATURES)
        file(COPY "${CURRENT_INSTALLED_DIR}/include/SDL2/"
             DESTINATION "${CURRENT_INSTALLED_DIR}/include/")
    endif()

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

    get_dependency_requires_private(PJ_REQUIRES_PRIVATE)

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

        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(ARCH_PART "x86_64-x64")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(ARCH_PART "i386-Win32")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(ARCH_PART "ARM64-arm64")
        else()
            message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
        endif()

        set(PJ_INSTALL_LDFLAGS "-lpjproject-${ARCH_PART}-vc14-${CONFIG_SUFFIX}-Static")

        configure_file("${CMAKE_CURRENT_LIST_DIR}/libpjproject.pc.in" "${PKG_PATH}" @ONLY)
    endforeach()
endfunction()

function(get_dependency_requires_private OUTPUT_VAR)
    set(DEPENDENCY_MODULES "")

    if("ssl" IN_LIST FEATURES)
        list(APPEND DEPENDENCY_MODULES "openssl")
    endif()

    if("opus" IN_LIST FEATURES)
        list(APPEND DEPENDENCY_MODULES "opus")
    endif()

    if("video" IN_LIST FEATURES)
        list(APPEND DEPENDENCY_MODULES "libavcodec" "libavformat" "libswscale" "vpx" "sdl2")
    endif()

    if(DEPENDENCY_MODULES)
        x_vcpkg_pkgconfig_get_modules(
            PREFIX pjproject_deps
            MODULES ${DEPENDENCY_MODULES}
            LIBS_VAR DEPS_LIBS
            CFLAGS_VAR DEPS_CFLAGS
        )

        string(REPLACE ";" " " REQUIRES_PRIVATE_STR "${DEPENDENCY_MODULES}")
        set(${OUTPUT_VAR} "${REQUIRES_PRIVATE_STR}" PARENT_SCOPE)
    else()
        set(${OUTPUT_VAR} "" PARENT_SCOPE)
    endif()
endfunction()