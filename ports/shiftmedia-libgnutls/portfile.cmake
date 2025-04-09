set(GNULIB_REF "3639c57")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ShiftMediaProject/gnutls
    REF ${VERSION}
    SHA512 db318ee923d0810484e98342cc395624efc52b7227020fc14b9fa9ae63e4b8bf254cfd90470e051cd992fb167fb839fff340430a223bcc50d1422f1738a5b599
    HEAD_REF master
    PATCHES
        external-libtasn1.patch
        pkgconfig.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/devel/perlasm")

vcpkg_download_distfile(
    GNULIB_SNAPSHOT
    URLS "https://git.savannah.gnu.org/gitweb/?p=gnulib.git;a=snapshot;h=${GNULIB_REF};sf=tgz"
    FILENAME "gnulib-${GNULIB_REF}.tar.gz"
    SHA512 bc99be736d2907049d498f44d8f24db4beb2b3645459451b595087b9406ac1eebe4cbb4f2ef65df9e65823e01db4b4800b75eb9537236797fe1edcc65418c520
)

vcpkg_extract_source_archive(
    GNULIB_SOURCE_PATH
    ARCHIVE "${GNULIB_SNAPSHOT}"
    SOURCE_BASE ${GNULIB_REF}
)

file(REMOVE_RECURSE "${SOURCE_PATH}/gnulib")
file(RENAME "${GNULIB_SOURCE_PATH}" "${SOURCE_PATH}/gnulib")

include("${CURRENT_HOST_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake")
yasm_tool_helper(OUT_VAR YASM)
file(TO_NATIVE_PATH "${YASM}" YASM)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(CONFIGURATION_RELEASE ReleaseDLL)
    set(CONFIGURATION_DEBUG DebugDLL)
else()
    set(CONFIGURATION_RELEASE Release)
    set(CONFIGURATION_DEBUG Debug)
endif()

if(VCPKG_TARGET_IS_UWP)
    string(APPEND CONFIGURATION_RELEASE WinRT)
    string(APPEND CONFIGURATION_DEBUG WinRT)
endif()

set(_gnutlsproject "${SOURCE_PATH}/SMP/libgnutls.vcxproj")
file(READ "${_gnutlsproject}" _contents)
string(REPLACE  [[<Import Project="$(VCTargetsPath)\BuildCustomizations\yasm.props" />]]
                    "<Import Project=\"${CURRENT_HOST_INSTALLED_DIR}/share/vs-yasm/yasm.props\" />"
                _contents "${_contents}")
string(REPLACE  [[<Import Project="$(VCTargetsPath)\BuildCustomizations\yasm.targets" />]]
                    "<Import Project=\"${CURRENT_HOST_INSTALLED_DIR}/share/vs-yasm/yasm.targets\" />"
                _contents "${_contents}")
string(REGEX REPLACE "${VCPKG_ROOT_DIR}/installed/[^/]+/share" "${CURRENT_HOST_INSTALLED_DIR}/share" _contents "${_contents}") # Above already
file(WRITE "${_gnutlsproject}" "${_contents}")

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(RuntimeLibraryExt "")
else()
    set(RuntimeLibraryExt "DLL")
endif()

# patch output library file path and name
foreach(PROPS IN ITEMS
"${SOURCE_PATH}/SMP/smp_deps.props"
"${SOURCE_PATH}/SMP/smp_winrt_deps.props")
vcpkg_replace_string(
    "${PROPS}"
    [=[_winrt</TargetName>]=]
    [=[</TargetName>]=]
    IGNORE_UNCHANGED
)
vcpkg_replace_string(
    "${PROPS}"
    [=[<TargetName>lib$(RootNamespace)]=]
    [=[<TargetName>$(RootNamespace)]=]
)
endforeach()

# patch hogweed, gpm, nettle, zlib libraries file names; inject RuntimeLibrary property to control CRT linkage 
foreach(VCXPROJ IN ITEMS
"${SOURCE_PATH}/SMP/libgnutls.vcxproj"
"${SOURCE_PATH}/SMP/libgnutls_winrt.vcxproj")
vcpkg_replace_string(
    "${VCXPROJ}"
    "_winrt.lib"
    ".lib"
    IGNORE_UNCHANGED
)
vcpkg_replace_string(
    "${VCXPROJ}"
    "libhogweed"
    "hogweed"
)
vcpkg_replace_string(
    "${VCXPROJ}"
    "hogweedd"
    "hogweed"
)
vcpkg_replace_string(
    "${VCXPROJ}"
    "libgmp"
    "gmp"
)
vcpkg_replace_string(
    "${VCXPROJ}"
    "gmpd"
    "gmp"
)
vcpkg_replace_string(
    "${VCXPROJ}"
    "libnettle"
    "nettle"
)
vcpkg_replace_string(
    "${VCXPROJ}"
    "nettled"
    "nettle"
)
vcpkg_replace_string(
    "${VCXPROJ}"
    "libzlib"
    "zlib"
)
vcpkg_replace_string(
    "${VCXPROJ}"
    [=[</DisableSpecificWarnings>]=]
    [=[</DisableSpecificWarnings><RuntimeLibrary>$(RuntimeLibrary)</RuntimeLibrary>]=]
)
endforeach()

vcpkg_install_msbuild(
    USE_VCPKG_INTEGRATION
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH SMP/libgnutls.sln
    PLATFORM ${TRIPLET_SYSTEM_ARCH}
    LICENSE_SUBPATH LICENSE
    RELEASE_CONFIGURATION ${CONFIGURATION_RELEASE}
    DEBUG_CONFIGURATION ${CONFIGURATION_DEBUG}
    SKIP_CLEAN
    OPTIONS /p:YasmPath="${YASM}" /p:OutDir=..\\msvc
    OPTIONS_DEBUG /p:RuntimeLibrary=MultiThreadedDebug${RuntimeLibraryExt}
    OPTIONS_RELEASE /p:RuntimeLibrary=MultiThreaded${RuntimeLibraryExt}
)

get_filename_component(SOURCE_PATH_SUFFIX "${SOURCE_PATH}" NAME)
if(VCPKG_TARGET_IS_UWP)
    set(WINRT_SUBFOLDER libgnutls_winrt)
endif()
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX}/msvc/${WINRT_SUBFOLDER}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

set(GNUTLS_REQUIRES_PRIVATE "Requires.private: gmp, nettle, hogweed, libtasn1")
set(GNUTLS_LIBS_PRIVATE "-lcrypt32 -lws2_32 -lkernel32 -lncrypt")

set(prefix "${CURRENT_INSTALLED_DIR}")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(GNUTLS_LIBS "-lgnutls")
configure_file("${SOURCE_PATH}/lib/gnutls.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gnutls.pc" @ONLY)

if(NOT VCPKG_BUILD_TYPE)
  set(prefix "${CURRENT_INSTALLED_DIR}/debug")
  set(exec_prefix "\${prefix}")
  set(libdir "\${prefix}/lib")
  set(includedir "\${prefix}/../include")
  set(GNUTLS_LIBS "-lgnutlsd")
  configure_file("${SOURCE_PATH}/lib/gnutls.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gnutls.pc" @ONLY)
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
file(COPY "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gnutls")
