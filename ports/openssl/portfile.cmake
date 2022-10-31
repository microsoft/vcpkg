if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libressl/copyright"
    OR EXISTS "${CURRENT_INSTALLED_DIR}/share/boringssl/copyright")
    message(FATAL_ERROR "Can't build openssl if libressl/boringssl is installed. Please remove libressl/boringssl, and try install openssl again if you need it.")
endif()

if (VCPKG_TARGET_IS_LINUX)
    message(WARNING
[[openssl currently requires the following library from the system package manager:
    linux-headers
It can be installed on alpine systems via apk add linux-headers.]]
    )
endif()

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP)
    set(OPENSSL_PATCHES "${CMAKE_CURRENT_LIST_DIR}/windows/flags.patch")
endif()

vcpkg_download_distfile(
    ARCHIVE
    URLS
        https://www.openssl.org/source/openssl-3.0.7.tar.gz
    FILENAME openssl-3.0.7.tar.gz
    SHA512 6c2bcd1cd4b499e074e006150dda906980df505679d8e9d988ae93aa61ee6f8c23c0fa369e2edc1e1a743d7bec133044af11d5ed57633b631ae479feb59e3424
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES ${OPENSSL_PATCHES}
)

# vcpkg_from_github(
#     OUT_SOURCE_PATH SOURCE_PATH
#     REPO openssl/openssl
#     REF openssl-${VERSION}
#     SHA512 0
#     PATCHES ${OPENSSL_PATCHES}
# )

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

if(VCPKG_TARGET_IS_UWP)
    include("${CMAKE_CURRENT_LIST_DIR}/uwp/portfile.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/install-pc-files.cmake")
elseif(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    include("${CMAKE_CURRENT_LIST_DIR}/windows/portfile.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/install-pc-files.cmake")
else()
    include("${CMAKE_CURRENT_LIST_DIR}/unix/portfile.cmake")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
