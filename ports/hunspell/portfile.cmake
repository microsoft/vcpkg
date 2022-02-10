vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hunspell/hunspell
    REF v1.7.0
    SHA512 8149b2e8b703a0610c9ca5160c2dfad3cf3b85b16b3f0f5cfcb7ebb802473b2d499e8e2d0a637a97a37a24d62424e82d3880809210d3f043fa17a4970d47c903
    HEAD_REF master
    PATCHES
        0001_fix_unistd.patch
        0002-disable-test.patch
        0003-fix-win-build.patch
        0004-add-win-arm64.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(REMOVE "${SOURCE_PATH}/README") #README is a symlink

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

    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(HUNSPELL_CONFIGURATION _dll)
    else()
        set(HUNSPELL_CONFIGURATION )
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
else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(ENV{CFLAGS} "$ENV{CFLAGS} -DHUNSPELL_STATIC")
        set(ENV{CXXFLAGS} "$ENV{CXXFLAGS} -DHUNSPELL_STATIC")
    endif()
    if(NOT "tools" IN_LIST FEATURES) # Building the tools is not possible on windows!
        file(READ "${SOURCE_PATH}/src/Makefile.am" _contents)
        string(REPLACE " parsers tools" "" _contents "${_contents}")
        file(WRITE "${SOURCE_PATH}/src/Makefile.am" "${_contents}")
    endif()
    vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
        AUTOCONFIG
        ADDITIONAL_MSYS_PACKAGES gzip
    )
    #install-pkgconfDATA:
    vcpkg_build_make(BUILD_TARGET dist LOGFILE_ROOT build-dist)
    vcpkg_install_make()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    vcpkg_fixup_pkgconfig()
endif()
vcpkg_copy_pdbs()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if (VCPKG_TARGET_IS_WINDOWS)
        set(HUNSPELL_EXPORT_HDR "${CURRENT_PACKAGES_DIR}/include/hunvisapi.h")
    else()
        set(HUNSPELL_EXPORT_HDR "${CURRENT_PACKAGES_DIR}/include/hunspell/hunvisapi.h")
    endif()
    vcpkg_replace_string(
        ${HUNSPELL_EXPORT_HDR}
        "#if defined(HUNSPELL_STATIC)"
        "#if 1"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/COPYING.LESSER" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright-lgpl)
file(INSTALL "${SOURCE_PATH}/COPYING.MPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright-mpl)
