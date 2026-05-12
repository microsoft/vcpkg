vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/tcl/files/Tcl/${VERSION}/tcl${VERSION}-src.tar.gz/download"
    FILENAME "tcl${VERSION}-src.tar.gz"
    SHA512 a899333fd96f139d92ad74ee42cc402428677ab2cab8ed3eb1e6e7cb35c7ca7d39aac89b7755b2fb1786512c857c79486d71f49a7821470f669fb9e544dba532

)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        dependencies.diff
        nmake.diff
)
file(GLOB sqlite3_sources "${SOURCE_PATH}/pkgs/sqlite3.51.0/compat/sqlite3/*.c" "${SOURCE_PATH}/pkgs/sqlite3.51.0/compat/sqlite3/*.h")
file(GLOB precompiled_tools "${SOURCE_PATH}/win/*.exe" "${SOURCE_PATH}/pkgs/*/win/*.exe")
file(REMOVE_RECURSE
    "${SOURCE_PATH}/compat/zlib"
    "${SOURCE_PATH}/libtommath"
    ${sqlite3_sources}
    ${precompiled_tools}
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # Cf. https://core.tcl-lang.org/tips/doc/main/tip/477.md

    set(OPTS pdbs)
    set(TCLSH_SUFFIX "")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(OPTS ${OPTS},static)
        string(APPEND TCLSH_SUFFIX "s")
    endif()
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(OPTS ${OPTS},msvcrt)
    else()
        set(OPTS ${OPTS},nomsvcrt)
        string(APPEND TCLSH_SUFFIX "x")
    endif()
    
    if("profile" IN_LIST FEATURES)
        set(OPTS ${OPTS},profile)
    endif()
    if("thrdalloc" IN_LIST FEATURES)
        set(OPTS ${OPTS},thrdalloc)
    endif()
    if("time64bit" IN_LIST FEATURES)
        set(OPTS ${OPTS},time64bit)
    endif()

    cmake_path(NATIVE_PATH CURRENT_HOST_INSTALLED_DIR CURRENT_HOST_INSTALLED_DIR_NATIVE)
    vcpkg_list(SET OPTIONS)
    if(VCPKG_CROSSCOMPILING)
        file(GLOB HOST_TCLSH "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/bin/tclsh90*.exe")
        cmake_path(NATIVE_PATH HOST_TCLSH HOST_TCLSH_NATIVE)
        vcpkg_list(APPEND OPTIONS
            "NMAKEHLPC=${CURRENT_HOST_INSTALLED_DIR_NATIVE}\\tools\\${PORT}\\bin\\nmakehlp.exe"
            "TCLSH_NATIVE=${HOST_TCLSH_NATIVE}"
        )
    endif()

    set(ZLIB_BASENAME "z")
    if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/zs.lib")
        set(ZLIB_BASENAME "zs")
    endif()

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH win
        OPTIONS
            STATS=none
            CHECKS=none
            ${OPTIONS}
        OPTIONS_DEBUG
            OPTS=${OPTS},symbols
            "SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}\\tools\\${PORT}\\debug\\lib\\tcl9.0"
            "SQLITE3_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib"
            "TOMMATHOBJS=${CURRENT_INSTALLED_DIR}/debug/lib/tommath.lib"
            "ZLIBOBJS=${CURRENT_INSTALLED_DIR}/debug/lib/${ZLIB_BASENAME}d.lib"
            "HOST_DLL_DIR=${CURRENT_HOST_INSTALLED_DIR_NATIVE}\\debug\\bin"
        OPTIONS_RELEASE
            OPTS=${OPTS}
            "SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}\\tools\\${PORT}\\lib\\tcl9.0"
            "SQLITE3_LIBS=${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib"
            "TOMMATHOBJS=${CURRENT_INSTALLED_DIR}/lib/tommath.lib"
            "ZLIBOBJS=${CURRENT_INSTALLED_DIR}/lib/${ZLIB_BASENAME}.lib"
            "HOST_DLL_DIR=${CURRENT_HOST_INSTALLED_DIR}\\bin"
    )

    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_copy_tools(TOOL_NAMES tclsh90${TCLSH_SUFFIX}
            SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin"
        )
    endif()
    vcpkg_copy_tools(TOOL_NAMES tclsh90${TCLSH_SUFFIX}
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
        AUTO_CLEAN
    )
    if(NOT VCPKG_CROSSCOMPILING)
        vcpkg_copy_tools(TOOL_NAMES nmakehlp
            SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/win"
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
        )
    endif()

    file(GLOB_RECURSE extensions "${CURRENT_PACKAGES_DIR}/lib/*/*.dll")
    if(extensions)
        file(COPY ${extensions} DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}")
        file(REMOVE ${extensions})
        if(NOT VCPKG_BUILD_TYPE)
            file(GLOB_RECURSE extensions "${CURRENT_PACKAGES_DIR}/debug/lib/*/*.dll")
            file(COPY ${extensions} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}")
            file(REMOVE ${extensions})
        endif()
    endif()
    
    file(GLOB_RECURSE tclconfigs "${CURRENT_PACKAGES_DIR}/lib/*Config.sh")
    foreach(file IN LISTS tclconfigs)
        cmake_path(GET file FILENAME filename)
        file(COPY_FILE "${file}" "${CURRENT_BUILDTREES_DIR}/aaa-${TARGET_TRIPLET}-${filename}.log")
    endforeach()
    file(GLOB_RECURSE tclconfigs "${CURRENT_PACKAGES_DIR}/lib/*Config.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/*Config.sh")
    file(REMOVE ${tclconfigs} PLACEHOLDER)

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
else()
    if(VCPKG_CROSSCOMPILING)
        vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/bin")
        set(ENV{HOST_TCLSH} "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/bin/tclsh9.0")
    endif()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}/unix"
        AUTORECONF
        DEFAULT_OPTIONS_EXCLUDE "^--(disable|enable)-static"
        OPTIONS
            "CFLAGS=-I${CURRENT_INSTALLED_DIR}/include \$CFLAGS"
            --with-system-libtommath
            --with-system-sqlite
    )
    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()
    
    file(GLOB_RECURSE config_scripts "${CURRENT_PACKAGES_DIR}/lib/*Config.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/*Config.sh")
    file(REMOVE ${config_scripts})

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/share/man1"
        "${CURRENT_PACKAGES_DIR}/share/man3"
        "${CURRENT_PACKAGES_DIR}/share/mann"
    )
endif()

file(GLOB pkgs_license_files RELATIVE "${SOURCE_PATH}/pkgs" "${SOURCE_PATH}/pkgs/*/license.terms")
foreach(path IN LISTS pkgs_license_files)
    string(REPLACE "/" " " filename "${path}")
    file(COPY_FILE "${SOURCE_PATH}/pkgs/${path}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${filename}")
    string(REPLACE "${path}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${filename}" pkgs_license_files "${pkgs_license_files}")
endforeach()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.terms" ${pkgs_license_files})
