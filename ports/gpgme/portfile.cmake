set(GPGME_BRANCH 1.18)
set(GPGME_VERSION ${GPGME_BRANCH}.0)

vcpkg_download_distfile(ARCHIVE
     URLS "https://www.gnupg.org/ftp/gcrypt/${PORT}/${PORT}-${GPGME_VERSION}.tar.bz2"
     FILENAME "${PORT}-${GPGME_VERSION}.tar.bz2"
     SHA512 c0cb0b337d017793a15dd477a7f5eaef24587fcda3d67676bf746bb342398d04792c51abe3c26ae496e799c769ce667d4196d91d86e8a690d02c6718c8f6b4ac
 )

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-build-Update-ax_cxx_compile_stdcxx-macro.patch
        0001-cpp-Fix-building-with-C-11.patch
        0001-qt-Fix-building-with-C-11.patch
        0001-Guard-unistd.h-includes.patch                      # https://dev.gnupg.org/D561
        disable-tests.patch                                     # https://dev.gnupg.org/D560
        disable-docs.patch
        windows_unistd_io.patch
        versioninfo.patch
        0001-Use-OS-agnostic-string-comparison-functions.patch
        0001-Guard-sys-time.h-include-with-HAVE_SYS_TIME_H.patch
        0001-Guiard-sys-types.h-include-with-HAVE_SYS_TYPES_H.patch
        0001-Guard-strings.h.patch
        0001-lang-cpp-Use-gpgme_ssize_t-gpgme_off_t-consistently.patch
        0001-lang-cpp-add-missing-string-includes.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    if (NOT VCPKG_TARGET_IS_MINGW)
        set(EXTRA_LIBS "LIBS=\$LIBS -lgetopt")

        # set(ENV{CC} "compile clang-cl.exe")
        # set(ENV{CXX} "compile clang-cl.exe")
        set(windows_defs "-D__STDC__=1 -DWIN32 -D_WIN64")
        string(APPEND windows_defs " -D_WIN32_WINNT=0x0A00 -DWINVER=0x0A00") # tweak for targeted windows
        string(APPEND windows_defs " -D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE")
        string(APPEND windows_defs " -D_ATL_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS")
        string(APPEND windows_defs " -D_CRT_INTERNAL_NONSTDC_NAMES -D_CRT_DECLARE_NONSTDC_NAMES") # due to -D__STDC__=1 required for e.g. _fopen -> fopen and other not underscored functions/defines
        string(APPEND windows_defs " -D_FORCENAMELESSUNION") # Due to -D__STDC__ to access tagVARIANT members (ffmpeg)
        string(APPEND windows_defs " -Wno-narrowing") # https://dev.gnupg.org/T6150
        
        set(EXTRA_CFLAGS "CFLAGS=\$CFLAGS ${windows_defs} -std:c11")
        set(EXTRA_CPPFLAGS "CPPFLAGS=\$CPPFLAGS ${windows_defs}")
        set(ENV{LD} "lld-link.exe")
        set(ENV{DLLTOOL} "llvm-dlltool.exe")
        set(ENC{AR} "llvm-lib.exe")
    endif()
endif()

list(REMOVE_ITEM FEATURES core)
string(REPLACE ";" "," LANGUAGES "${FEATURES}")

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin")

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-gpgconf-test
        --disable-gpg-test
        --disable-gpgsm-test
        --disable-g13-test
        --disable-glibtest
        --enable-languages=${LANGUAGES}
        --with-libgpg-error-prefix=${CURRENT_INSTALLED_DIR}/tools/libgpg-error
        --with-libassuan-prefix=${CURRENT_INSTALLED_DIR}/tools/libassuan
        ${EXTRA_LIBS}
        ${EXTRA_CFLAGS}
        ${EXTRA_CPPFLAGS}
)

vcpkg_install_make()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Gpgmepp)
vcpkg_copy_pdbs() 

# We have no dependency on glib, so remove this extra .pc file
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gpgme-glib.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gpgme-glib.pc")
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gpgme/bin/gpgme-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
if (NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gpgme/debug/bin/gpgme-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
