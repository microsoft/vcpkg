set(GETTEXT_VERSION 0.19)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz"
    FILENAME "gettext-${GETTEXT_VERSION}.tar.gz"
    SHA512 a5db035c582ff49d45ee6eab9466b2bef918e413a882019c204a9d8903cb3770ddfecd32c971ea7c7b037c7b69476cf7c56dcabc8b498b94ab99f132516c9922
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GETTEXT_VERSION}
    PATCHES
        0001-Fix-macro-definitions.patch
        0002-Fix-uwp-build.patch
        0003-Fix-osx.patch
        0004-Fix-win-unicode-paths.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    file(COPY
        ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
        ${CMAKE_CURRENT_LIST_DIR}/config.win32.h
        ${CMAKE_CURRENT_LIST_DIR}/config.unix.h.in
        DESTINATION ${SOURCE_PATH}/gettext-runtime
    )
    file(REMOVE ${SOURCE_PATH}/gettext-runtime/intl/libgnuintl.h ${SOURCE_PATH}/gettext-runtime/config.h)

    file(COPY ${CMAKE_CURRENT_LIST_DIR}/libgnuintl.win32.h DESTINATION ${SOURCE_PATH}/gettext-runtime/intl)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}/gettext-runtime
        PREFER_NINJA
        OPTIONS_DEBUG
            -DDISABLE_INSTALL_HEADERS=ON
    )

    vcpkg_install_cmake()
    vcpkg_copy_pdbs()

    vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-gettext TARGET_PATH share/unofficial-gettext)
else()
    set(GETTEXT_EXTRA_OPTS)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(GETTEXT_EXTRA_OPTS ${GETTEXT_EXTRA_OPTS} --enable-shared)
    else()
        set(GETTEXT_EXTRA_OPTS ${GETTEXT_EXTRA_OPTS} --enable-static)
    endif()

    set(GETTEXT_EXTRA_OPTS ${GETTEXT_EXTRA_OPTS}
                           --enable-relocatable
                           --disable-nls
    )

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            ${GETTEXT_EXTRA_OPTS}
            --with-libiconv-prefix=${CURRENT_INSTALLED_DIR}
    )

    vcpkg_build_make(
        NO_PARALLEL_BUILD
        ENABLE_INSTALL
    )

    if (EXISTS ${CURRENT_PACKAGES_DIR}/lib/GNU.Gettext.dll)
        if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/bin)
            file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
        endif()
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/GNU.Gettext.dll ${CURRENT_PACKAGES_DIR}/bin/GNU.Gettext.dll)
    endif()
    if (EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/GNU.Gettext.dll)
        if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin)
            file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
        endif()
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/GNU.Gettext.dll ${CURRENT_PACKAGES_DIR}/debug/bin/GNU.Gettext.dll)
    endif()

    file(GLOB_RECURSE TOOLS_EXES ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    file(INSTALL ${TOOLS_EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/info/dir)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
