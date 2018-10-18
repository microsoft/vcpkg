if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "This port is only for openssl on Unix-like systems")
endif()

include(vcpkg_common_functions)
set(OPENSSL_VERSION 1.0.2p)
set(MASTER_COPY_SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openssl-${OPENSSL_VERSION})

vcpkg_find_acquire_program(PERL)

vcpkg_download_distfile(OPENSSL_SOURCE_ARCHIVE
    URLS "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" "https://www.openssl.org/source/old/1.0.2/openssl-${OPENSSL_VERSION}.tar.gz"
    FILENAME "openssl-${OPENSSL_VERSION}.tar.gz"
    SHA512 958c5a7c3324bbdc8f07dfb13e11329d9a1b4452c07cf41fbd2d42b5fe29c95679332a3476d24c2dc2b88be16e4a24744aba675a05a388c0905756c77a8a2f16
)

vcpkg_extract_source_archive(${OPENSSL_SOURCE_ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${MASTER_COPY_SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/ConfigureIncludeQuotesFix.patch
            ${CMAKE_CURRENT_LIST_DIR}/STRINGIFYPatch.patch
            ${CMAKE_CURRENT_LIST_DIR}/EmbedSymbolsInStaticLibsZ7.patch
)

if(CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
    set(MAKE ${MSYS_ROOT}/usr/bin/make.exe)
else()
    find_program(MAKE make)
    if(NOT MAKE)
        message(FATAL_ERROR "Could not find make. Please install it through your package manager.")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${CMAKE_CURRENT_LIST_DIR}
    PREFER_NINJA
    OPTIONS
        -DSOURCE_PATH=${MASTER_COPY_SOURCE_PATH}
        -DPERL=${PERL}
        -DMAKE=${MAKE}
    OPTIONS_RELEASE
        -DINSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(GLOB HEADERS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/include/openssl/*.h)
set(RESOLVED_HEADERS)
foreach(HEADER ${HEADERS})
    get_filename_component(X "${HEADER}" REALPATH)
    list(APPEND RESOLVED_HEADERS "${X}")
endforeach()

file(INSTALL ${RESOLVED_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/openssl)
file(INSTALL ${MASTER_COPY_SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openssl-unix RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/openssl)
endif()

vcpkg_test_cmake(PACKAGE_NAME OpenSSL MODULE)
