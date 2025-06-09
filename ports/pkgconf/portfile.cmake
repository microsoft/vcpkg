vcpkg_download_distfile(
    ADD_MISSING_DEFINE_PATCH
    URLS https://github.com/pkgconf/pkgconf/commit/664b53d5c4920e66e4a57c7515ccfd1bd1477bac.patch?full_index=1
    FILENAME pkgconf-add-missing-define-664b53d5c4920e66e4a57c7515ccfd1bd1477bac.patch
    SHA512 1e5dc8b6ac9547157694c1674660c0f207876ed2916a053217c9299eb352c05d1f03a1ba8afddaf994b7c22474590407c627846cd68000bf53bd7229d9009895
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pkgconf/pkgconf
    REF "pkgconf-${VERSION}"
    SHA512 8c73b8f9c3dd3c72e6b0acf139a68054d631484af4618f46c30c3c13947294986d809bbac0648af9e974739fd42e1730a4e22323884d7cf72f0843a972991a99
    HEAD_REF master
    PATCHES
        "${ADD_MISSING_DEFINE_PATCH}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_PKG_CONFIG
    OPTIONS -Dtests=disabled
)

set(systemsuffix "")
set(architectureprefix "")

set(SYSTEM_LIBDIR "")
set(PKG_DEFAULT_PATH "")
set(SYSTEM_INCLUDEDIR "")
set(PERSONALITY_PATH "personality.d")


if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_CROSSCOMPILING AND VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    # These defaults are obtained from pkgconf/pkg-config on Ubuntu and OpenSuse
    # vcpkg cannot do system introspection to obtain/set these values since it would break binary caching.
    set(SYSTEM_INCLUDEDIR "/usr/include")
    # System lib dirs will be stripped from -L from the pkg-config output
    set(SYSTEM_LIBDIR "/lib:/lib/i386-linux-gnu:/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnux32:/lib64:/lib32:/libx32:/usr/lib:/usr/lib/i386-linux-gnu:/usr/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnux32:/usr/lib64:/usr/lib32:/usr/libx32")
    set(PKG_DEFAULT_PATH "/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig")
    set(PERSONALITY_PATH "/usr/share/pkgconfig/personality.d:/etc/pkgconfig/personality.d")
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pkgconf/libpkgconf/libpkgconf-api.h" "#if defined(PKGCONFIG_IS_STATIC)" "#if 1")
endif()

vcpkg_copy_tools(TOOL_NAMES pkgconf AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
