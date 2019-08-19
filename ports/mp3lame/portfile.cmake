if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  message(FATAL_ERROR "mp3lame does not support ARM")
endif()

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(FATAL_ERROR "mp3lame does not support UWP")
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
)

# template for mp3lameConfig.cmake
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in DESTINATION ${SOURCE_PATH} RENAME vcpkg_Config.cmake.in)

if(VCPKG_TARGET_IS_WINDOWS)
    # use vc11 solution instead ov vc9
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vc11 DESTINATION ${SOURCE_PATH} RENAME vcpkg_vc11)

    # should use "#include <lame/lame.h>" instead of "#include <lame.h>"
    file(INSTALL ${SOURCE_PATH}/include/lame.h DESTINATION ${SOURCE_PATH}/vcpkg_include/lame)

    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        # replace "<RuntimeLibrary>...</RuntimeLibrary>" to "<RuntimeLibrary>...DLL</RuntimeLibrary>" in vcxproj
        file(GLOB vcxprojs ${SOURCE_PATH}/vcpkg_vc11/*.vcxproj)
        foreach(vcxproj ${vcxprojs})
            file(READ ${vcxproj} vcxproj_orig)
            string(REPLACE "</RuntimeLibrary>" "DLL</RuntimeLibrary>" vcxproj_orig "${vcxproj_orig}")
            file(WRITE ${vcxproj} "${vcxproj_orig}")
        endforeach()
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH "vcpkg_vc11/vc11_lame.sln"
        TARGET "lame"
        RELEASE_CONFIGURATION ${RELEASE_CONFIGURATION}
        DEBUG_CONFIGURATION ${DEBUG_CONFIGURATION}
        LICENSE_SUBPATH ${SOURCE_PATH_SUFFIX}/COPYING
        INCLUDES_SUBPATH "vcpkg_include"
    )

    # remove redundant files
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

        # remove redundant files
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
            # remove redundant files
            file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
        endif()

        configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/mp3lame/copyright COPYONLY)
    endif()

endif()

configure_file(
    ${SOURCE_PATH}/vcpkg_Config.cmake.in 
    ${CURRENT_PACKAGES_DIR}/share/mp3lame/mp3lameConfig.cmake 
    @ONLY
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/mp3lame)
