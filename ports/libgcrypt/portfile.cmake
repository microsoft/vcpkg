set (PACKAGE_VERSION 1.9.4)

if(VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "libgcrypt on Windows uses a fork managed by the ShiftMediaProject: https://shiftmediaproject.github.io/")
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ShiftMediaProject/libgcrypt
        REF libgcrypt-${PACKAGE_VERSION}
        SHA512 9885239fd22136e6fb7c99a6771f7b8c813842fe36bcfd345bb9a3d290819042a29ae8cd9cd504fe77c657aa4052a3210d2f495301b3f4af6b97320bb1f4fafb
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
else()
    vcpkg_from_git(
        OUT_SOURCE_PATH SOURCE_PATH
        URL git://git.gnupg.org/libgcrypt.git
        FETCH_REF libgcrypt-${PACKAGE_VERSION}
        REF 05422ca24a0391dad2a0b7790a904ce348819c10 # https://git.gnupg.org/cgi-bin/gitweb.cgi?p=libgcrypt.git;a=commit;h=05422ca24a0391dad2a0b7790a904ce348819c10
        HEAD_REF master
    )

    vcpkg_configure_make(
        AUTOCONFIG
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            --disable-doc
            --disable-silent-rules
            --with-libgpg-error-prefix=${CURRENT_INSTALLED_DIR}/tools/libgpg-error
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig() 
    vcpkg_copy_pdbs()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endif()