if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

#Based on https://github.com/winlibs/gettext

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gettext-0.19)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnu.org/pub/gnu/gettext/gettext-0.19.tar.gz"
    FILENAME "gettext-0.19.tar.gz"
    SHA512 a5db035c582ff49d45ee6eab9466b2bef918e413a882019c204a9d8903cb3770ddfecd32c971ea7c7b037c7b69476cf7c56dcabc8b498b94ab99f132516c9922
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/config.win32.h
    DESTINATION ${SOURCE_PATH}/gettext-runtime
)
file(REMOVE ${SOURCE_PATH}/gettext-runtime/intl/libgnuintl.h ${SOURCE_PATH}/gettext-runtime/config.h)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/libgnuintl.win32.h DESTINATION ${SOURCE_PATH}/gettext-runtime/intl)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-Fix-macro-definitions.patch"
            "${CMAKE_CURRENT_LIST_DIR}/0002-Fix-uwp-build.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/gettext-runtime
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gettext)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gettext/COPYING ${CURRENT_PACKAGES_DIR}/share/gettext/copyright)

vcpkg_copy_pdbs()
