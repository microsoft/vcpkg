set(VERSION 3.100)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lame/lame
    REF ${VERSION}
    FILENAME "lame-${VERSION}.tar.gz"
    SHA512 0844b9eadb4aacf8000444621451277de365041cc1d97b7f7a589da0b7a23899310afd4e4d81114b9912aa97832621d20588034715573d417b2923948c08634b
    PATCHES
        00001-msvc-upgrade-solution-up-to-vc11.patch
        remove_lame_init_old_from_symbol_list.patch # deprecated https://github.com/zlargon/lame/blob/master/include/lame.h#L169
        add-macos-universal-config.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(platform "ARM64")
        set(machine "ARM64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(platform "ARM")
        set(machine "ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(platform "x64")
        set(machine "x64")
    else()
        set(platform "Win32")
        set(machine "x86")
    endif()

    file(READ "${SOURCE_PATH}/vc_solution/vc11_lame.sln" sln_con)
    string(REPLACE "|Win32" "|${platform}" sln_con "${sln_con}")
    string(REPLACE "\"vc11_" "\"${machine}_vc11_" sln_con "${sln_con}")
    file(WRITE "${SOURCE_PATH}/vc_solution/${machine}_vc11_lame.sln" "${sln_con}")

    
    file(GLOB vcxprojs RELATIVE "${SOURCE_PATH}/vc_solution" "${SOURCE_PATH}/vc_solution/vc11_*.vcxproj")
    foreach(vcxproj ${vcxprojs})
        file(READ "${SOURCE_PATH}/vc_solution/${vcxproj}" vcxproj_con)
        
        if(NOT VCPKG_CRT_LINKAGE STREQUAL dynamic)
            string(REPLACE "DLL</RuntimeLibrary>" "</RuntimeLibrary>" vcxproj_con "${vcxproj_con}")
        endif()

        string(REPLACE "/machine:x86" "/machine:${machine}" vcxproj_con "${vcxproj_con}")
        string(REPLACE "<Platform>Win32</Platform>" "<Platform>${platform}</Platform>" vcxproj_con "${vcxproj_con}")
        string(REPLACE "|Win32" "|${platform}" vcxproj_con "${vcxproj_con}")
        string(REPLACE "Include=\"vc11_" "Include=\"${machine}_vc11_" vcxproj_con "${vcxproj_con}")
 
        if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
            string(REPLACE "/APPCONTAINER" "" vcxproj_con "${vcxproj_con}")
        endif()
        
        file(WRITE "${SOURCE_PATH}/vc_solution/${machine}_${vcxproj}" "${vcxproj_con}")
    endforeach()

    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "vc_solution/${machine}_vc11_lame.sln"
        TARGET "lame"
        PLATFORM "${platform}"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libmp3lame.lib")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libmp3lame.lib")
        endif()
        set(MP3LAME_LIB "libmp3lame-static.lib")
    else()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libmp3lame-static.lib")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libmpghip-static.lib")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libmp3lame-static.lib")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libmpghip-static.lib")
        endif()
        set(MP3LAME_LIB "libmp3lame.lib")
    endif()

else()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(OPTIONS --enable-static=yes --enable-shared=no)
        set(MP3LAME_LIB "libmp3lame${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    else()
        set(OPTIONS --enable-shared=yes --enable-static=no)
        if(VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX)
            set(MP3LAME_LIB "libmp3lame${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}")
        else()
            set(MP3LAME_LIB "libmp3lame${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
        endif()
    endif()

    if(NOT VCPKG_TARGET_IS_MINGW)
        string(APPEND OPTIONS --with-pic=yes)
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        DETERMINE_BUILD_TRIPLET
        OPTIONS ${OPTIONS}
    )

    vcpkg_install_make()
    file(REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/debug/include"
            "${CURRENT_PACKAGES_DIR}/debug/share"
        )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/doc" "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1")

file(COPY "${SOURCE_PATH}/include/lame.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/lame")
configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/mp3lame-config.cmake" @ONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
