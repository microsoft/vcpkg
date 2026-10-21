# Declare a named repo to fetch with vcpkg_from_git and stage into SOURCE_PATH.
function(declare_webrtc_repo name)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "DESTINATION;URL;REF;PATCHES_VAR" "")
    if(NOT arg_DESTINATION OR NOT arg_URL OR NOT arg_REF)
        message(FATAL_ERROR "Arguments DESTINATION, URL and REF are required.")
    endif()

    set(declared_repos "${webrtc_declared_repos}")
    list(APPEND declared_repos "${name}")
    set(webrtc_repo_destination_${name} "${arg_DESTINATION}" PARENT_SCOPE)
    set(webrtc_repo_url_${name} "${arg_URL}" PARENT_SCOPE)
    set(webrtc_repo_ref_${name} "${arg_REF}" PARENT_SCOPE)
    set(webrtc_repo_patches_var_${name} "${arg_PATCHES_VAR}" PARENT_SCOPE)
    set(webrtc_declared_repos "${declared_repos}" PARENT_SCOPE)
endfunction()

# Fetch and stage all declared repos beneath the given source root.
function(fetch_declared_webrtc_repos source_path)
    foreach(name IN LISTS webrtc_declared_repos)
        set(repo_patches)
        set(patches_var "${webrtc_repo_patches_var_${name}}")
        if(NOT patches_var STREQUAL "" AND DEFINED ${patches_var})
            set(repo_patches ${${patches_var}})
        endif()

        vcpkg_from_git(
            OUT_SOURCE_PATH repo_source_path
            URL "${webrtc_repo_url_${name}}"
            REF "${webrtc_repo_ref_${name}}"
            PATCHES ${repo_patches}
        )

        set(repo_target_path "${source_path}/${webrtc_repo_destination_${name}}")
        get_filename_component(repo_target_parent "${repo_target_path}" DIRECTORY)
        file(MAKE_DIRECTORY "${repo_target_parent}")
        file(REMOVE_RECURSE "${repo_target_path}")
        file(RENAME "${repo_source_path}" "${repo_target_path}")
    endforeach()
endfunction()

# Declare a generated third-party overlay to be emitted by generate_external_dep().
function(declare_webrtc_generated_external name)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "LIB_ROOT_VAR;TOOL_PATH_VAR;PHASE" "")

    set(declared_generated_externals "${webrtc_declared_generated_externals}")
    list(APPEND declared_generated_externals "${name}")
    set(webrtc_generated_external_lib_root_var_${name} "${arg_LIB_ROOT_VAR}" PARENT_SCOPE)
    set(webrtc_generated_external_tool_path_var_${name} "${arg_TOOL_PATH_VAR}" PARENT_SCOPE)
    if("${arg_PHASE}" STREQUAL "")
        set(arg_PHASE "post_absl")
    endif()
    set(webrtc_generated_external_phase_${name} "${arg_PHASE}" PARENT_SCOPE)
    set(webrtc_declared_generated_externals
        "${declared_generated_externals}" PARENT_SCOPE)
endfunction()

# Emit all declared generated third-party overlays for the current build config.
function(generate_declared_webrtc_externals source_path build_config phase)
    foreach(name IN LISTS webrtc_declared_generated_externals)
        if(NOT webrtc_generated_external_phase_${name} STREQUAL "${phase}")
            continue()
        endif()

        set(lib_root "${CURRENT_INSTALLED_DIR}/lib")
        set(tool_path)

        set(lib_root_var "${webrtc_generated_external_lib_root_var_${name}}")
        if(NOT lib_root_var STREQUAL "" AND DEFINED ${lib_root_var})
            set(lib_root "${${lib_root_var}}")
        endif()

        set(tool_path_var "${webrtc_generated_external_tool_path_var_${name}}")
        if(NOT tool_path_var STREQUAL "" AND DEFINED ${tool_path_var})
            set(tool_path "${${tool_path_var}}")
        endif()

        if(tool_path STREQUAL "")
            generate_external_dep(
                "${source_path}" "${name}" "${CURRENT_INSTALLED_DIR}/include"
                "${lib_root}" "${build_config}"
            )
        else()
            generate_external_dep(
                "${source_path}" "${name}" "${CURRENT_INSTALLED_DIR}/include"
                "${lib_root}" "${build_config}" TOOL_PATH "${tool_path}"
            )
        endif()
    endforeach()
endfunction()
