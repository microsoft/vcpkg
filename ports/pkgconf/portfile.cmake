vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pkgconf/pkgconf
    REF cef30268e1a3f79efd607c26abcf556aa314c9c4 
    SHA512 ea03b81d01521201bdc471a39cdc8b13f9452f7cc78706d5c57056595f3e4e8a3562c022ebb72ce6444f2c7a8dfc778114814ef5064eaef770a70cc294c7f7ee
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_PKG_CONFIG
    OPTIONS -Dtests=false
    )

set(systemsuffix "")
set(architectureprefix "")

if(VCPKG_TARGET_IS_LINUX)
    set(systemsuffix "linux-gnu")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(architectureprefix "x86_64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(architectureprefix "i386")
    endif()
endif()

if(NOT systemsuffix STREQUAL "" AND NOT architectureprefix STREQUAL "")
    set(archdir "${architectureprefix}-${systemsuffix}")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    # These defaults are taken from the pkg-config configure.ac script
    set(SYSTEM_LIBDIR "/usr/lib:/lib")
    set(PKG_DEFAULT_PATH "/usr/lib/pkgconfig:/usr/share/pkgconfig")
    set(SYSTEM_INCLUDEDIR "/usr/include")
    set(PERSONALITY_PATH "/usr/lib/pkgconfig/personality.d:/usr/share/pkgconfig/personality.d")

    if(NOT archdir STREQUAL "")
        string(PREPEND PKG_DEFAULT_PATH "/usr/lib/${archdir}/pkgconfig:")
        string(PREPEND SYSTEM_INCLUDEDIR "/usr/include/${archdir}:")
        string(PREPEND PERSONALITY_PATH "/usr/lib/${archdir}/pkgconfig/personality.d:")
    endif()
else()
    set(SYSTEM_LIBDIR "")
    set(PKG_DEFAULT_PATH "")
    set(SYSTEM_INCLUDEDIR "")
    set(PERSONALITY_PATH "personality.d")
endif()

if(DEFINED VCPKG_pkgconf_SYSTEM_LIBDIR)
    set(SYSTEM_LIBDIR "${VCPKG_pkgconf_SYSTEM_LIBDIR}")
endif()
if(DEFINED VCPKG_pkgconf_PKG_DEFAULT_PATH)
    set(PKG_DEFAULT_PATH "${VCPKG_pkgconf_PKG_DEFAULT_PATH}")
endif()
if(DEFINED VCPKG_pkgconf_SYSTEM_INCLUDEDIR)
    set(SYSTEM_INCLUDEDIR "${VCPKG_pkgconf_SYSTEM_INCLUDEDIR}")
endif()
if(DEFINED VCPKG_pkgconf_PERSONALITY_PATH)
    set(PERSONALITY_PATH "${VCPKG_pkgconf_PERSONALITY_PATH}")
endif()


set(pkgconfig_file "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libpkgconf/config.h")
if(EXISTS "${pkgconfig_file}")
    file(READ "${pkgconfig_file}" contents)
    string(REGEX REPLACE "#define PKG_DEFAULT_PATH [^\n]+" "#define PKG_DEFAULT_PATH \"${PKG_DEFAULT_PATH}\"" contents "${contents}")
    string(REGEX REPLACE "#define SYSTEM_INCLUDEDIR [^\n]+" "#define SYSTEM_INCLUDEDIR \"${SYSTEM_INCLUDEDIR}\"" contents "${contents}")
    string(REGEX REPLACE "#define SYSTEM_LIBDIR [^\n]+" "#define SYSTEM_LIBDIR \"${SYSTEM_LIBDIR}\"" contents "${contents}")
    string(REGEX REPLACE "#define PERSONALITY_PATH [^\n]+" "#define PERSONALITY_PATH \"${PERSONALITY_PATH}\"" contents "${contents}")
    file(WRITE "${pkgconfig_file}" "${contents}")
endif()
set(pkgconfig_file "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libpkgconf/config.h")
if(EXISTS "${pkgconfig_file}")
    file(READ "${pkgconfig_file}" contents)
    string(REGEX REPLACE "#define PKG_DEFAULT_PATH [^\n]+" "#define PKG_DEFAULT_PATH \"${PKG_DEFAULT_PATH}\"" contents "${contents}")
    string(REGEX REPLACE "#define SYSTEM_INCLUDEDIR [^\n]+" "#define SYSTEM_INCLUDEDIR \"${SYSTEM_INCLUDEDIR}\"" contents "${contents}")
    string(REGEX REPLACE "#define SYSTEM_LIBDIR [^\n]+" "#define SYSTEM_LIBDIR \"${SYSTEM_LIBDIR}\"" contents "${contents}")
    string(REGEX REPLACE "#define PERSONALITY_PATH [^\n]+" "#define PERSONALITY_PATH \"${PERSONALITY_PATH}\"" contents "${contents}")
    file(WRITE "${pkgconfig_file}" "${contents}")
endif()

vcpkg_install_meson()
vcpkg_fixup_pkgconfig(SKIP_CHECK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pkgconf/libpkgconf/libpkgconf-api.h" "#if defined(PKGCONFIG_IS_STATIC)" "#if 1")
endif()

vcpkg_copy_tools(TOOL_NAMES pkgconf AUTO_CLEAN)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
