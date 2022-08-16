message(WARNING "libgcrypt on Windows uses a fork managed by the ShiftMediaProject: https://shiftmediaproject.github.io/")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ShiftMediaProject/libgcrypt
    REF libgcrypt-1.10.1
    SHA512 6da8225ec73c51562cd76a0c0abc19506a7378750ed2a9ea45f03df3c8d7cf500840459deb9b0a694a5602fe77ee2b0dd5b2e37376745233350b0f218dff4f1c
    HEAD_REF master
    PATCHES 
        outdir.patch
        gpgerror.patch
        runtime.patch
)

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

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(RuntimeLibraryExt "")
else()
    set(RuntimeLibraryExt "DLL")
endif()

vcpkg_install_msbuild(
    USE_VCPKG_INTEGRATION
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH SMP/libgcrypt.sln
    PLATFORM ${TRIPLET_SYSTEM_ARCH}
    LICENSE_SUBPATH COPYING.LIB
    RELEASE_CONFIGURATION ${CONFIGURATION_RELEASE}
    DEBUG_CONFIGURATION ${CONFIGURATION_DEBUG}
    SKIP_CLEAN
    OPTIONS_DEBUG "/p:RuntimeLibrary=MultiThreadedDebug${RuntimeLibraryExt}"
    OPTIONS_RELEASE "/p:RuntimeLibrary=MultiThreaded${RuntimeLibraryExt}"
)

get_filename_component(SOURCE_PATH_SUFFIX "${SOURCE_PATH}" NAME)
file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX}/msvc/include" "${CURRENT_PACKAGES_DIR}/include")

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(LIBGCRYPT_CONFIG_LIBS "-L\${libdir} -lgcrypt -lgpg-error")
configure_file("${SOURCE_PATH}/src/libgcrypt.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libgcrypt.pc" @ONLY)

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/../include")
set(LIBGCRYPT_CONFIG_LIBS "-L\${libdir} -lgcryptd -lgpg-errord")
configure_file("${SOURCE_PATH}/src/libgcrypt.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libgcrypt.pc" @ONLY)

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/src/libgcrypt.m4" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/aclocal/")

file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/COPYING.LIB" "${CURRENT_PACKAGES_DIR}/debug/lib/COPYING.LIB")
