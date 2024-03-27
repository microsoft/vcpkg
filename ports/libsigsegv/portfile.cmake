set(LIBSIGSEGV_VER "2.14")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libsigsegv/libsigsegv-${LIBSIGSEGV_VER}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libsigsegv/libsigsegv-${LIBSIGSEGV_VER}.tar.gz"
    FILENAME "libsigsegv-${LIBSIGSEGV_VER}.tar.gz"
    SHA512 423dade56636fe38356f0976e1288178cb1c7c059615e9f70ad693a1e4194feba47a583b0804717e95a866da271b1ea5f80083c54a121577983dd23e5aa9f056
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}")
else ()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
#            --host=x86_64-w64-mingw32 --prefix=/usr/local/msvc64
#            CC="$HOME/msvc/compile cl -nologo"
#            CFLAGS="-MD"
#            CXX="$HOME/msvc/compile cl -nologo"
#            CXXFLAGS="-MD"
#            CPPFLAGS="-D_WIN32_WINNT=$win32_target -I/usr/local/msvc64/include"
#            LDFLAGS="-L/usr/local/msvc64/lib"
#            LD="link"
#            NM="dumpbin -symbols"
#            STRIP=":"
#            AR="$HOME/msvc/ar-lib lib"
#            RANLIB=":"
             ${options}
    )
endif()

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
