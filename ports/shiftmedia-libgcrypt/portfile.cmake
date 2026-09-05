vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ShiftMediaProject/libgcrypt
    REF libgcrypt-${VERSION}
    SHA512 957f2138d174cd39b3809aabbc6873292c56e596892a2273a77301038473cbcd4c69aa5d3d0ebb98a34cf3a2c30ac3212af16b34a304f81d72f11df18c3601f9
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
        IGNORE_UNCHANGED
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
    "${SOURCE_PATH}/SMP/libgcrypt_winrt.vcxproj"
)
    vcpkg_replace_string(
        "${VCXPROJ}"
        "_winrt.lib"
        ".lib"
        IGNORE_UNCHANGED
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

string(REGEX REPLACE "-.*" "" PACKAGE_VERSION "${VERSION}")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(LIBGCRYPT_CONFIG_LIBS "-lgcrypt")
configure_file("${SOURCE_PATH}/src/libgcrypt.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libgcrypt.pc" @ONLY)
if(NOT VCPKG_BUILD_TYPE)
    set(includedir "\${prefix}/../include")
    set(LIBGCRYPT_CONFIG_LIBS "-lgcryptd")
    configure_file("${SOURCE_PATH}/src/libgcrypt.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libgcrypt.pc" @ONLY)
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/src/libgcrypt.m4" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libgcrypt/aclocal/")

file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/COPYING.LIB" "${CURRENT_PACKAGES_DIR}/debug/lib/COPYING.LIB")
vcpkg_install_copyright(COMMENT [[
The library is distributed under the terms of the GNU Lesser General Public License (LGPL).
There are additonal notices about contributions that require these additional notices are distributed.
]]
    FILE_LIST
        "${SOURCE_PATH}/COPYING.LIB"
        "${SOURCE_PATH}/LICENSES"
)
