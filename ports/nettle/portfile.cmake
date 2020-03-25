## requires AUTOCONF, LIBTOOL and PKCONF


if(VCPKG_TARGET_IS_WINDOWS)
    #vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 
    #set(OPTIONS --disable-assembler)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "----- ${PORT} requires Visual Studio YASM integration which can be downloaded from https://github.com/ShiftMediaProject/VSYASM/releases/latest -----")
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ShiftMediaProject/nettle
        REF 1d0a6e64e01458fdf37eaf5d90975deb52c3da41 #v3.5.1 
        SHA512 6124fbd223e6519d88290c3f4e3b8cc399e038c9c77cfec38e6ab17b075846e662fd0360d62c132c882536489c8a865795f64059e2d2b21467f65d90320e5c39
        HEAD_REF master
        PATCHES gmp.patch
                name.dir.patch
    )
    vcpkg_find_acquire_program(YASM)
    get_filename_component(YASM_DIR "${YASM}" DIRECTORY)
    vcpkg_add_to_path(${YASM_DIR})
    if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
        set(PLATFORM "Win32")
    else ()
        set(PLATFORM ${TRIPLET_SYSTEM_ARCH})
    endif()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(CONFIGURATION_RELEASE ReleaseDLL)
        set(CONFIGURATION_DEBUG DebugDLL)
    else()
        set(CONFIGURATION_RELEASE Release)
        set(CONFIGURATION_DEBUG Debug)
    endif()

    if(VCPKG_TARGET_IS_UWP)
        string(APPEND CONFIGURATION_RELEASE WinRT)
        string(APPEND CONFIGURATION_DEBUG WinRT)
    endif()
    
    vcpkg_install_msbuild(
        USE_VCPKG_INTEGRATION
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH SMP/libnettle.sln
        PLATFORM ${PLATFORM}
        LICENSE_SUBPATH COPYING.LESSERv3
        TARGET Rebuild
        RELEASE_CONFIGURATION ${CONFIGURATION_RELEASE}
        DEBUG_CONFIGURATION ${CONFIGURATION_DEBUG}
        SKIP_CLEAN
    )

    get_filename_component(SOURCE_PATH_SUFFIX "${SOURCE_PATH}" NAME)
    file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX}/msvc/include" "${CURRENT_PACKAGES_DIR}/include")
    set(PACKAGE_VERSION 3.5.1)
    set(prefix "${CURRENT_INSTALLED_DIR}")
    set(exec_prefix "\${prefix}")
    set(libdir "\${prefix}/lib")
    set(includedir "\${prefix}/include")
    set(LIBS -lnettle -lgmp)
    configure_file("${SOURCE_PATH}/nettle.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/nettle.pc" @ONLY)
    set(HOGWEED -lhogweed)
    set(LIBS -lnettle)
    configure_file("${SOURCE_PATH}/hogweed.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libhogweed.pc" @ONLY)
    set(prefix "${CURRENT_INSTALLED_DIR}/debug")
    set(exec_prefix "\${prefix}")
    set(libdir "\${prefix}/lib")
    set(includedir "\${prefix}/../include")
    set(LIBS -lnettled -lgmpd)
    configure_file("${SOURCE_PATH}/nettle.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/nettle.pc" @ONLY)
    set(LIBS -lnettled)
    set(HOGWEED -lhogweedd)
    configure_file("${SOURCE_PATH}/hogweed.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libhogweed.pc" @ONLY)
    vcpkg_fixup_pkgconfig()
else()
    message(STATUS "----- ${PORT} requires autoconf, libtool and pkconf from the system package manager! \n ----- sudo apt-get install autogen autoconf libtool-----")
    vcpkg_find_acquire_program(YASM)
    get_filename_component(YASM_DIR "${YASM}" DIRECTORY)
    vcpkg_add_to_path(${YASM_DIR})
    vcpkg_from_gitlab(
        GITLAB_URL https://git.lysator.liu.se/
        OUT_SOURCE_PATH SOURCE_PATH
        REPO nettle/nettle
        REF  ee5d62898cf070f08beedc410a8d7c418588bd95 #v3.5.1 
        SHA512 881912548f4abb21460f44334de11439749c8a055830849a8beb4332071d11d9196d9eecaeba5bf822819d242356083fba91eb8719a64f90e41766826e6d75e1
        HEAD_REF master # branch name
        #PATCHES example.patch #patch name
    ) 
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        #SKIP_CONFIGURE
        #NO_DEBUG
        #AUTO_HOST
        #AUTO_DST
        #PRERUN_SHELL ${SHELL_PATH}
        OPTIONS
            --disable-documentation
            ${OPTIONS}
        #OPTIONS_DEBUG
        #OPTIONS_RELEASE
    )

    vcpkg_install_make()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    # # Handle copyright
    
    file(INSTALL "${SOURCE_PATH}/COPYINGv3" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
    # # Post-build test for cmake libraries
    # vcpkg_test_cmake(PACKAGE_NAME Xlib)

    set(TOOLS nettle-hash nettle-lfib-stream nettle-pbkdf2 sexp-conv)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    foreach(tool ${TOOLS})
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    endforeach()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR VCPKG_TARGET_IS_LINUX)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()


