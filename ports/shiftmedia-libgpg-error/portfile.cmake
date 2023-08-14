vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ShiftMediaProject/libgpg-error
    REF "libgpg-error-${VERSION}"
    SHA512 779983bd0aac1f281bf357d0218e9626a5c72c3391513eef8a56148f08966f3cc75495e97f410ea7156d40be16977b5c64748c66626ae6d877e2a6c28dc822a2
    HEAD_REF master
    PATCHES 
        outdir.patch
        runtime.patch
        TargetPlatformMinVersion.patch
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

if(VCPKG_TARGET_IS_UWP)
    set(_gpg-errorproject "${SOURCE_PATH}/SMP/libgpg-error_winrt.vcxproj")
else()
    set(_gpg-errorproject "${SOURCE_PATH}/SMP/libgpg-error.vcxproj")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(RuntimeLibraryExt "")
else()
    set(RuntimeLibraryExt "DLL")
endif()

vcpkg_install_msbuild(
    USE_VCPKG_INTEGRATION
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH SMP/libgpg-error.sln
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
set(GPG_ERROR_CONFIG_LIBS "-L\${libdir} -lgpg-error")
configure_file("${SOURCE_PATH}/src/gpg-error.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gpg-error.pc" @ONLY)

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/../include")
set(GPG_ERROR_CONFIG_LIBS "-L\${libdir} -lgpg-errord")
configure_file("${SOURCE_PATH}/src/gpg-error.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gpg-error.pc" @ONLY)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/COPYING.LIB" "${CURRENT_PACKAGES_DIR}/debug/lib/COPYING.LIB")
