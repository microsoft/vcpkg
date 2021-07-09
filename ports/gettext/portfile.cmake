if(VCPKG_TARGET_IS_LINUX)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    if (NOT EXISTS "/usr/include/libintl.h")
        message(FATAL_ERROR "Please use command \"sudo apt-get install gettext\" to install gettext on linux.")
    endif()
    return()
else()
    set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
endif()

#Based on https://github.com/winlibs/gettext

set(GETTEXT_VERSION 0.21)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz"
    FILENAME "gettext-${GETTEXT_VERSION}.tar.gz"
    SHA512 bbe590c5dd3580c75bf30ff768da99a88eb8d466ec1ac9eea20be4cab4357ecf72448e6b81b47425e39d50fa6320ba426632914d7898dfebb4f159abc39c31d1
)
if(VCPKG_TARGET_IS_UWP)
    set(PATCHES uwp_remove_localcharset.patch)
endif()
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GETTEXT_VERSION}
    PATCHES
        0002-Fix-uwp-build.patch
        0003-Fix-win-unicode-paths.patch
        rel_path.patch
        android.patch
        ${PATCHES}
)
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_PATH ${BISON} DIRECTORY)
vcpkg_add_to_path(${BISON_PATH})

if(VCPKG_TARGET_IS_WINDOWS)
    # This is required. For some reason these do not get correctly identified for release builds. 
    list(APPEND OPTIONS ac_cv_func_wcslen=yes
                        ac_cv_func_memmove=yes
                        #The following are required for a full gettext built.
                        # Left here for future reference. 
                        gl_cv_func_printf_directive_n=no #segfaults otherwise with popup window
                        ac_cv_func_memset=yes #not detected in release builds 
                        ac_cv_header_pthread_h=no
                        ac_cv_header_dirent_h=no
                        )
endif()
set(ADDITIONAL_CONFIGURE_OPTIONS)
set(ADDITIONAL_INSTALL_OPTIONS)
if("tools" IN_LIST FEATURES)
    set(BUILD_SOURCE_PATH ${SOURCE_PATH})
    set(ADDITIONAL_CONFIGURE_OPTIONS ADDITIONAL_MSYS_PACKAGES gzip)
else()
    set(BUILD_SOURCE_PATH ${SOURCE_PATH}/gettext-runtime) # Could be its own port
    set(ADDITIONAL_INSTALL_OPTIONS SUBPATH "/intl")
endif()
vcpkg_configure_make(SOURCE_PATH ${BUILD_SOURCE_PATH}
                     DETERMINE_BUILD_TRIPLET
                     USE_WRAPPERS
                     ADD_BIN_TO_PATH    # So configure can check for working iconv
                     OPTIONS --enable-relocatable #symbol duplication with glib-init.c?
                             --enable-c++
                             --disable-java
                             ${OPTIONS}
                     ${ADDITIONAL_CONFIGURE_OPTIONS}
                    )
vcpkg_install_make(${ADDITIONAL_INSTALL_OPTIONS})

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gettext)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gettext/COPYING ${CURRENT_PACKAGES_DIR}/share/gettext/copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(GNU_DLL_PATHS lib/ debug/lib/)
set(GNU_DLL_NAME GNU.Gettext.dll) #C# dll?
foreach(DLL_PATH IN LISTS GNU_DLL_PATHS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/${DLL_PATH}${GNU_DLL_NAME}")
       file(REMOVE "${CURRENT_PACKAGES_DIR}/${DLL_PATH}${GNU_DLL_NAME}")
    endif()
endforeach()

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/intl)
