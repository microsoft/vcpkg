set(PACKAGE_VERSION_MAJOR 1)
set(PACKAGE_VERSION_MINOR 10)
set(PACKAGE_VERSION_PATCH 1)
set(PACKAGE_VERSION ${PACKAGE_VERSION_MAJOR}.${PACKAGE_VERSION_MINOR}.${PACKAGE_VERSION_PATCH})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ShiftMediaProject/libgcrypt
    REF libgcrypt-${PACKAGE_VERSION}
    SHA512 6da8225ec73c51562cd76a0c0abc19506a7378750ed2a9ea45f03df3c8d7cf500840459deb9b0a694a5602fe77ee2b0dd5b2e37376745233350b0f218dff4f1c
    HEAD_REF master
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

# patch output library file path and name; inject RuntimeLibrary property to control CRT linkage 
foreach(PROPS IN ITEMS
    "${SOURCE_PATH}/SMP/smp_deps.props"
    "${SOURCE_PATH}/SMP/smp_winrt_deps.props")
    vcpkg_replace_string(
        "${PROPS}"
        [=[_winrt</TargetName>]=]
        [=[</TargetName>]=]
    )
    vcpkg_replace_string(
        "${PROPS}"
        [=[<TargetName>lib$(RootNamespace)]=]
        [=[<TargetName>$(RootNamespace)]=]
    )
    vcpkg_replace_string(
        "${PROPS}"
        [=[</TreatSpecificWarningsAsErrors>]=]
        [=[</TreatSpecificWarningsAsErrors><RuntimeLibrary>$(RuntimeLibrary)</RuntimeLibrary>]=]
    )
endforeach()

# patch gpg-error library file name
foreach(VCXPROJ IN ITEMS
    "${SOURCE_PATH}/SMP/libgcrypt.vcxproj"
    "${SOURCE_PATH}/SMP/libgcrypt_winrt.vcxproj")
    vcpkg_replace_string(
        "${VCXPROJ}"
        "_winrt.lib"
        ".lib"
    )
    vcpkg_replace_string(
        "${VCXPROJ}"
        "libgpg-error"
        "gpg-error"
    )
endforeach()

vcpkg_install_msbuild(
    USE_VCPKG_INTEGRATION
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH SMP/libgcrypt.sln
    PLATFORM ${TRIPLET_SYSTEM_ARCH}
    LICENSE_SUBPATH COPYING.LIB
    RELEASE_CONFIGURATION ${CONFIGURATION_RELEASE}
    DEBUG_CONFIGURATION ${CONFIGURATION_DEBUG}
    SKIP_CLEAN
    OPTIONS /p:OutDir=..\\msvc
    OPTIONS_DEBUG "/p:RuntimeLibrary=MultiThreadedDebug${RuntimeLibraryExt}"
    OPTIONS_RELEASE "/p:RuntimeLibrary=MultiThreaded${RuntimeLibraryExt}"
)

get_filename_component(SOURCE_PATH_SUFFIX "${SOURCE_PATH}" NAME)
if(VCPKG_TARGET_IS_UWP)
    set(WINRT_SUBFOLDER libgcrypt_winrt)
endif()
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX}/msvc/${WINRT_SUBFOLDER}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(LIBGCRYPT_CONFIG_LIBS "-lgcrypt")
configure_file("${SOURCE_PATH}/src/libgcrypt.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libgcrypt.pc" @ONLY)

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/../include")
set(LIBGCRYPT_CONFIG_LIBS "-lgcryptd")
configure_file("${SOURCE_PATH}/src/libgcrypt.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libgcrypt.pc" @ONLY)

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/src/libgcrypt.m4" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libgcrypt/aclocal/")

file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/COPYING.LIB" "${CURRENT_PACKAGES_DIR}/debug/lib/COPYING.LIB")
