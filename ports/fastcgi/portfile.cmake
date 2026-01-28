vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FastCGI-Archives/fcgi2
    REF "${VERSION}"
    SHA512   a8b49fe7d88fa5404ec6f9b9aba59f1c37c479820ba1ed7024260fe2539ff98dae9f71fb7c46192a257401b0eab1ce8cb6b2825286c85a73a33457f8cd9dd926
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${PORT}/fcgiapp.h" "ifdef LIBFCGI_DLL_IMPORT" "if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${PORT}/fcgios.h" "ifdef LIBFCGI_DLL_IMPORT" "if 1")
endif()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
