set(LIB_FILENAME libqcow-alpha-${VERSION}.tar.gz)

# Release distribution file contains configured sources, while the source code in the repository does not.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libqcow/releases/download/${VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 8d68ce3f94dbc75cdb9af8690384705b3516cf9199bd93a255be8ee14aa3f4aff36d8e0bfd54558c6160a0953502407261d74e99d55fd31b9b01bebb1c842817
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        devendor-zlib.diff
        disable-dokan.diff
        mingw-zlib.diff
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

    vcpkg_libyal_msvscpp_convert(
        OUT_PROJECT_SUBPATH project_subpath
        SOURCE_PATH "${SOURCE_PATH}"
        SOLUTION "msvscpp/libqcow.sln"
    )

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "${project_subpath}"
        DEBUG_CONFIGURATION VSDebug
        DEPENDENT_PKGCONFIG zlib
    )

    file(GLOB headers "${SOURCE_PATH}/include/libqcow/*.h")
    file(INSTALL ${headers} DESTINATION "${CURRENT_PACKAGES_DIR}/include/libqcow")
    file(INSTALL "${SOURCE_PATH}/include/libqcow.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

    file(GLOB tests "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qcow_test*.exe")
    file(REMOVE_RECURSE ${tests})

    block(SCOPE_FOR VARIABLES)
        set(prefix [[unused]])
        set(exec_prefix [[${prefix}]])
        set(libdir [[${prefiix}/lib]])
        set(includedir [[${prefix}/include]])
        configure_file("${SOURCE_PATH}/libqcow.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libqcow.pc" @ONLY)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libqcow.pc" " -lqcow" " -llibqcow")
        if(NOT VCPKG_BUILD_TYPE)
            set(includedir [[${prefix}/../include]])
            configure_file("${SOURCE_PATH}/libqcow.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libqcow.pc" @ONLY)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libqcow.pc" " -lqcow" " -llibqcow")
        endif()
    endblock()

else()
    vcpkg_list(SET options)
    if("nls" IN_LIST FEATURES)
        vcpkg_list(APPEND options "--enable-nls")
    else()
        vcpkg_list(APPEND options "--disable-nls")
    endif()

    if(VCPKG_TARGET_IS_ANDROID)
        list(APPEND options --with-pthread=no) # may have pthread but not -lpthread
    endif()

    x_vcpkg_pkgconfig_get_modules(PREFIX libcrypto MODULES libcrypto LIBS)
    
    vcpkg_configure_make(
        COPY_SOURCE
        DETERMINE_BUILD_TRIPLET
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            ${options}
            # Must not run conftest. Result from openssl 3.2 x64-linux.
            ac_cv_openssl_xts_duplicate_keys=yes
            # Don't use system lib
            --with-libfuse=no
            # "no" means: use vendored libyal lib
            --with-libbfio=no
            --with-libcaes=no
            --with-libcdata=no
            --with-libcerror=no
            --with-libcfile=no
            --with-libclocale=no
            --with-libcnotify=no
            --with-libcpath=no
            --with-libcsplit=no
            --with-libcthreads=no
            --with-libfcache=no
            --with-libfdata=no
            --with-libuna=no
        OPTIONS_RELEASE
            "LIBS=${libcrypto_LIBS_RELEASE} \$LIBS"
        OPTIONS_DEBUG
            "LIBS=${libcrypto_LIBS_DEBUG} \$LIBS"
        )
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/libqcowConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libqcow")
file(INSTALL "${CURRENT_PORT_DIR}/unofficial-libqcow-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libqcow")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${SOURCE_PATH}/include/libqcow/extern.h" "defined( LIBQCOW_DLL_IMPORT )" "1")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man3"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
