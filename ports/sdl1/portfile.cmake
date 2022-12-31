vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SDL-Mirror/SDL
    REF release-1.2.15
    SHA512 38b94a650ec205377ae1503d0ec8a5254ef6d50ed0acac8d985b57b64bc16ea042cfa41e19e5ef8317980c4afb83186829f5bc3da9433d0a649dfd10554801b5
    HEAD_REF master
    PATCHES
        export-symbols-only-in-shared-build.patch
        fix-linux-build.patch
        sdl-config.patch
)

configure_file("${SOURCE_PATH}/include/SDL_config.h.default" "${SOURCE_PATH}/include/SDL_config.h" COPYONLY)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/SDL1_2017.sln" DESTINATION "${SOURCE_PATH}/VisualC/")
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(LIB_TYPE StaticLibrary)
    else()
        set(LIB_TYPE DynamicLibrary)
    endif()
    
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(CRT_TYPE_DBG MultiThreadedDebugDLL)
        set(CRT_TYPE_REL MultiThreadedDLL)
    else()
        set(CRT_TYPE_DBG MultiThreadedDebug)
        set(CRT_TYPE_REL MultiThreaded)
    endif()
    
    configure_file("${CURRENT_PORT_DIR}/SDL.vcxproj.in" "${SOURCE_PATH}/VisualC/SDL/SDL.vcxproj" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/SDLmain.vcxproj.in" "${SOURCE_PATH}/VisualC/SDLmain/SDLmain.vcxproj" @ONLY)
    
    # This text file gets copied as a library, and included as one in the package 
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/hermes/COPYING.LIB")
    
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH VisualC/SDL1_2017.sln
        INCLUDES_SUBPATH include
        LICENSE_SUBPATH COPYING
        ALLOW_ROOT_INCLUDES
    )
    
    #Take all the fils into include/SDL to sovle conflict with SDL2 port
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/doxyfile")
    file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include.tmp")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
    file(RENAME "${CURRENT_PACKAGES_DIR}/include.tmp" "${CURRENT_PACKAGES_DIR}/include/SDL")
    
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/SDLmain.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/SDLmain.lib")
    if(NOT DEFINED VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/SDLmain.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/SDLmaind.lib")
    endif()
else()
    if(VCPKG_TARGET_IS_LINUX)
        message("libgles2-mesa-dev must be installed before sdl1 can build. Install it with \"apt install libgles2-mesa-dev\".")
    endif()

    find_program(WHICH_COMMAND NAMES which)
    if(NOT WHICH_COMMAND)
        set(polyfill_scripts "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-bin")
        file(REMOVE_RECURSE "${polyfill_scripts}")
        file(MAKE_DIRECTORY "${polyfill_scripts}")
        vcpkg_host_path_list(APPEND ENV{PATH} "${polyfill_scripts}")
        # sdl's autoreconf.sh needs `which`, but our msys root doesn't have it.
        file(WRITE "${polyfill_scripts}/which" "#!/bin/sh\nif test -f \"/usr/bin/\$1\"; then echo \"/usr/bin/\$1\"; else false; fi\n")
        file(CHMOD "${polyfill_scripts}/which" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
    )
    
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/man3"
    )

    file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
