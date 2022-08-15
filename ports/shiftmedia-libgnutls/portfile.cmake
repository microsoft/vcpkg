set(PACKAGE_VERSION_MAJOR 3)
set(PACKAGE_VERSION_MINOR 6)
set(PACKAGE_VERSION_PATCH 15)
set(PACKAGE_VERSION ${PACKAGE_VERSION_MAJOR}.${PACKAGE_VERSION_MINOR}.${PACKAGE_VERSION_PATCH})

set(GNULIB_REF "fb64a781")

message(WARNING "${PORT} on Windows uses a fork managed by the ShiftMediaProject: https://shiftmediaproject.github.io/")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ShiftMediaProject/gnutls
    REF ${PACKAGE_VERSION}
    SHA512 f9b8b453a4484c97051ea2a7e6b318cc3590824921998214586c49a8d2d04c726a719e4c6f46be6efa86d501506632d0091865669bf2e4cfd888f605b43566f9
    HEAD_REF master
    PATCHES
        external-libtasn1.patch
        runtime.patch
        pkgconfig.patch
        nettle.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/devel/perlasm")

vcpkg_download_distfile(
    GNULIB_SNAPSHOT
    URLS "https://git.savannah.gnu.org/gitweb/?p=gnulib.git;a=snapshot;h=${GNULIB_REF};sf=tgz"
    FILENAME "gnulib-${GNULIB_REF}.tar.gz"
    SHA512 6e534b3a623efa5f473977deeed4d24669ef0e0e3ac5fcadc88c5cf2d6ad0852a07c68cd70ac748d7f9a3793704ce1a54a7d17114458a8c1f2e42d410681c340
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH GNULIB_SOURCE_PATH
    ARCHIVE "${GNULIB_SNAPSHOT}"
    REF ${GNULIB_REF}
)

file(REMOVE_RECURSE "${SOURCE_PATH}/gnulib")
file(RENAME ${GNULIB_SOURCE_PATH} "${SOURCE_PATH}/gnulib")

include("${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake")
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
                    "<Import Project=\"${CURRENT_INSTALLED_DIR}/share/vs-yasm/yasm.props\" />"
                _contents "${_contents}")
string(REPLACE  [[<Import Project="$(VCTargetsPath)\BuildCustomizations\yasm.targets" />]]
                    "<Import Project=\"${CURRENT_INSTALLED_DIR}/share/vs-yasm/yasm.targets\" />"
                _contents "${_contents}")
string(REGEX REPLACE "${VCPKG_ROOT_DIR}/installed/[^/]+/share" "${CURRENT_INSTALLED_DIR}/share" _contents "${_contents}") # Above already
file(WRITE "${_gnutlsproject}" "${_contents}")

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(RuntimeLibraryExt "")
else()
    set(RuntimeLibraryExt "DLL")
endif()

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
file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX}/msvc/include" "${CURRENT_PACKAGES_DIR}/include")

set(VERSION ${PACKAGE_VERSION})
set(GNUTLS_REQUIRES_PRIVATE "Requires.private: nettle, libhogweed, libtasn1")
set(GNUTLS_LIBS_PRIVATE "-lcrypt32 -lws2_32 -lkernel32 -lncrypt")

set(prefix "${CURRENT_INSTALLED_DIR}")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(GMP_LIBS "-lgmp")
set(GNUTLS_LIBS -lgnutls)
configure_file("${SOURCE_PATH}/lib/gnutls.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gnutls.pc" @ONLY)

set(prefix "${CURRENT_INSTALLED_DIR}/debug")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/../include")
set(GMP_LIBS "-lgmpd")
set(GNUTLS_LIBS -lgnutlsd)
configure_file("${SOURCE_PATH}/lib/gnutls.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gnutls.pc" @ONLY)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()
