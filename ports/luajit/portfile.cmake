set(extra_patches "")
if (VCPKG_TARGET_IS_OSX)
	list(APPEND extra_patches 005-do-not-pass-ld-e-macosx.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuaJIT/LuaJIT
    REF d0e88930ddde28ff662503f9f20facf34f7265aa  #2023-01-04
    SHA512 e4111b2d7eeb05676c62d69da13a380a51d98f082c0be575a414c09ee27ff17d101b5b4a95e1b8a1bad14d55a4d2b305718a11878fbf36e0d3d48e62ba03407f
    HEAD_REF master
    PATCHES
        msvcbuild.patch
        003-do-not-set-macosx-deployment-target.patch
        ${extra_patches}
)

vcpkg_list(SET options)
if(VCPKG_CROSSCOMPILING)
    list(APPEND options "LJARCH=${VCPKG_TARGET_ARCHITECTURE}")
    vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(PKGCONFIG_CFLAGS "")
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND options "MSVCBUILD_OPTIONS=static")
    else()
        set(PKGCONFIG_CFLAGS "/DLUA_BUILD_AS_DLL=1")
    endif()

    vcpkg_install_nmake(SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_NAME "${CMAKE_CURRENT_LIST_DIR}/Makefile.nmake"
        OPTIONS
            ${options}
    )

    configure_file("${CMAKE_CURRENT_LIST_DIR}/luajit.pc.win.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/luajit.pc" @ONLY)
    if(NOT VCPKG_BUILD_TYPE)
        configure_file("${CMAKE_CURRENT_LIST_DIR}/luajit.pc.win.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/luajit.pc" @ONLY)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/manual-tools")
    endif()

    vcpkg_copy_pdbs()

    file(INSTALL "${SOURCE_PATH}/src/lua.h"      DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
    file(INSTALL "${SOURCE_PATH}/src/luajit.h"   DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
    file(INSTALL "${SOURCE_PATH}/src/luaconf.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
    file(INSTALL "${SOURCE_PATH}/src/lualib.h"   DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
    file(INSTALL "${SOURCE_PATH}/src/lauxlib.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
    file(INSTALL "${SOURCE_PATH}/src/lua.hpp"    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
else()
    vcpkg_list(SET make_options "EXECUTABLE_SUFFIX=${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if(VCPKG_TARGET_IS_OSX)
        vcpkg_list(APPEND make_options "TARGET_SYS=Darwin")
        vcpkg_list(APPEND make_options "MACOSX_DEPLOYMENT_TARGET=${VCPKG_OSX_DEPLOYMENT_TARGET}")
        set(TARGET_ARCHITECTURE "${VCPKG_TARGET_ARCHITECTURE}")
        if(TARGET_ARCHITECTURE STREQUAL "x64")
            set(TARGET_ARCHITECTURE x86_64)
        endif()
        vcpkg_list(APPEND make_options "TARGET_CFLAGS=--target=${TARGET_ARCHITECTURE}-apple-darwin")
        vcpkg_list(APPEND make_options "TARGET_LDFLAGS=--target=${TARGET_ARCHITECTURE}-apple-darwin")
    elseif(VCPKG_TARGET_IS_IOS)
        vcpkg_list(APPEND make_options "TARGET_SYS=iOS")
    elseif(VCPKG_TARGET_IS_LINUX)
        vcpkg_list(APPEND make_options "TARGET_SYS=Linux")
    elseif(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_list(APPEND make_options "TARGET_SYS=Windows")
    endif()

    file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        OPTIONS
            "BUILDMODE=${VCPKG_LIBRARY_LINKAGE}"
            ${options}
    )
    vcpkg_install_make(
        MAKEFILE "Makefile.vcpkg"
        OPTIONS
            ${make_options}
    )
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/lib/lua"
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/lib/lua"
        "${CURRENT_PACKAGES_DIR}/share/lua"
        "${CURRENT_PACKAGES_DIR}/share/man"
    )
endif()

vcpkg_copy_tools(TOOL_NAMES luajit AUTO_CLEAN)

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
