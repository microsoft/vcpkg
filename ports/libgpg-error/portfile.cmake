set (PACKAGE_VERSION 1.42)

if(VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "libgpg-error on Windows uses a fork managed by the ShiftMediaProject: https://shiftmediaproject.github.io/")
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ShiftMediaProject/libgpg-error
        REF libgpg-error-${PACKAGE_VERSION}
        SHA512 2dbf41e28196f4b99d641a430e6e77566ae2d389bbe9d6f6e310d56a5ca90de9b9ae225a3eee979fe4606d36878d3db6f777162d697de717b4748151dd3525d0
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
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO gpg/libgpg-error
        REF libgpg-error-${PACKAGE_VERSION}
        SHA512 f5a1c1874ac1dee36ee01504f1ab0146506aa7af810879e192eac17a31ec81945fe850953ea1c57188590c023ce3ff195c7cab62af486b731fa1534546d66ba3
        HEAD_REF master
        PATCHES
            add_cflags_to_tools.patch
    )

    vcpkg_configure_make(
        AUTOCONFIG
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            --disable-tests
            --disable-doc
            --disable-silent-rules
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig() 
    vcpkg_copy_pdbs()
	
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/debug/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
    endif()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/locale" "${CURRENT_PACKAGES_DIR}/debug/share")
    file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
