set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(LIBTOOL_VERSION_STR "2.4.7")
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/libtool/libtool-${LIBTOOL_VERSION_STR}.tar.xz"
    FILENAME "gnu-libtool-${LIBTOOL_VERSION_STR}.tar.xz"
    SHA512 47f4c6de40927254ff9ba452612c0702aea6f4edc7e797f0966c8c6bf0340d533598976cdba17f0bdc64545572e71cd319bbb587aa5f47cd2e7c1d96f873a3da
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0101-simplify-deplib-check.patch # inspired by MSYS2's 0005-Fix-seems-to-be-moved.patch
        0102-win32-libid-type.patch      # inspired by MSYS2's 0008-tests.patch
        # Originally from MSYS2 mingw-w64-libtool 2.4.6-20, refreshed.
        # (Now in MSYS2 libtool and mingw-w64-libltdl.)
        0002-cygwin-mingw-Create-UAC-manifest-files.mingw.patch
        0003-Pass-various-runtime-library-flags-to-GCC.mingw.patch
        0006-Fix-strict-ansi-vs-posix.patch
        0007-fix-cr-for-awk-in-configure.all.patch
        0011-Pick-up-clang_rt-static-archives-compiler-internal-l.patch
        0012-Prefer-response-files-over-linker-scripts-for-mingw-.patch
        0013-Allow-statically-linking-compiler-support-libraries-.patch
        0014-Support-llvm-objdump-f-output.patch
)

set(OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    string(APPEND VCPKG_C_FLAGS " -D_CRT_SECURE_NO_WARNINGS")
    string(APPEND VCPKG_CXX_FLAGS " -D_CRT_SECURE_NO_WARNINGS")
    if(NOT VCPKG_TARGET_IS_MINGW)
        list(APPEND OPTIONS
            ac_cv_header_dirent_h=no # Ignore vcpkg port dirent
        )
    endif()
endif()

# Running `libtoolize` during `autoreconf` breaks the automake step.
# Replace `libtoolize` by `true`, as in libtool's bootstrap.conf.
set(ENV{LIBTOOLIZE} "true")
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-ltdl-install
        "HELP2MAN=echo Skipping help2man"
        ${OPTIONS}
)
vcpkg_install_make()
foreach(tool IN ITEMS libtool libtoolize)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${tool}" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../.." )
endforeach()
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/x_vcpkg_update_libtool.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/x_vcpkg_update_libtool.cmake" @ONLY)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
