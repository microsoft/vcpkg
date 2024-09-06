vcpkg_download_distfile(ARCHIVE
    URLS https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-${VERSION}.tar.gz
    FILENAME libgpiod-${VERSION}.tar.gz
    SHA512 e3401d9d5b48e4da29494a5fa7738df80b1db7cb7e75e24067d44cc4bae5661cf7364e9722b5f588d4e813da8b2abd18dde29d5a118049b4a36d2a1df0c432a0
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND OPTIONS --enable-shared=yes)
    list(APPEND OPTIONS --enable-static=no)
else()
    list(APPEND OPTIONS --enable-shared=no)
    list(APPEND OPTIONS --enable-static=yes)
endif()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if (VCPKG_DETECTED_CMAKE_CROSSCOMPILING STREQUAL "TRUE")
    list(APPEND OPTIONS "CC=${VCPKG_DETECTED_CMAKE_C_COMPILER}")
    if (VCPKG_TARGET_IS_LINUX AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm"))
        list(APPEND OPTIONS ac_cv_func_malloc_0_nonnull=yes)
        list(APPEND OPTIONS ac_cv_func_realloc_0_nonnull=yes)
    endif()
endif()

if ("cxx-bindings" IN_LIST FEATURES)
  set(USE_CXX_BINDINGS yes)
else()
  set(USE_CXX_BINDINGS no)
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        --enable-tools=no
        --enable-tests=no
        --enable-bindings-cxx=${USE_CXX_BINDINGS}
        --enable-bindings-python=no
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
