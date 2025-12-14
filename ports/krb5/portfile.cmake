vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO krb5/krb5
    REF krb5-${VERSION}-final
    SHA512 4abfc37679483727fdad827afcf53729e6316febdf985a70133ee1dabaf8516e7fa771c1cfbc8fd557fed868c50f16b26bb59939ec091c2dd7019d0b2234ef1f
    HEAD_REF master
    PATCHES
        static-deps.diff
        define-des-zeroblock.diff
)

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    vcpkg_find_acquire_program(PERL)
    get_filename_component(PERL_PATH "${PERL}" DIRECTORY)
    vcpkg_add_to_path("${PERL_PATH}")
    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}/src"
        PROJECT_NAME Makefile.in
        TARGET prep-windows
        OPTIONS_RELEASE
            "NODEBUG=1"
    )
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug")
    vcpkg_install_nmake(
        SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}"
        PROJECT_NAME "Makefile"
        OPTIONS
            "NO_LEASH=1"
        OPTIONS_RELEASE
            "KRB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}"
            "NODEBUG=1"
        OPTIONS_DEBUG
            "KRB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug"
    )
    set(tools
        ccapiserver
        gss-client
        gss-server
        kcpytkt
        kdeltkt
        kdestroy
        kfwcpcc
        kinit
        klist
        kpasswd
        kswitch
        kvno
        mit2ms
        ms2mit
    )
    vcpkg_copy_tools(
        TOOL_NAMES ${tools}
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
        AUTO_CLEAN
    )
    foreach(tool_name ${tools})
        list(APPEND debug_tools_to_remove "${CURRENT_PACKAGES_DIR}/debug/bin/${tool_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    endforeach()
    file(REMOVE ${debug_tools_to_remove})

    set(WINDOWS_PC_FILES 
        krb5-gssapi
        krb5
        mit-krb5-gssapi
        mit-krb5
    )

    foreach (PC_FILE ${WINDOWS_PC_FILES})
        configure_file("${CURRENT_PORT_DIR}/windows_pc_files/${PC_FILE}.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${PC_FILE}.pc" @ONLY)
    endforeach()

    if(NOT DEFINED VCPKG_BUILD_TYPE)
        foreach (PC_FILE ${WINDOWS_PC_FILES})
            configure_file("${CURRENT_PORT_DIR}/windows_pc_files/${PC_FILE}.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${PC_FILE}.pc" @ONLY)
        endforeach()    
    endif()
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}/src"
        AUTOCONFIG
        OPTIONS
            --disable-nls
            --with-tls-impl=no
            "CFLAGS=-fcommon \$CFLAGS"
    )
    vcpkg_install_make()

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/krb5-config" "${CURRENT_INSTALLED_DIR}" [[$(cd "$(dirname "$0")/../../.."; pwd -P)]])
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/compile_et" "${CURRENT_INSTALLED_DIR}" [[$(cd "$(dirname "$0")/../../.."; pwd -P)]])
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/krb5-config" "${CURRENT_INSTALLED_DIR}" [[$(cd "$(dirname "$0")/../../../.."; pwd -P)]])
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/compile_et" "${CURRENT_INSTALLED_DIR}" [[$(cd "$(dirname "$0")/../../../.."; pwd -P)]])
    endif()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/var")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat1")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat5")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat7")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat8")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/var")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/lib/krb5/"
        "${CURRENT_PACKAGES_DIR}/lib/krb5/"
    )
endif()

if(VCPKG_BUILD_TYPE)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/NOTICE")
