set (PACKAGE_VERSION 1.41)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ShiftMediaProject/libgpg-error
        REF 8dbb46c75850c6a2a215b1964dcca59ff6e34af6 #v1.41
        SHA512 87737bd8e042faa552734ac35033ddf1de2ca2314d8be68157408c41240228f2810909c656efa64b6b1c5de2b69b989fed306a33d25c84161cbc7aa2ce795955
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

    if(VCPKG_TARGET_IS_UWP)
        set(_gpg-errorproject "${SOURCE_PATH}/SMP/libgpg-error_winrt.vcxproj")
    else()
        set(_gpg-errorproject "${SOURCE_PATH}/SMP/libgpg-error.vcxproj")
    endif()

    file(READ "${_gpg-errorproject}" _contents)
    string(REGEX REPLACE "${VCPKG_ROOT_DIR}/installed/[^/]+/share" "${CURRENT_INSTALLED_DIR}/share" _contents "${_contents}") # Above already
    file(WRITE "${_gpg-errorproject}" "${_contents}")


    vcpkg_install_msbuild(
        USE_VCPKG_INTEGRATION
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH SMP/libgpg-error.sln
        PLATFORM ${TRIPLET_SYSTEM_ARCH}
        LICENSE_SUBPATH COPYING.LIB
        TARGET Rebuild
        RELEASE_CONFIGURATION ${CONFIGURATION_RELEASE}
        DEBUG_CONFIGURATION ${CONFIGURATION_DEBUG}
        SKIP_CLEAN
    )

    get_filename_component(SOURCE_PATH_SUFFIX "${SOURCE_PATH}" NAME)
    file(RENAME "${CURRENT_BUILDTREES_DIR}/msvc/include" "${CURRENT_PACKAGES_DIR}/include")
    
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
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO gpg/libgpg-error
        REF libgpg-error-${PACKAGE_VERSION}
        SHA512 9a0e32bac58df60bfd53cfb0911f4793913a96bc8373e5348a1ab8774ceda56b2447aba51385a91e9e2022332149c3f7c0c7c44d989920affbeb71cf6f40358a
        HEAD_REF master
    PATCHES
        add_cflags_to_tools.patch
    )

    vcpkg_configure_make(
        AUTOCONFIG
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            --disable-tests
            --disable-doc
            --disable-silent-rules
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig() 
    vcpkg_copy_pdbs()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/locale ${CURRENT_PACKAGES_DIR}/debug/share)
    file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endif()
