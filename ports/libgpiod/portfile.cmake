vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
    REF dfc5d361e6748d5f48b706e5c4ac949d133b5470 # v1.6.3
    PATCHES
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
    list(APPEND OPTIONS CC=${VCPKG_DETECTED_CMAKE_C_COMPILER})
    if (VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        list(APPEND OPTIONS ac_cv_func_malloc_0_nonnull=yes)
        list(APPEND OPTIONS ac_cv_func_realloc_0_nonnull=yes)
    endif()
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${OPTIONS}
        --enable-tools=no
        --enable-tests=no
        --enable-bindings-cxx=no
        --enable-bindings-python=no
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)