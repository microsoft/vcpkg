set(GETTEXT_VERSION 0.20.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz"
    FILENAME "gettext-${GETTEXT_VERSION}.tar.gz"
    SHA512 af6d74986da285df0bdd59524bdf01bb12db448e5ea659dda3b60b660c4a9063c80e8c74cc8751334e065e98348ee0db0079e43c67d485a15e86ae236115fe06
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GETTEXT_VERSION}
    PATCHES
        0001-Fix-macro-definitions.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
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
        OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
    )

    vcpkg_install_cmake()
    vcpkg_copy_pdbs()

    vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-gettext TARGET_PATH share/unofficial-gettext)
else()
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
    )

    vcpkg_install_make()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-gettext-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-gettext)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
