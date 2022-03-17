if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_ANDROID)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/iconv")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/iconv")
    return()
endif()

set(LIBICONV_VERSION 1.16)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libiconv/libiconv-${LIBICONV_VERSION}.tar.gz"
    FILENAME "libiconv-${LIBICONV_VERSION}.tar.gz"
    SHA512 365dac0b34b4255a0066e8033a8b3db4bdb94b9b57a9dca17ebf2d779139fe935caf51a465d17fd8ae229ec4b926f3f7025264f37243432075e5583925bb77b7
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIBICONV_VERSION}
    PATCHES
        0002-Config-for-MSVC.patch
        0003-Add-export.patch
        0004-ModuleFileName.patch
)

if (NOT VCPKG_TARGET_IS_ANDROID)
    list(APPEND OPTIONS --enable-relocatable)
endif()

vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}"
                     DETERMINE_BUILD_TRIPLET
                     USE_WRAPPERS
                     OPTIONS
                        --enable-extra-encodings
                        --without-libiconv-prefix 
                        --without-libintl-prefix
                        ${OPTIONS}
                    )
vcpkg_install_make()

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/iconv")

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}") # share contains unneeded doc files

file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
