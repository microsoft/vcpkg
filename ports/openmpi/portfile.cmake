vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

string(REGEX REPLACE [[^([0-9]+[.][0-9]+).*$]] [[\1]] OpenMPI_SHORT_VERSION "${VERSION}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.open-mpi.org/release/open-mpi/v${OpenMPI_SHORT_VERSION}/openmpi-${VERSION}.tar.gz"
    FILENAME "openmpi-${VERSION}.tar.gz"
    SHA512 a174b6ac6d286f378ccc7a1ac3500cdff3c7368eaa00c1b672f0a71452c2cbe7812e030796e62ebb09a3fffb0cb9d89fbc6798a80609079038e68c7b0d318923
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_find_acquire_program(PERL)
cmake_path(GET PERL PARENT_PATH PERL_PATH)
vcpkg_add_to_path("${PERL_PATH}")

# Put wrapper data dir side-by-side to wrapper executables dir instead of loosing debug data.
# vcpkg-make appends these to the configuration-specific options.
vcpkg_list(PREPEND VCPKG_MAKE_CONFIGURE_OPTIONS_DEBUG [[--datadir=\${prefix}/../tools/openmpi/debug/share]])
vcpkg_list(PREPEND VCPKG_MAKE_CONFIGURE_OPTIONS_RELEASE [[--datadir=\${prefix}/tools/openmpi/share]])
if(VCPKG_TARGET_IS_OSX)
    # This ensures that vcpkg-fixup-macho-rpath succeeds
    string(APPEND VCPKG_LINKER_FLAGS " -headerpad_max_install_names")
endif()

vcpkg_make_configure(
    COPY_SOURCE
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-dependency-tracking
        --with-hwloc=internal
        --with-libevent=internal
        --with-pmix=internal
        --enable-mpi-fortran=no
    OPTIONS_DEBUG
        --enable-debug
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

# hwloc-compress-dir and hwloc-gather-topology are generated from autoconf
# templates and may embed configure-time absolute paths. Rewrite the installed
# scripts to resolve companion tools from the script location instead of the
# build/package staging directory.
function(openmpi_fix_hwloc_script script_path script_dir_suffix)
    if(NOT EXISTS "${script_path}")
        return()
    endif()

    file(READ "${script_path}" _script_contents)

    if(NOT _script_contents MATCHES [[script_dir=]])
        vcpkg_replace_string(
            "${script_path}"
            [[#!/bin/sh]]
            [=[#!/bin/sh
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"]=]
            IGNORE_UNCHANGED
        )
    endif()

    # POSIX shell parameter expansion:
    #   ${script_dir%/tools/openmpi/bin}
    # strips the known suffix and gives the package root.
    set(_prefix_expr "\${script_dir%/${script_dir_suffix}}")

    # Prefer the script directory for bindir and derive the configured prefix
    # from it. This keeps both release and debug scripts relocatable.
    vcpkg_replace_string(
        "${script_path}"
        "${CURRENT_INSTALLED_DIR}/${script_dir_suffix}"
        [[${script_dir}]]
        IGNORE_UNCHANGED
    )
    vcpkg_replace_string(
        "${script_path}"
        "${CURRENT_INSTALLED_DIR}"
        "${_prefix_expr}"
        IGNORE_UNCHANGED
    )

    # Remove any remaining build-machine paths that are not meaningful at
    # runtime and would fail vcpkg's absolute path validation.
    foreach(abs_path IN ITEMS
        "${CURRENT_BUILDTREES_DIR}"
        "${DOWNLOADS}"
    )
        if(NOT abs_path STREQUAL "")
            vcpkg_replace_string(
                "${script_path}"
                "${abs_path}"
                ""
                IGNORE_UNCHANGED
            )
        endif()
    endforeach()
endfunction()

openmpi_fix_hwloc_script(
    "${CURRENT_PACKAGES_DIR}/tools/openmpi/bin/hwloc-compress-dir"
    "tools/openmpi/bin"
)
openmpi_fix_hwloc_script(
    "${CURRENT_PACKAGES_DIR}/tools/openmpi/bin/hwloc-gather-topology"
    "tools/openmpi/bin"
)

openmpi_fix_hwloc_script(
    "${CURRENT_PACKAGES_DIR}/tools/openmpi/debug/bin/hwloc-compress-dir"
    "tools/openmpi/debug/bin"
)
openmpi_fix_hwloc_script(
    "${CURRENT_PACKAGES_DIR}/tools/openmpi/debug/bin/hwloc-gather-topology"
    "tools/openmpi/debug/bin"
)

# pmix_config.h records the configure command line. Redact its build-machine
# paths without changing the generated C string syntax.
foreach(dir IN ITEMS "" "debug/")
    set(pmix_config "${CURRENT_PACKAGES_DIR}/${dir}include/pmix/src/include/pmix_config.h")
    if(EXISTS "${pmix_config}")
        foreach(abs_path IN ITEMS
            "${CURRENT_PACKAGES_DIR}"
            "${CURRENT_BUILDTREES_DIR}"
            "${CURRENT_INSTALLED_DIR}"
            "${DOWNLOADS}"
        )
            if(NOT abs_path STREQUAL "")
                vcpkg_replace_string(
                    "${pmix_config}"
                    "${abs_path}"
                    "VCPKG_REDACTED_PATH"
                    IGNORE_UNCHANGED
                )
            endif()
        endforeach()
    endif()
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${CURRENT_PORT_DIR}/mpi-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/mpi-wrapper.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
