include(vcpkg_common_functions)

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
    find_program(autoreconf autoreconf)
    if (NOT autoreconf OR NOT EXISTS "/usr/share/doc/libgles2/copyright")
        message(FATAL_ERROR "autoreconf and libgles2-mesa-dev must be installed before libepoxy can build. Install them with \"apt-get dh-autoreconf libgles2-mesa-dev\".")
    endif()
    
    find_program(MAKE make)
    if (NOT MAKE)
        message(FATAL_ERROR "MAKE not found")
    endif()

    file(REMOVE_RECURSE ${SOURCE_PATH}/m4)
    file(MAKE_DIRECTORY ${SOURCE_PATH}/m4)
    
    vcpkg_execute_required_process(
        COMMAND "./autogen.sh"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME autoreconf-${TARGET_TRIPLET}
    )
    
    message(STATUS "Configuring ${TARGET_TRIPLET}")
    set(OUT_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/make-build-${TARGET_TRIPLET}-release)
    
    file(REMOVE_RECURSE ${OUT_PATH_RELEASE})
    file(MAKE_DIRECTORY ${OUT_PATH_RELEASE})
    
    vcpkg_execute_required_process(
        COMMAND "./configure" --prefix=${OUT_PATH_RELEASE}
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME config-${TARGET_TRIPLET}
    )
    
    message(STATUS "Building ${TARGET_TRIPLET}")
    vcpkg_execute_build_process(
        COMMAND "make -j ${VCPKG_CONCURRENCY}"
        NO_PARALLEL_COMMAND "make"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "build-${TARGET_TRIPLET}-release"
    )
    
    message(STATUS "Installing ${TARGET_TRIPLET}")
    vcpkg_execute_required_process(
        COMMAND "make install"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "install-${TARGET_TRIPLET}-release"
    )
    
    file(INSTALL ${OUT_PATH_RELEASE}/include DESTINATION ${CURRENT_PACKAGES_DIR})
    file(INSTALL ${OUT_PATH_RELEASE}/lib DESTINATION ${CURRENT_PACKAGES_DIR})
    file(INSTALL ${OUT_PATH_RELEASE}/share DESTINATION ${CURRENT_PACKAGES_DIR})
    
    file(GLOB DYNAMIC_LIBS ${CURRENT_PACKAGES_DIR}/lib *.so*)
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(COPY ${DYNAMIC_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    endif()
    file(REMOVE ${DYNAMIC_LIBS})
    
    file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endif()