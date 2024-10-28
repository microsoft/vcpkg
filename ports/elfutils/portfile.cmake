vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceware.org/pub/elfutils/${VERSION}/elfutils-${VERSION}.tar.bz2"
         "https://www.mirrorservice.org/sites/sourceware.org/pub/elfutils/${VERSION}/elfutils-${VERSION}.tar.bz2"
    FILENAME "elfutils-${VERSION}.tar.bz2"
    SHA512 e22d85f25317a79b36d370347e50284c9120c86f9830f08791b7b6a7b4ad89b9bf4c7c71129133b8d193a0edffb2a2c17987b7e48428b9670aff5ce918777e04
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        disable-werror.diff
        link-libs.diff
        rpath-link.diff
        static-tools.diff
)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

set(options "")

if(NOT "libdebuginfod" IN_LIST FEATURES)
    list(APPEND options "--enable-libdebuginfod=no")
endif()

if("nls" IN_LIST FEATURES)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")
else()
    set(ENV{AUTOPOINT} true) # the program
    list(APPEND options "--enable-nls=no")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${options}
        --enable-debuginfod=no
        --with-bzlib
        --with-lzma
        --with-zlib
        --with-zstd
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/etc/debuginfod"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(wrong_suffix "${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
else()
    set(wrong_suffix "${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
endif()
file(GLOB wrong_libs
    "${CURRENT_PACKAGES_DIR}/lib/*${wrong_suffix}"
    "${CURRENT_PACKAGES_DIR}/lib/*${wrong_suffix}.*"
    "${CURRENT_PACKAGES_DIR}/debug/lib/*${wrong_suffix}"
    "${CURRENT_PACKAGES_DIR}/debug/lib/*${wrong_suffix}.*"
)
file(REMOVE ${wrong_libs})

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/eu-make-debug-archive" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
if("libdebuginfod" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/profile.d/debuginfod.sh" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../..")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/profile.d/debuginfod.csh" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../..")
endif()
 
vcpkg_install_copyright(
    COMMENT [[
The libraries are subject to LGPL-3.0-or-later OR GPL-2.0-or-later (cf. COPYING-LGPLV3, COPYING-GPLV2).
The tools are subject to GPL-3.0-or-later (cf. COPYING).
For additional terms, see the following source files:
- doc/readelf.1 (GFDL-NIV-1.3)
- lib/stdatomic-fbsd.h (BSD-2-Clause)
- libcpu/i386_parse.* (GPL-3+ with Bison exception)
- libelf/dl-hash.h (LGPL-2.1+)
- libelf/elf.h (LGPL-2.1+)
]]
    FILE_LIST
        "${SOURCE_PATH}/COPYING-LGPLV3"
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/COPYING-GPLV2"
)
