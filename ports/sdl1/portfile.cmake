vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SDL-Mirror/SDL
    REF release-1.2.15
    SHA512 38b94a650ec205377ae1503d0ec8a5254ef6d50ed0acac8d985b57b64bc16ea042cfa41e19e5ef8317980c4afb83186829f5bc3da9433d0a649dfd10554801b5
    HEAD_REF master
    PATCHES
        export-symbols-only-in-shared-build.patch
        fix-linux-build.patch
)

configure_file(${SOURCE_PATH}/include/SDL_config.h.default ${SOURCE_PATH}/include/SDL_config.h COPYONLY)


if (VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/SDL1_2017.sln DESTINATION ${SOURCE_PATH}/VisualC/ )
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/SDL_static.vcxproj DESTINATION ${SOURCE_PATH}/VisualC/SDL RENAME SDL.vcxproj)
        file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/SDLmain_static.vcxproj DESTINATION ${SOURCE_PATH}/VisualC/SDLmain RENAME SDLmain.vcxproj)
    else()
        file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/SDL_dynamic.vcxproj DESTINATION ${SOURCE_PATH}/VisualC/SDL RENAME SDL.vcxproj)
        file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/SDLmain_dynamic.vcxproj DESTINATION ${SOURCE_PATH}/VisualC/SDLmain RENAME SDLmain.vcxproj)
    endif()
    
    # This text file gets copied as a library, and included as one in the package 
    file(REMOVE_RECURSE ${SOURCE_PATH}/src/hermes/COPYING.LIB)
    
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH VisualC/SDL1_2017.sln
        INCLUDES_SUBPATH include
        LICENSE_SUBPATH COPYING
        ALLOW_ROOT_INCLUDES
    )
    
    #Take all the fils into include/SDL to sovle conflict with SDL2 port
    file(GLOB files ${CURRENT_PACKAGES_DIR}/include/*)
    foreach(file ${files})
            file(COPY ${file} DESTINATION ${CURRENT_PACKAGES_DIR}/include/SDL)
            file(REMOVE ${file})
    endforeach()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/SDL/doxyfile)
    
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/SDLmain.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/SDLmain.lib)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/SDLmain.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/SDLmaind.lib)
    endif()
else()
    message("libgles2-mesa-dev must be installed before sdl1 can build. Install them with \"apt install libgles2-mesa-dev\".")
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(BUILD_SHARED yes)
        set(BUILD_STATIC no)
    else()
        set(BUILD_SHARED no)
        set(BUILD_STATIC yes)
    endif()

    file(REMOVE_RECURSE ${SOURCE_PATH}/m4)
    file(MAKE_DIRECTORY ${SOURCE_PATH}/m4)
    
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        NO_DEBUG
        PRERUN_SHELL autogen.sh
        OPTIONS
            --enable-shared=${BUILD_SHARED}
            --enable-static=${BUILD_STATIC}
    )
    
    vcpkg_install_make()
    
    file(GLOB SDL1_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*")
    foreach (SDL1_TOOL ${SDL1_TOOLS})
        file(COPY ${SDL1_TOOL} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
        file(REMOVE ${SDL1_TOOL})
    endforeach()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    
    file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endif()