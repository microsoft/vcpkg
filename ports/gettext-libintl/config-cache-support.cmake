# Filter out non-portable entries from full cache file
function(z_vcpkg_config_cache_filter_file in_file out_file)
    file(READ "${in_file}" cache)
    string(JOIN "|" filter_exclude
        " *#"
        "[^\\n]*/installed/"
        "[^\\n]*/buildtrees/"
        "[^\\n]*/usr/"
        "[^\\n]*[/\\\\]Windows Kit[/\\\\]"
        "[a-z_]*_inline"  # depends on build type
        "ac_cv_build"
        "ac_cv_env_"
        "ac_cv_host"
        "ac_cv_path"
        "ac_cv_prog"
        "gl_cv_absolute_"
        "gl_cv_func_snprintf_truncation_c99"
        "gl_cv_host_cpu_c_abi_32bit"
        "gl_cv_malloc_ptrdiff"
        "gl_cv_next_.*_h="  # depends on absolute paths
        "gl_cv_prog_"
        "gt_cv_locale_"
        "(test [^|]*[|][|] )?lt_cv_"  # libtool config depends on target
    )
    string(REGEX REPLACE "\n(${filter_exclude})[^\n]*" "" cache "${cache}")
    string(REGEX REPLACE "\n\n+" "\n" cache "${cache}")
    file(WRITE "${out_file}" "${cache}")
endfunction()

# Initalize config cache options
function(vcpkg_config_cache_setup out_option_release out_option_debug)
    set(z_vcpkg_config_cache_release "${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-rel.log" CACHE INTERNAL "")
    set(${out_option_release} "--cache-file=${z_vcpkg_config_cache_release}" PARENT_SCOPE)
    if(VCPKG_AUTOTOOLS_CONFIG_CACHE AND EXISTS "${VCPKG_AUTOTOOLS_CONFIG_CACHE}")
        message(STATUS "Using config at ${VCPKG_AUTOTOOLS_CONFIG_CACHE}")
        z_vcpkg_config_cache_filter_file("${VCPKG_AUTOTOOLS_CONFIG_CACHE}" "${z_vcpkg_config_cache_release}")
    else()
        file(WRITE "${z_vcpkg_config_cache_release}" "")
    endif()
    set(z_vcpkg_config_cache_debug "${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-dbg.log" CACHE INTERNAL "")
    set(${out_option_debug} "--cache-file=${z_vcpkg_config_cache_debug}" PARENT_SCOPE)
    file(COPY_FILE "${z_vcpkg_config_cache_release}" "${z_vcpkg_config_cache_debug}")
    file(SHA512 "${z_vcpkg_config_cache_release}" sha512)
    set(z_vcpkg_config_cache_input_sha512 "${sha512}" CACHE INTERNAL "")
endfunction()

# Process one build type's cache for immediate reuse for the other build type
function(vcpkg_config_cache_reuse)
    if(VCPKG_AUTOTOOLS_CONFIG_CACHE)
        set(input "${z_vcpkg_config_cache_release}")
        set(output "${z_vcpkg_config_cache_debug}")
        if("${output}" IS_NEWER_THAN "${input}")
            set(input "${z_vcpkg_config_cache_debug}")
            set(output "${z_vcpkg_config_cache_release}")
        endif()
        file(READ "${input}" config_cache)
        # Same system, different build type: Eliminate specific flags etc.
        string(REGEX REPLACE "\n(ac_cv_env|[a-z_]*_inline)[^\n]*" "" config_cache "${config_cache}")
        file(WRITE "${output}" "${config_cache}")
    endif()
endfunction()

# Save config cache template
function(vcpkg_config_cache_teardown)
    set(config_cache_output "${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-new.log")
    z_vcpkg_config_cache_filter_file("${z_vcpkg_config_cache_release}" "${config_cache_output}")
    file(SHA512 "${config_cache_output}" sha512)
    if(EXISTS "${VCPKG_AUTOTOOLS_CONFIG_CACHE}" AND NOT sha512 STREQUAL z_vcpkg_config_cache_input_sha512)
        message(STATUS "Modified config written to ${config_cache_output}")
    endif()
endfunction()
