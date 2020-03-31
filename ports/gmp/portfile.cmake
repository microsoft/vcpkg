
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ShiftMediaProject/gmp
        REF e140dfc8668e96d7e56cbd46467945adcc6b3cc4 #v6.2.0
        SHA512 3b646c142447946bb4556db01214ff130da917bc149946b8cf086f3b01e1cc3d664b941a30a42608799c14461b2f29e4b894b72915d723bd736513c8914729b7
        HEAD_REF master
        PATCHES vs.build.patch
    )
    vcpkg_find_acquire_program(YASM)
    message(STATUS "YASM:${YASM}")
    get_filename_component(YASM_DIR "${YASM}" DIRECTORY)
    vcpkg_add_to_path(${YASM_DIR})
    set(ENV{YASMPATH} ${YASM_DIR}/)
    if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
        set(PLATFORM "Win32")
    else ()
        set(PLATFORM ${TRIPLET_SYSTEM_ARCH})
    endif()
    
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
    #<Import Project="${CURRENT_INSTALLED_DIR}/share/vs-yasm/yasm.props" />
    set(_file "${SOURCE_PATH}/SMP/libgmp.vcxproj")
    file(READ "${_file}" _contents)
    string(REPLACE  [[<Import Project="$(VCTargetsPath)\BuildCustomizations\yasm.props" />]]
                     "<Import Project=\"${CURRENT_INSTALLED_DIR}/share/vs-yasm/yasm.props\" />"
                    _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
    
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH SMP/libgmp.sln
        PLATFORM ${PLATFORM}
        LICENSE_SUBPATH COPYING.LESSERv3
        TARGET Rebuild
        RELEASE_CONFIGURATION ${CONFIGURATION_RELEASE}
        DEBUG_CONFIGURATION ${CONFIGURATION_DEBUG}
        SKIP_CLEAN
    )
    get_filename_component(SOURCE_PATH_SUFFIX "${SOURCE_PATH}" NAME)
    file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX}/msvc/include" "${CURRENT_PACKAGES_DIR}/include")
    set(PACKAGE_VERSION 6.2.0)
    set(PACKAGE_NAME gmp)
    set(prefix "${CURRENT_INSTALLED_DIR}")
    set(exec_prefix "\${prefix}")
    set(libdir "\${prefix}/lib")
    set(includedir "\${prefix}/include")
    set(LIBS -lgmp)
    configure_file("${SOURCE_PATH}/gmp.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gmp.pc" @ONLY)
    configure_file("${SOURCE_PATH}/gmpxx.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gmpxx.pc" @ONLY)
    set(prefix "${CURRENT_INSTALLED_DIR}/debug")
    set(exec_prefix "\${prefix}")
    set(libdir "\${prefix}/lib")
    set(includedir "\${prefix}/../include")
    set(LIBS -lgmpd)
    configure_file("${SOURCE_PATH}/gmp.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gmp.pc" @ONLY)
    configure_file("${SOURCE_PATH}/gmpxx.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gmpxx.pc" @ONLY)
    vcpkg_fixup_pkgconfig()
else()
    vcpkg_download_distfile(
        ARCHIVE
        URLS https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz 
        FILENAME gmp-6.2.0.tar.xz
        SHA512 a066f0456f0314a1359f553c49fc2587e484ff8ac390ff88537266a146ea373f97a1c0ba24608bf6756f4eab11c9056f103c8deb99e5b57741b4f7f0ec44b90c)

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        REF gmp-6.2.0
    )

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        #SKIP_CONFIGURE
        #NO_DEBUG
        #AUTO_HOST
        #AUTO_DST
        #PRERUN_SHELL ${SHELL_PATH}
        OPTIONS ${OPTIONS}
        #OPTIONS_DEBUG
        #OPTIONS_RELEASE
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    # # Handle copyright
    file(INSTALL "${SOURCE_PATH}/COPYINGv3" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()


