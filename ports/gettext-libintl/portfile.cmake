if(VCPKG_TARGET_IS_LINUX)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    if(NOT EXISTS "/usr/include/libintl.h")
        message(FATAL_ERROR
            "When targeting Linux, `libintl.h` is expected to come from the C Runtime Library (glibc). "
            "Please use \"sudo apt-get install libc-dev\" or the equivalent to install development files."
        )
    endif()
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    return()
endif()

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/gettext/gettext-${VERSION}.tar.gz"
         "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gettext/gettext-${VERSION}.tar.gz"
    FILENAME "gettext-${VERSION}.tar.gz"
    SHA512 ccd43a43fab3c90ed99b3e27628c9aeb7186398153b137a4997f8c7ddfd9729b0ba9d15348567e5206af50ac027673d2b8a3415bb3fc65f87ad778f85dc03a05
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        # Shared with port gettext
        android.patch
        uwp.patch
        0003-Fix-win-unicode-paths.patch
)

if(VCPKG_HOST_IS_WINDOWS)
    message(STATUS "Modifying 'configure' to use fast bash variable expansion")
    set(ENV{CONFIG_SHELL} "/usr/bin/bash")
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}"
            "-DSOURCE_DIRS=gettext-runtime"
            -P "${CMAKE_CURRENT_LIST_DIR}/bashify.cmake"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "bashify-${TARGET_TRIPLET}"
    )
endif()

set(OPTIONS
    --no-recursion
    --enable-relocatable #symbol duplication with glib-init.c?
    --enable-c++
    --disable-acl
    --disable-csharp
    --disable-curses
    --disable-java
    --disable-libasprintf
    --disable-openmp
    --with-included-gettext
    --without-libintl-prefix
    --disable-dependency-tracking # Faster ?
    ac_cv_path_DVIPS=:
    ac_cv_path_GMSGFMT=:
    ac_cv_path_MSGFMT=:
    ac_cv_path_MSGMERGE=:
    ac_cv_path_TEXI2PDF=:
    ac_cv_path_XGETTEXT=:
    ac_cv_prog_INTLBISON=:
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS
        # Avoid unnecessary tests.
        am_cv_func_iconv_works=yes
        "--with-libiconv-prefix=${CURRENT_INSTALLED_DIR}"
        ## This is required. For some reason these do not get correctly identified for release builds.
        ac_cv_func_wcslen=yes
        ac_cv_func_memmove=yes
    )
    if(NOT VCPKG_TARGET_IS_MINGW)
        list(APPEND OPTIONS
            # Don't take from port getopt-win32
            ac_cv_header_getopt_h=no
            # Don't take from port pthreads
            ac_cv_header_pthread_h=no
            # Detected 'no' everywhere except x64-windows-static
            ac_cv_func_snprintf=no
            # Detected x64 values for gnulib, overriding guesses for cross builds
            gl_cv_func_mbrtowc_empty_input=no
            # Detected x64 values for gettext, overriding guesses for x86 & x64-uwp
            gt_cv_int_divbyzero_sigfpe=no
        )
    endif()
endif()

file(REMOVE "${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-rel.log")
file(REMOVE "${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-dbg.log")
vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}/gettext-runtime"
    DETERMINE_BUILD_TRIPLET
    USE_WRAPPERS
    OPTIONS
        ${OPTIONS}
    OPTIONS_RELEASE
        "--cache-file=${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-rel.log"
    OPTIONS_DEBUG
        "--cache-file=${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-dbg.log"
    )

# This helps with Windows build times, but should work everywhere in vcpkg.
# - Avoid an extra command to move a temporary file, we are building out of source.
# - Avoid a subshell just to add comments, the build dir is temporary.
# - Avoid cygpath -w when other tools handle this for us.
file(GLOB_RECURSE makefiles "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}*/intl/Makefile")
foreach(file IN LISTS makefiles)
    file(READ "${file}" rules)
    string(REGEX REPLACE "(\n\ttest -d [^ ]* [|][|] [\$][(]MKDIR_P[)][^\n;]*)(\n\t)" "\\1 || exit 1 ; \\\\\\2" rules "${rules}")
    string(REGEX REPLACE "(\n\t){ echo '/[*] [^*]* [*]/'; \\\\\n\t  cat ([^;\n]*); \\\\\n\t[}] > [\$]@-t\n\tmv -f [\$]@-t ([\$]@\n)" "\\1cp \\2 \\3" rules "${rules}")
    string(REGEX REPLACE " > [\$]@-t\n\t[\$][(]AM_V_at[)]mv [\$]@-t ([\$]@\n)" "> \\1" rules "${rules}")
    string(REGEX REPLACE "([\$}[(]COMPILE[)] -c -o [\$]@) `[\$][(]CYGPATH_W[)] '[\$]<'`" "\\1 \$<" rules "${rules}")
    file(WRITE "${file}" "${rules}")
endforeach()

vcpkg_install_make(SUBPATH intl)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/intl")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/gettext-runtime/intl/COPYING.LIB")
