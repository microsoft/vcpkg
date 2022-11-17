vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hunspell/hunspell
    REF v1.7.1
    SHA512 472249309aecbbc58a025445781268867173e0651a6147f29644975ad65af043a1e2fbe91f2094934526889c7f9944739dc0a5f0d25328a77d22db1fd8f055ec
    HEAD_REF master
    PATCHES
        0001_fix_unistd.patch
        0002-disable-test.patch
        0003-fix-win-build.patch
        0004-add-win-arm64.patch
        0005-autotools-subdirs.patch
)

file(REMOVE "${SOURCE_PATH}/README") #README is a symlink
configure_file("${SOURCE_PATH}/README.md" "${SOURCE_PATH}/README" COPYONLY)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    #architecture detection
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(HUNSPELL_ARCH Win32)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(HUNSPELL_ARCH x64)
     elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(HUNSPELL_ARCH ARM64)
    else()
        message(FATAL_ERROR "unsupported architecture")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(HUNSPELL_CONFIGURATION _dll)
    else()
        set(HUNSPELL_CONFIGURATION "")
    endif()

    if("tools" IN_LIST FEATURES)
        set(HSP_TARGET hunspell)
    else()
        set(HSP_TARGET libhunspell)
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "msvc/Hunspell.sln"
        INCLUDES_SUBPATH src/hunspell
        PLATFORM ${HUNSPELL_ARCH}
        RELEASE_CONFIGURATION Release${HUNSPELL_CONFIGURATION}
        DEBUG_CONFIGURATION Debug${HUNSPELL_CONFIGURATION}
        ALLOW_ROOT_INCLUDES
    )
    vcpkg_copy_pdbs()

    set(HUNSPELL_EXPORT_HDR "${CURRENT_PACKAGES_DIR}/include/hunvisapi.h")

else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(ENV{CFLAGS} "$ENV{CFLAGS} -DHUNSPELL_STATIC")
        set(ENV{CXXFLAGS} "$ENV{CXXFLAGS} -DHUNSPELL_STATIC")
    endif()
    vcpkg_list(SET options)
    if("tools" IN_LIST FEATURES)
        vcpkg_list(APPEND options "--enable-tools")
    endif()
    if("nls" IN_LIST FEATURES)
        vcpkg_list(APPEND options "--enable-nls")
    else()
        set(ENV{AUTOPOINT} true) # true, the program
        vcpkg_list(APPEND options "--disable-nls")
    endif()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        ADDITIONAL_MSYS_PACKAGES gzip
        OPTIONS
            ${options}
        OPTIONS_DEBUG
            --disable-tools
    )
    if("nls" IN_LIST FEATURES)
        vcpkg_build_make(BUILD_TARGET dist LOGFILE_ROOT build-dist)
    endif()
    vcpkg_install_make()

    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    vcpkg_fixup_pkgconfig()

    set(HUNSPELL_EXPORT_HDR "${CURRENT_PACKAGES_DIR}/include/hunspell/hunvisapi.h")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${HUNSPELL_EXPORT_HDR}" "#if defined(HUNSPELL_STATIC)" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    COMMENT "Hunspell is licensed under LGPL/GPL/MPL tri-license."
    FILE_LIST
        "${SOURCE_PATH}/license.hunspell"
        "${SOURCE_PATH}/license.myspell"
        "${SOURCE_PATH}/COPYING.MPL"
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/COPYING.LESSER"
)
