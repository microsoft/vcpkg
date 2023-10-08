# This port is just to provide gettext tools and build data, not libs.
# The "core" feature depends on port gettext-libintl which provides libintl.
# The "core" feature also installs enough for running autoreconf.
# The actual tools are only enabled by opt-in features.
# These features are typically used as a host dependency.
# For fast builds in particular on Windows, the following choices are made:
# - only release build type
# - namespacing disabled (windows only)
# - configuration cache
# - using preinstalled gettext-libintl
# - skipping some subdirs
set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/gettext/gettext-${VERSION}.tar.gz"
         "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gettext/gettext-${VERSION}.tar.gz"
    FILENAME "gettext-${VERSION}.tar.gz"
    SHA512 ccd43a43fab3c90ed99b3e27628c9aeb7186398153b137a4997f8c7ddfd9729b0ba9d15348567e5206af50ac027673d2b8a3415bb3fc65f87ad778f85dc03a05
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        # shared with port gettext-libintl
        android.patch
        uwp.patch
        0003-Fix-win-unicode-paths.patch
        # unique to port gettext
        win-gethostname.patch
        rel_path.patch
        subdirs.patch
        parallel-gettext-tools.patch
        macosx-libs.patch
)

set(subdirs "")
if("runtime-tools" IN_LIST FEATURES)
    string(APPEND subdirs " gettext-runtime")
endif()
if("tools" IN_LIST FEATURES)
    string(APPEND subdirs " libtextstyle gettext-tools")
endif()
if(subdirs)
    set(ENV{VCPKG_GETTEXT_SUBDIRS} "${subdirs}")

    vcpkg_find_acquire_program(BISON)
    get_filename_component(BISON_PATH "${BISON}" DIRECTORY)
    vcpkg_add_to_path("${BISON_PATH}")

    if(VCPKG_HOST_IS_WINDOWS)
        message(STATUS "Modifying build system for less forks")
        set(ENV{CONFIG_SHELL} "/usr/bin/bash")
        vcpkg_execute_required_process(
            COMMAND "${CMAKE_COMMAND}"
                "-DSOURCE_DIRS=.;gettext-runtime;libtextstyle;gettext-tools"
                -P "${CMAKE_CURRENT_LIST_DIR}/bashify.cmake"
            WORKING_DIRECTORY "${SOURCE_PATH}"
            LOGNAME "bashify-${TARGET_TRIPLET}"
        )
    endif()

    set(OPTIONS
        --enable-relocatable #symbol duplication with glib-init.c?
        --enable-c++
        --disable-acl
        --disable-csharp
        --disable-curses
        --disable-java
        --disable-openmp
        --disable-dependency-tracking
        # Avoiding system dependencies and unnecessary tests
        --with-included-glib
        --with-included-libxml # libtextstyle won't use external libxml
        --with-included-libunistring
        --with-installed-libtextstyle=no
        --without-cvs
        --without-emacs
        --without-git
        --without-libcurses-prefix
        --without-libncurses-prefix
        --without-libtermcap-prefix
        --without-libxcurses-prefix
    )
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND OPTIONS
            # Faster, but not for export
            --disable-namespacing
            # Avoid unnecessary tests.
            am_cv_func_iconv_works=yes
            "--with-libiconv-prefix=${CURRENT_INSTALLED_DIR}"
            "--with-libintl-prefix=${CURRENT_INSTALLED_DIR}"
            # This is required. For some reason these do not get correctly identified for release builds.
            ac_cv_func_wcslen=yes
            ac_cv_func_memmove=yes
            # The following are required for a full gettext built (libintl and tools).
            gl_cv_func_printf_directive_n=no  # segfaults otherwise with popup window
            ac_cv_func_memset=yes             # not detected in release builds
        )
        if(NOT VCPKG_TARGET_IS_MINGW)
            list(APPEND OPTIONS
                # Don't take from port dirent
                ac_cv_header_dirent_h=no
                # Don't take from port getopt-win32
                ac_cv_header_getopt_h=no
                # Don't take from port pthreads
                ac_cv_header_pthread_h=no
                ac_cv_header_sched_h=no
                ac_cv_header_semaphore_h=no
                # Detected 'no' everywhere except x64-windows-static
                ac_cv_func_snprintf=no
                # Detected x64 values for gnulib, overriding guesses for cross builds
                gl_cv_func_fopen_mode_x=yes
                gl_cv_func_frexpl_works=yes
                gl_cv_func_getcwd_null=yes
                gl_cv_func_mbrtowc_empty_input=no
                gl_cv_func_mbsrtowcs_works=yes
                gl_cv_func_printf_flag_zero=yes
                gl_cv_func_printf_infinite_long_double=yes
                gl_cv_func_printf_precision=yes
                gl_cv_func_snprintf_truncation_c99=yes
                # Detected x64 values for gettext, overriding guesses for x86 & x64-uwp
                gt_cv_int_divbyzero_sigfpe=no
            )
        endif()
    endif()

    file(REMOVE "${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-rel.log")
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}"
        DETERMINE_BUILD_TRIPLET
        USE_WRAPPERS
        ADDITIONAL_MSYS_PACKAGES gzip
        OPTIONS
            ${OPTIONS}
        OPTIONS_RELEASE
            "--cache-file=${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-rel.log"
    )

    # This helps with Windows build times, but should work everywhere in vcpkg.
    # - Avoid an extra command to move a temporary file, we are building out of source.
    # - Avoid a subshell just to add comments, the build dir is temporary.
    # - Avoid cygpath -w when other tools handle this for us.
    file(GLOB_RECURSE makefiles "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}*/*Makefile")
    foreach(file IN LISTS makefiles)
        file(READ "${file}" rules)
        string(REGEX REPLACE "(\n\ttest -d [^ ]* [|][|] [\$][(]MKDIR_P[)][^\n;]*)(\n\t)" "\\1 || exit 1 ; \\\\\\2" rules "${rules}")
        string(REGEX REPLACE "(\n\t){ echo '/[*] [^*]* [*]/'; \\\\\n\t  cat ([^;\n]*); \\\\\n\t[}] > [\$]@-t\n\tmv -f [\$]@-t ([\$]@\n)" "\\1cp \\2 \\3" rules "${rules}")
        string(REGEX REPLACE " > [\$]@-t\n\t[\$][(]AM_V_at[)]mv [\$]@-t ([\$]@\n)" "> \\1" rules "${rules}")
        string(REGEX REPLACE "([\$}[(]COMPILE[)] -c -o [\$]@) `[\$][(]CYGPATH_W[)] '[\$]<'`" "\\1 \$<" rules "${rules}")
        file(WRITE "${file}" "${rules}")
    endforeach()

    vcpkg_install_make()
    vcpkg_copy_pdbs()
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    file(GLOB unix_runtime LIST_DIRECTORIES false
        "${CURRENT_PACKAGES_DIR}/lib/libgettext*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}*"
        "${CURRENT_PACKAGES_DIR}/lib/libtextstyle*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}*"
    )
    if(unix_runtime)
        file(INSTALL ${unix_runtime} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    endif()
    file(GLOB link_libs LIST_DIRECTORIES false "${CURRENT_PACKAGES_DIR}/lib/*" "${CURRENT_PACKAGES_DIR}/bin/*.dll")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include" ${link_libs})
endif()

if("tools" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/gettext/user-email" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../..")
else()
    # A fast installation of the autopoint tool and data, needed for autoconfig
    include("${CMAKE_CURRENT_LIST_DIR}/install-autopoint.cmake")
    install_autopoint()
endif()

# These files can be needed to run `autoreconf`.
# We want to install these files also for fast "core" builds without "tools".
# Cf. PACKAGING for the file list.
file(INSTALL
    "${SOURCE_PATH}/gettext-runtime/m4/gettext.m4"
    "${SOURCE_PATH}/gettext-runtime/m4/iconv.m4"
    "${SOURCE_PATH}/gettext-runtime/m4/intlmacosx.m4"
    "${SOURCE_PATH}/gettext-runtime/m4/nls.m4"
    "${SOURCE_PATH}/gettext-runtime/m4/po.m4"
    "${SOURCE_PATH}/gettext-runtime/m4/progtest.m4"
    "${SOURCE_PATH}/gettext-runtime/gnulib-m4/host-cpu-c-abi.m4"
    "${SOURCE_PATH}/gettext-runtime/gnulib-m4/lib-ld.m4"
    "${SOURCE_PATH}/gettext-runtime/gnulib-m4/lib-link.m4"
    "${SOURCE_PATH}/gettext-runtime/gnulib-m4/lib-prefix.m4"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/gettext/aclocal"
)

if(NOT VCPKG_CROSSCOMPILING)
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gettext")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/gettext-runtime/COPYING" "${SOURCE_PATH}/COPYING")
