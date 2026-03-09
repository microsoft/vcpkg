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

    # Truncate meson.build before the test/pseudo-target sections that reference
    # variables from skipped subdirs (pg_regress, regress_module, docs, etc.).
    # The subdirs themselves are already commented out by windows/meson-vcpkg.patch,
    # but the test infrastructure section still references variables from them.
    file(READ "${source_path}/meson.build" meson_content)
    string(FIND "${meson_content}" "# all targets that require building code" truncate_pos)
    if(NOT truncate_pos EQUAL -1)
        string(SUBSTRING "${meson_content}" 0 ${truncate_pos} meson_content)
        file(WRITE "${source_path}/meson.build" "${meson_content}")
    endif()

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
        # The vcpkg tcl port doesn't generate pkg-config files on Windows,
        # so meson's dependency('tcl90') fails. Its fallback cc.find_library()
        # also fails because meson's link-test probe doesn't work reliably
        # with vcpkg's directory layout. Generate .pc files so meson can
        # find Tcl through its preferred pkg-config path.
        # Tcl naming: tcl90 (dynamic), tcl90s (static), +g suffix for debug.
        set(_tcl_pc_name "tcl90")
        # Determine the release library name
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            set(_tcl_rel_libname "tcl90s")
        else()
            set(_tcl_rel_libname "tcl90")
        endif()
        # Generate release .pc file
        set(_tcl_pc_dir "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
        file(MAKE_DIRECTORY "${_tcl_pc_dir}")
        file(WRITE "${_tcl_pc_dir}/${_tcl_pc_name}.pc"
"prefix=${CURRENT_INSTALLED_DIR}\nlibdir=\${prefix}/lib\nincludedir=\${prefix}/include\n\nName: ${_tcl_pc_name}\nDescription: Tcl scripting language\nVersion: 9.0\nLibs: -L\${libdir} -l${_tcl_rel_libname}\nCflags: -I\${includedir}\n")
        # Determine the debug library name
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            set(_tcl_dbg_libname "tcl90sg")
        else()
            set(_tcl_dbg_libname "tcl90g")
        endif()
        # Generate debug .pc file
        if(NOT VCPKG_BUILD_TYPE)
            set(_tcl_pc_dbg_dir "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig")
            file(MAKE_DIRECTORY "${_tcl_pc_dbg_dir}")
            file(WRITE "${_tcl_pc_dbg_dir}/${_tcl_pc_name}.pc"
"prefix=${CURRENT_INSTALLED_DIR}/debug\nlibdir=\${prefix}/lib\nincludedir=${CURRENT_INSTALLED_DIR}/include\n\nName: ${_tcl_pc_name}\nDescription: Tcl scripting language\nVersion: 9.0\nLibs: -L\${libdir} -l${_tcl_dbg_libname}\nCflags: -I\${includedir}\n")
        endif()
        list(APPEND MESON_OPTIONS "-Dtcl_version=${_tcl_pc_name}")
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

    # The meson build installs pgcommon with -DUSE_PRIVATE_ENCODING_FUNCS,
    # which renames pg_char_to_encoding -> pg_char_to_encoding_private.
    # Consumers linking static pq.lib need the non-private names.
    # Replace pgcommon with pgcommon_shlib (compiled without the flag),
    # mirroring the autoconf Makefile: mv libpgcommon_shlib.a libpgcommon.a
    foreach(dir IN ITEMS "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug/lib")
        if(EXISTS "${dir}/libpgcommon_shlib.lib")
            file(REMOVE "${dir}/libpgcommon.lib")
            file(RENAME "${dir}/libpgcommon_shlib.lib" "${dir}/libpgcommon.lib")
        endif()
        # Clean up _shlib variants that consumers don't need
        file(REMOVE "${dir}/libpgport_shlib.lib")
    endforeach()

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
