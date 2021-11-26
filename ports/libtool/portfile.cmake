set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(LIBTOOL_VERSION_STR "2.4.6")
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/libtool/libtool-${LIBTOOL_VERSION_STR}.tar.xz"
    FILENAME "gnu-libtool-${LIBTOOL_VERSION_STR}.tar.xz"
    SHA512 a6eef35f3cbccf2c9e2667f44a476ebc80ab888725eb768e91a3a6c33b8c931afc46eb23efaee76c8696d3e4eed74ab1c71157bcb924f38ee912c8a90a6521a4
)

set(PATCHES
    0100-mitigate-sed-quote-subst-slowdown.patch # From upstream 32f0df983
)
if(VCPKG_TARGET_IS_OSX)
    list(APPEND PATCHES
        0101-support-macos-11.patch # From upstream 9e8c8825
    )
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PATCHES
        # From MSYS2 mingw-w64-libtool 2.4.6-20, refreshed
        0002-cygwin-mingw-Create-UAC-manifest-files.mingw.patch
        0003-Pass-various-runtime-library-flags-to-GCC.mingw.patch
        0005-Fix-seems-to-be-moved.patch
        0006-Fix-strict-ansi-vs-posix.patch
        0007-fix-cr-for-awk-in-configure.all.patch
        0008-tests.patch
        0011-Pick-up-clang_rt-static-archives-compiler-internal-l.patch
        0012-Prefer-response-files-over-linker-scripts-for-mingw-.patch
        0013-Allow-statically-linking-compiler-support-libraries-.patch
        0014-Support-llvm-objdump-f-output.patch
    )
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES ${PATCHES}
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
