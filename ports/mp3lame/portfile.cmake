if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  message(FATAL_ERROR "mp3lame does not support ARM")
endif()

include(vcpkg_common_functions)

set(VERSION 3.100)

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://downloads.sourceforge.net/project/lame/lame/${VERSION}/lame-${VERSION}.tar.gz"
    FILENAME "lame-3.100.tar.gz"
    SHA512 0844b9eadb4aacf8000444621451277de365041cc1d97b7f7a589da0b7a23899310afd4e4d81114b9912aa97832621d20588034715573d417b2923948c08634b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE_FILE}
    REF ${VERSION}
    PATCHES 00001-msvc-upgrade-solution-up-to-vc11.patch
)

if(VCPKG_TARGET_IS_WINDOWS)

    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(GLOB vcxprojs ${SOURCE_PATH}/vc_solution/vc11_*.vcxproj)
        foreach(vcxproj ${vcxprojs})
            file(READ ${vcxproj} vcxproj_orig)
            string(REPLACE 
                "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>" 
                "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>" 
                vcxproj_orig "${vcxproj_orig}"
            )
            string(REPLACE 
                "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>" 
                "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>" 
                vcxproj_orig "${vcxproj_orig}"
            )
            file(WRITE ${vcxproj} "${vcxproj_orig}")
        endforeach()
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH "vc_solution/vc11_lame.sln"
        TARGET "lame"
        RELEASE_CONFIGURATION ${RELEASE_CONFIGURATION}
        DEBUG_CONFIGURATION ${DEBUG_CONFIGURATION}
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
            file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libmp3lame.lib)
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
            file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libmp3lame.lib)
        endif()
        set(MP3LAME_LIB "libmp3lame-static.lib")
    else()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libmp3lame-static.lib)
            file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libmpghip-static.lib)
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libmp3lame-static.lib)
            file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libmpghip-static.lib)
        endif()
        set(MP3LAME_LIB "libmp3lame.lib")
    endif()

else()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(OPTIONS --enable-static=yes --enable-shared=no)
        set(MP3LAME_LIB "libmp3lame.a")
    else()
        set(OPTIONS --enable-shared=yes --enable-static=no)
        set(MP3LAME_LIB "libmp3lame.so")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        vcpkg_execute_required_process(
            COMMAND ${SOURCE_PATH}/configure ${OPTIONS} --with-pic=yes --prefix=${CURRENT_PACKAGES_DIR}/debug
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME configure-${TARGET_TRIPLET}-dbg
        )
        message(STATUS "Building ${TARGET_TRIPLET}-dbg")
        vcpkg_execute_required_process(
            COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME install-${TARGET_TRIPLET}-dbg
        )

        file(REMOVE_RECURSE 
            ${CURRENT_PACKAGES_DIR}/debug/bin
            ${CURRENT_PACKAGES_DIR}/debug/include 
            ${CURRENT_PACKAGES_DIR}/debug/share
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND ${SOURCE_PATH}/configure ${OPTIONS} --with-pic=yes --prefix=${CURRENT_PACKAGES_DIR}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME configure-${TARGET_TRIPLET}-rel
        )

        message(STATUS "Building ${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME install-${TARGET_TRIPLET}-rel
        )

        if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
            file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
        endif()

    endif()

endif()

file(COPY ${SOURCE_PATH}/include/lame.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/lame)
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/mp3lame/copyright COPYONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in ${CURRENT_PACKAGES_DIR}/share/mp3lame/mp3lame-config.cmake @ONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/mp3lame)
