set(VERSION 3.100)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lame/lame
    REF ${VERSION}
    FILENAME "lame-${VERSION}.tar.gz"
    SHA512 0844b9eadb4aacf8000444621451277de365041cc1d97b7f7a589da0b7a23899310afd4e4d81114b9912aa97832621d20588034715573d417b2923948c08634b
    PATCHES 00001-msvc-upgrade-solution-up-to-vc11.patch
)

if(VCPKG_TARGET_IS_WINDOWS)

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
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH "vc_solution/${machine}_vc11_lame.sln"
        TARGET "lame"
        PLATFORM "${platform}"
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
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in ${CURRENT_PACKAGES_DIR}/share/mp3lame/mp3lame-config.cmake @ONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
