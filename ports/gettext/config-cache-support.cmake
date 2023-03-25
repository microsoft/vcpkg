function(vcpkg_config_cache_setup out_option_release out_option_debug)
    set(z_vcpkg_config_cache_release "${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-rel.log" CACHE INTERNAL "")
    set(${out_option_release} "--cache-file=${z_vcpkg_config_cache_release}" PARENT_SCOPE)
    if(VCPKG_AUTOTOOLS_CONFIG_CACHE AND EXISTS "${VCPKG_AUTOTOOLS_CONFIG_CACHE}")
        message(STATUS "Using config at ${VCPKG_AUTOTOOLS_CONFIG_CACHE}")
        file(COPY_FILE "${VCPKG_AUTOTOOLS_CONFIG_CACHE}" "${z_vcpkg_config_cache_release}")
    else()
        file(WRITE "${z_vcpkg_config_cache_release}" "")
    endif()
    set(z_vcpkg_config_cache_debug "${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-dbg.log" CACHE INTERNAL "")
    set(${out_option_debug} "--cache-file=${z_vcpkg_config_cache_debug}" PARENT_SCOPE)
    file(COPY_FILE "${z_vcpkg_config_cache_release}" "${z_vcpkg_config_cache_debug}")
    file(SHA512 "${z_vcpkg_config_cache_release}" sha512)
    set(z_vcpkg_config_cache_input_sha512 "${sha512}" CACHE INTERNAL "")
endfunction()

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
        string(REGEX REPLACE "\n(ac_cv_env|[a-z_]*_c_inline)[^\n]*" "" config_cache "${config_cache}")
        file(WRITE "${output}" "${config_cache}")
        file(WRITE "${output}.log" "${config_cache}")
    endif()
endfunction()

function(vcpkg_config_cache_teardown)
    file(STRINGS "${z_vcpkg_config_cache_release}" cache)
    set(cache_multiline "")
    set(multiline "")
    foreach(line IN LISTS cache ITEMS "")
        string(APPEND multiline "${line}")
        if(line MATCHES "[\\]\$")
            string(APPEND multiline "\n")
        else()
            list(APPEND cache_multiline "${multiline}")
            set(multiline "")
        endif()
    endforeach()
    string(JOIN "|" filter
        "^ac_cv_c_"
        "^ac_cv_cxx_"
        "^ac_cv_exeext"
        "^ac_cv_func_"
        "^ac_cv_have_decl_"
        "^ac_cv_header_"
        "^ac_cv_member_struct_"
        "^ac_cv_search_"
        "^ac_cv_type_"
    )
    list(FILTER cache_multiline INCLUDE REGEX "${filter}")
    list(FILTER cache_multiline EXCLUDE REGEX "_c_inline")
    set(cache "")
    foreach(line IN LISTS cache_multiline)
        string(APPEND cache "${line}\n")
    endforeach()
    set(config_cache_output "${CURRENT_BUILDTREES_DIR}/config.cache-${TARGET_TRIPLET}-new.log")
    file(WRITE "${config_cache_output}" "${cache}\n")
    file(SHA512 "${config_cache_output}" sha512)
    if(NOT sha512 STREQUAL z_vcpkg_config_cache_input_sha512)
        message(STATUS "Modified config written to ${config_cache_output}")
    endif()
endfunction()
