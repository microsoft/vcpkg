vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuaJIT/LuaJIT
    REF v2.0.5
    SHA512 65d982d7fe532a61335613f414f3b8fa5333747bdf7aefc2c2d52022d227594ade827639049b97e3c4ffae9f38f32cb15f1a17b1780fb0a943e1a3af05e2b576
    HEAD_REF master
    PATCHES
        001-fix-build-path.patch
        002-fix-crt-linkage.patch
        003-do-not-set-macosx-deployment-target.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set (LJIT_STATIC "")
else()
    set (LJIT_STATIC "static")
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

        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/luajit.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lua51.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lua51.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(COPY "${CURRENT_PACKAGES_DIR}/debug/bin/lua51.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools")
        endif()
        vcpkg_copy_pdbs()
    else()
        vcpkg_execute_build_process(
            COMMAND make -j${VCPKG_CONCURRENCY} -f ${SOURCE_PATH}/Makefile clean
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME clean-${TARGET_TRIPLET}-debug
        )
        vcpkg_execute_build_process(
            COMMAND make -j${VCPKG_CONCURRENCY} -f ${SOURCE_PATH}/Makefile PREFIX=${CURRENT_PACKAGES_DIR}/debug CCDEBUG=-g3 CFLAGS=-O0 BUILDMODE=${VCPKG_LIBRARY_LINKAGE} install
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME build-${TARGET_TRIPLET}-debug
        )
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/lua")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
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

        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lua51.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
            vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools)
        endif()
        vcpkg_copy_pdbs()
    else()
        vcpkg_execute_build_process(
            COMMAND make -j${VCPKG_CONCURRENCY} -f ${SOURCE_PATH}/Makefile clean
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME clean-${TARGET_TRIPLET}-rel
        )
        vcpkg_execute_build_process(
            COMMAND make -j${VCPKG_CONCURRENCY} -f ${SOURCE_PATH}/Makefile PREFIX=${CURRENT_PACKAGES_DIR} CCDEBUG= BUILDMODE=${VCPKG_LIBRARY_LINKAGE} install
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
