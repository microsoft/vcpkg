vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FastCGI-Archives/fcgi2
    REF fc8c6547ae38faf9926205a23075c47fbd4370c8
    SHA512   7f27b1060fbeaf0de9b8a43aa4ff954a004c49e99f7d6ea11119a438fcffe575fb469ba06262e71ac8132f92e74189e2097fd049595a6a61d4d5a5bac2733f7a
    HEAD_REF master
    PATCHES
        dll.patch
)

# Check build system first
if(VCPKG_TARGET_IS_OSX)
  message("${PORT} currently requires the following library from the system package manager:\n    gettext\n    automake\n    libtool\n\nIt can be installed with brew install gettext automake libtool")
elseif(NOT VCPKG_TARGET_IS_WINDOWS)
  message("${PORT} currently requires the following library from the system package manager:\n    gettext\n    automake\n    libtool\n    libtool-bin\n\nIt can be installed with apt-get install gettext automake libtool libtool-bin")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    COPY_SOURCE
    OPTIONS
        --disable-examples
)

vcpkg_install_make()

# switch ${PORT} into /${PORT}
file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include2")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include2" "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_fixup_pkgconfig()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/fcgi.pc" "Version: 2.4.2\n" "Version: 2.4.2\nCflags: -I\"\${prefix}/include/fastcgi\"\n")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/fcgi.pc" "Version: 2.4.2\n" "Version: 2.4.2\nCflags: -I\"\${prefix}/../include/fastcgi\"\n")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${PORT}/fcgiapp.h" "ifdef LIBFCGI_DLL_IMPORT" "if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${PORT}/fcgios.h" "ifdef LIBFCGI_DLL_IMPORT" "if 1")
endif()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.TERMS" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
