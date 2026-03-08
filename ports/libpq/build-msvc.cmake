function(build_msvc source_path)
    # Strip meson build to only compile client libraries and tools.
    # The full PostgreSQL meson build includes the server backend, timezone data,
    # PL languages, contrib modules, and tests - none of which we need.

    # src/meson.build: keep only bin (client tools) and interfaces (ecpg)
    file(WRITE "${source_path}/src/meson.build" [=[
subdir('bin')
subdir('interfaces')
]=])

    # src/bin/meson.build: only client tools (mirrors unix/no-server-tools.patch)
    file(WRITE "${source_path}/src/bin/meson.build" [=[
subdir('pg_amcheck')
subdir('pg_basebackup')
subdir('pg_config')
subdir('pg_dump')
subdir('pg_verifybackup')
subdir('pgbench')
subdir('pgevent')
subdir('psql')
subdir('scripts')
]=])

    # Main meson.build: skip contrib, tests, docs, and all post-build
    # test/install infrastructure. Commenting out individual subdir() calls is
    # insufficient because the test infrastructure section references many
    # variables defined in those subdirs (pg_regress, regress_module, docs, etc.).
    # Instead, truncate everything from the "all targets" section onward.
    vcpkg_replace_string("${source_path}/meson.build"
        "subdir('contrib')" "# subdir('contrib') # vcpkg: skip")
    vcpkg_replace_string("${source_path}/meson.build"
        "subdir('src/test')" "# subdir('src/test') # vcpkg: skip")
    vcpkg_replace_string("${source_path}/meson.build"
        "subdir('src/interfaces/ecpg/test')" "# subdir('src/interfaces/ecpg/test') # vcpkg: skip")
    vcpkg_replace_string("${source_path}/meson.build"
        "subdir('doc/src/sgml')" "# subdir('doc/src/sgml') # vcpkg: skip")

    # Truncate meson.build before the test/pseudo-target sections that reference
    # variables from skipped subdirs (pg_regress, regress_module, docs, etc.)
    file(READ "${source_path}/meson.build" meson_content)
    string(FIND "${meson_content}" "# all targets that require building code" truncate_pos)
    if(NOT truncate_pos EQUAL -1)
        string(SUBSTRING "${meson_content}" 0 ${truncate_pos} meson_content)
        file(WRITE "${source_path}/meson.build" "${meson_content}")
    endif()

    # Move extra_include_dirs after platform-specific includes so that
    # PostgreSQL's own headers (e.g. port/win32_msvc/dirent.h) take priority
    # over any conflicting headers from vcpkg dependencies.
    vcpkg_replace_string("${source_path}/meson.build"
        "postgres_inc_d += get_option('extra_include_dirs')" "# postgres_inc_d += get_option('extra_include_dirs') # vcpkg: moved below")
    vcpkg_replace_string("${source_path}/meson.build"
        "postgres_inc_d += 'src/include/port/win32_msvc'"
        "postgres_inc_d += 'src/include/port/win32_msvc'\n  postgres_inc_d += get_option('extra_include_dirs') # vcpkg: moved here for correct priority")

    # Prevent meson from detecting getopt-win32's <getopt.h> via extra_include_dirs.
    # That header renames optarg -> optarg_a via macros and declares them with
    # __declspec(dllimport), causing linker errors against the static libpgport.a
    # which defines plain optarg. It also provides struct option, which prevents
    # PostgreSQL's own getopt_long.h from defining it. PostgreSQL always uses its
    # own getopt on Windows (always_replace_getopt = true), so the external header
    # is unnecessary. Removing it from header_checks means:
    #   - HAVE_GETOPT_H is not set -> pg_getopt.h uses plain extern declarations
    #   - HAVE_STRUCT_OPTION is not set -> getopt_long.h provides struct option
    vcpkg_replace_string("${source_path}/meson.build"
        "'getopt.h'," "# 'getopt.h', # vcpkg: skip to avoid getopt-win32 header pollution")
    # The struct option check references cdata.get('HAVE_GETOPT_H') which would
    # fail if the key doesn't exist. Provide a default value of 0.
    vcpkg_replace_string("${source_path}/meson.build"
        "cdata.get('HAVE_GETOPT_H')" "cdata.get('HAVE_GETOPT_H', 0)")

    # Define generated_backend_sources (normally set in backend/meson.build,
    # referenced in conflict-checking code)
    vcpkg_replace_string("${source_path}/meson.build"
        "generated_backend_headers = []"
        "generated_backend_headers = []\ngenerated_backend_sources = []")

    # For static builds, remove __declspec(dllimport) from installed headers
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${source_path}/src/include/port/win32.h"
            "__declspec (dllimport)" "")
    endif()

    # Map vcpkg features to meson options
    vcpkg_list(SET MESON_OPTIONS)

    # Disable auto-detection so we don't pick up random system libraries
    list(APPEND MESON_OPTIONS -Dauto_features=disabled)

    # Features that map directly to meson option names
    foreach(option IN ITEMS icu lz4 zlib zstd)
        if(option IN_LIST FEATURES)
            list(APPEND MESON_OPTIONS -D${option}=enabled)
        endif()
    endforeach()

    # Features with different meson option names
    if("openssl" IN_LIST FEATURES)
        list(APPEND MESON_OPTIONS -Dssl=openssl)
    else()
        list(APPEND MESON_OPTIONS -Dssl=none)
    endif()
    if("xml" IN_LIST FEATURES)
        list(APPEND MESON_OPTIONS -Dlibxml=enabled)
    endif()
    if("xslt" IN_LIST FEATURES)
        list(APPEND MESON_OPTIONS -Dlibxslt=enabled)
    endif()
    if("nls" IN_LIST FEATURES)
        list(APPEND MESON_OPTIONS -Dnls=enabled)
        # Static intl depends on iconv, but PostgreSQL's meson build uses
        # cc.find_library('intl') which doesn't resolve transitive deps.
        # Patch to also link iconv when intl is found.
        vcpkg_replace_string("${source_path}/meson.build"
            "i18n = import('i18n')"
            "iconv_dep = cc.find_library('iconv', required: false, dirs: test_lib_d)\n    if iconv_dep.found()\n      libintl = declare_dependency(dependencies: [libintl, iconv_dep])\n    endif\n    i18n = import('i18n')")
    endif()
    # plpython requires matching debug/release Python libraries.
    # vcpkg's Python is release-only, so only enable for release builds.
    vcpkg_list(SET MESON_OPTIONS_RELEASE)
    vcpkg_list(SET MESON_OPTIONS_DEBUG)
    if("python" IN_LIST FEATURES)
        if(VCPKG_CROSSCOMPILING)
            # plpython can't be configured when cross-compiling because meson
            # needs to run the Python interpreter at configure time, but the
            # target binary won't execute on the build host.
            message(STATUS "Disabling plpython for cross-compilation build")
            list(APPEND MESON_OPTIONS -Dplpython=disabled)
        else()
            # Use the vcpkg python3 interpreter (which has matching dev libraries)
            # instead of the standalone tools Python (which has no SDK).
            string(REPLACE [[\]] [[/]] VCPKG_PYTHON3_PATH "${CURRENT_INSTALLED_DIR}/tools/python3/python.exe")
            list(APPEND MESON_OPTIONS_RELEASE -Dplpython=enabled "-DPYTHON=${VCPKG_PYTHON3_PATH}")
            list(APPEND MESON_OPTIONS_DEBUG -Dplpython=disabled)
        endif()
    endif()
    if("tcl" IN_LIST FEATURES)
        list(APPEND MESON_OPTIONS -Dpltcl=enabled)
        # Tcl library naming on Windows: tcl90 (shared), tcl90s (static).
        # vcpkg separates debug/release via directory (lib/ vs debug/lib/)
        # rather than filename suffixes.
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            list(APPEND MESON_OPTIONS -Dtcl_version=tcl90s)
        else()
            list(APPEND MESON_OPTIONS -Dtcl_version=tcl90)
        endif()
    endif()

    # Provide paths to required tools
    vcpkg_list(SET ADDITIONAL_BINARIES)
    string(REPLACE [[\]] [[/]] BISON_PATH "${BISON}")
    string(REPLACE [[\]] [[/]] FLEX_PATH "${FLEX}")
    string(REPLACE [[\]] [[/]] PERL_PATH "${PERL}")
    list(APPEND ADDITIONAL_BINARIES
        "bison = ['${BISON_PATH}']"
        "flex = ['${FLEX_PATH}']"
        "perl = ['${PERL_PATH}']"
    )

    # Extra include/lib dirs for vcpkg dependencies (only if they exist;
    # with no optional deps installed, CURRENT_INSTALLED_DIR may lack these).
    # Debug and release use different lib dirs (debug libs have different
    # suffixes, e.g. tcl90g.lib vs tcl90.lib).
    if(EXISTS "${CURRENT_INSTALLED_DIR}/include")
        list(APPEND MESON_OPTIONS "-Dextra_include_dirs=['${CURRENT_INSTALLED_DIR}/include']")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}/lib")
        list(APPEND MESON_OPTIONS_RELEASE "-Dextra_lib_dirs=['${CURRENT_INSTALLED_DIR}/lib']")
    endif()
    if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib")
        list(APPEND MESON_OPTIONS_DEBUG "-Dextra_lib_dirs=['${CURRENT_INSTALLED_DIR}/debug/lib']")
    endif()

    vcpkg_configure_meson(
        SOURCE_PATH "${source_path}"
        OPTIONS
            ${MESON_OPTIONS}
        OPTIONS_RELEASE
            ${MESON_OPTIONS_RELEASE}
        OPTIONS_DEBUG
            ${MESON_OPTIONS_DEBUG}
        LANGUAGES C
        ADDITIONAL_BINARIES
            ${ADDITIONAL_BINARIES}
    )
    vcpkg_install_meson()

    # Remove server-related installed files we don't need
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/lib/postgresql"
        "${CURRENT_PACKAGES_DIR}/debug/lib/postgresql"
        "${CURRENT_PACKAGES_DIR}/share/postgresql"
    )

    if(HAS_TOOLS)
        set(TOOL_NAMES
            clusterdb createdb createuser dropdb dropuser ecpg pgbench
            pg_amcheck pg_basebackup pg_config pg_createsubscriber
            pg_dump pg_dumpall pg_isready pg_receivewal pg_recvlogical
            pg_restore pg_verifybackup psql reindexdb vacuumdb
        )
        vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
    else()
        # Remove all executables (keep DLLs in bin/ for dynamic linkage)
        file(GLOB exe_files
            "${CURRENT_PACKAGES_DIR}/bin/*.exe"
            "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe"
        )
        if(exe_files)
            file(REMOVE ${exe_files})
        endif()
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endfunction()
