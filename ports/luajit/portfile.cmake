if (VCPKG_TARGET_IS_OSX)
	set (LJIT_PATCHES 005-do-not-pass-ld-e-macosx.patch)
else()
	set (LJIT_PATCHES "")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuaJIT/LuaJIT
    REF d0e88930ddde28ff662503f9f20facf34f7265aa  #2023-01-04
    SHA512 e4111b2d7eeb05676c62d69da13a380a51d98f082c0be575a414c09ee27ff17d101b5b4a95e1b8a1bad14d55a4d2b305718a11878fbf36e0d3d48e62ba03407f
    HEAD_REF master
    PATCHES
        003-do-not-set-macosx-deployment-target.patch
        004-fix-build-path-and-crt-linkage.patch
        ${LJIT_PATCHES}
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set (LJIT_STATIC "")
    set (LJIT_MSVC_PC_CFLAGS "/DLUA_BUILD_AS_DLL=1")
else()
    set (LJIT_STATIC "static")
    set (LJIT_MSVC_PC_CFLAGS "")
endif()

if(VCPKG_TARGET_IS_OSX)
    set(MACOSX_DEPLOYMENT_TARGET "MACOSX_DEPLOYMENT_TARGET=${VCPKG_OSX_DEPLOYMENT_TARGET}")
    set(TARGET_ARCHITECTURE "${VCPKG_TARGET_ARCHITECTURE}")
    if(TARGET_ARCHITECTURE STREQUAL x64)
        set(TARGET_ARCHITECTURE x86_64)
    endif()
    list(APPEND MACOSX_ARCHITECTURES "TARGET_CFLAGS=--target=${TARGET_ARCHITECTURE}-apple-darwin")
    list(APPEND MACOSX_ARCHITECTURES "TARGET_LDFLAGS=--target=${TARGET_ARCHITECTURE}-apple-darwin")
endif()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_execute_required_process_repeat(
            COUNT 1
            COMMAND "${SOURCE_PATH}/src/msvcbuild.bat" ${SOURCE_PATH}/src ${VCPKG_CRT_LINKAGE} debug ${LJIT_STATIC}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            LOGNAME build-${TARGET_TRIPLET}-dbg
        )

        # Note that luajit's build system responds to failure by producing no output; in particular a likely outcome is
        # only 'minilua.exe' being produced. This resulted in:
        # https://github.com/microsoft/vcpkg/pull/25856#issuecomment-1214285736
        # Please ensure luajit.exe is actually produced when making future changes.
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/luajit.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lua51.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        set(LJIT_LIBDIR "debug/lib")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/luajit.pc.win.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/luajit.pc" @ONLY)

        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lua51.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(COPY "${CURRENT_PACKAGES_DIR}/debug/bin/lua51.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools")
        endif()
        vcpkg_copy_pdbs()
    else()
        vcpkg_execute_build_process(
            COMMAND make -j${VCPKG_CONCURRENCY} -f ${SOURCE_PATH}/Makefile ${MACOSX_DEPLOYMENT_TARGET} clean
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME clean-${TARGET_TRIPLET}-debug
        )
        vcpkg_execute_build_process(
            COMMAND make -j${VCPKG_CONCURRENCY} -f ${SOURCE_PATH}/Makefile ${MACOSX_DEPLOYMENT_TARGET} ${MACOSX_ARCHITECTURES} PREFIX=${CURRENT_PACKAGES_DIR}/debug CCDEBUG=-g3 CFLAGS=-O0 BUILDMODE=${VCPKG_LIBRARY_LINKAGE} install
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME build-${TARGET_TRIPLET}-debug
        )
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/lua")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/luajit.pc" "multilib=lib" "multilib=debug/lib")
    endif()
endif()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

    if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_execute_required_process_repeat(
            COUNT 1
            COMMAND "${SOURCE_PATH}/src/msvcbuild.bat" ${SOURCE_PATH}/src ${VCPKG_CRT_LINKAGE} ${LJIT_STATIC}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            LOGNAME build-${TARGET_TRIPLET}-rel
        )

        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/luajit.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lua51.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        set(LJIT_LIBDIR "lib")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/luajit.pc.win.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/luajit.pc" @ONLY)

        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lua51.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
            vcpkg_copy_tools(TOOL_NAMES luajit SEARCH_DIR ${CURRENT_PACKAGES_DIR}/tools AUTO_CLEAN)
        endif()
        vcpkg_copy_pdbs()
    else()
        vcpkg_execute_build_process(
            COMMAND make -j${VCPKG_CONCURRENCY} -f ${SOURCE_PATH}/Makefile ${MACOSX_DEPLOYMENT_TARGET} clean
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME clean-${TARGET_TRIPLET}-rel
        )
        vcpkg_execute_build_process(
            COMMAND make -j${VCPKG_CONCURRENCY} -f ${SOURCE_PATH}/Makefile ${MACOSX_DEPLOYMENT_TARGET} ${MACOSX_ARCHITECTURES} PREFIX=${CURRENT_PACKAGES_DIR} CCDEBUG= BUILDMODE=${VCPKG_LIBRARY_LINKAGE} install
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME build-${TARGET_TRIPLET}-rel
        )
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/lua" "${CURRENT_PACKAGES_DIR}/lib/lua")
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/src/lua.h"      DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(INSTALL "${SOURCE_PATH}/src/luajit.h"   DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(INSTALL "${SOURCE_PATH}/src/luaconf.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(INSTALL "${SOURCE_PATH}/src/lualib.h"   DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(INSTALL "${SOURCE_PATH}/src/lauxlib.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(INSTALL "${SOURCE_PATH}/src/lua.hpp"    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
