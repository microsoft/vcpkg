if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libressl/copyright"
    OR EXISTS "${CURRENT_INSTALLED_DIR}/share/boringssl/copyright")
    message(FATAL_ERROR "Can't build openssl if libressl/boringssl is installed. Please remove libressl/boringssl, and try install openssl again if you need it.")
endif()

if(VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openssl/openssl
    REF "openssl-${VERSION}"
    SHA512 d5f78b2e9d7b7b4787c976c4f832b1448bbadf5f9d398a50ef98053f92501768d000aa73673af200568aef4c8a491442ebbee8c43556838f465d4f91dfc2b5ad
    PATCHES
        cmake-config.patch
        command-line-length.patch
        script-prefix.patch
        asm-armcap.patch
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
    no-tests
    no-docs
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

if("weak-ssl-ciphers" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS enable-weak-ssl-ciphers)
endif()

if("ssl3" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS enable-ssl3)
    vcpkg_list(APPEND CONFIGURE_OPTIONS enable-ssl3-method)
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

if (NOT "${VERSION}" MATCHES [[^([0-9]+)\.([0-9]+)\.([0-9]+)$]])
    message(FATAL_ERROR "Version regex did not match.")
endif()
set(OPENSSL_VERSION_MAJOR "${CMAKE_MATCH_1}")
set(OPENSSL_VERSION_MINOR "${CMAKE_MATCH_2}")
set(OPENSSL_VERSION_FIX "${CMAKE_MATCH_3}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
