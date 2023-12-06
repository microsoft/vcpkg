if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libressl/copyright"
    OR EXISTS "${CURRENT_INSTALLED_DIR}/share/boringssl/copyright")
    message(FATAL_ERROR "Can't build openssl if libressl/boringssl is installed. Please remove libressl/boringssl, and try install openssl again if you need it.")
endif()

if(VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

if (NOT "${VERSION}" MATCHES [[^([0-9]+)\.([0-9]+)\.([0-9]+)$]])
    message(FATAL_ERROR "Version regex did not match.")
endif()
set(OPENSSL_VERSION_MAJOR "${CMAKE_MATCH_1}")
set(OPENSSL_VERSION_MINOR "${CMAKE_MATCH_2}")
set(OPENSSL_VERSION_FIX "${CMAKE_MATCH_3}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openssl/openssl
    REF "openssl-${VERSION}"
    SHA512 04349ba554ddc5a9c26ff44714c1adca3c6431e98d11af5e7b6a5f58ed44e016da68c09cc53415716ab1936c6aaac04887ced470707dbc3f7816c04e06be69c1
    PATCHES
        disable-apps.patch
        disable-install-docs.patch
        script-prefix.patch
        windows/install-layout.patch
        windows/install-pdbs.patch
        unix/android-cc.patch
        unix/move-openssldir.patch
        unix/no-empty-dirs.patch
        unix/no-static-libs-for-shared.patch
)

vcpkg_list(SET CONFIGURE_OPTIONS
    enable-static-engine
    enable-capieng
    no-ssl3
    no-weak-ssl-ciphers
    no-tests
)

set(INSTALL_FIPS "")
if("fips" IN_LIST FEATURES)
    vcpkg_list(APPEND INSTALL_FIPS install_fips)
    vcpkg_list(APPEND CONFIGURE_OPTIONS enable-fips)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_list(APPEND CONFIGURE_OPTIONS shared)
else()
    vcpkg_list(APPEND CONFIGURE_OPTIONS no-shared no-module)
endif()

if(NOT "tools" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS no-apps)
endif()

if(DEFINED OPENSSL_USE_NOPINSHARED)
    vcpkg_list(APPEND CONFIGURE_OPTIONS no-pinshared)
endif()

if(OPENSSL_NO_AUTOLOAD_CONFIG)
    vcpkg_list(APPEND CONFIGURE_OPTIONS no-autoload-config)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    include("${CMAKE_CURRENT_LIST_DIR}/windows/portfile.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/install-pc-files.cmake")
else()
    include("${CMAKE_CURRENT_LIST_DIR}/unix/portfile.cmake")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
