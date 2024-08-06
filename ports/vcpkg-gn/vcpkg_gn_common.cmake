include_guard(GLOBAL)

# Create vcpkg list from json array.
function(z_vcpkg_gn_list_from_json out_var json) # <path>
    vcpkg_list(SET list)
    string(JSON array ERROR_VARIABLE error GET "${json}" ${ARGN})
    if(NOT error)
        string(JSON len ERROR_VARIABLE error LENGTH "${array}")
        if(NOT error AND NOT len STREQUAL "0")
            math(EXPR last "${len} - 1")
            foreach(i RANGE "${last}")
                string(JSON item GET "${array}" "${i}")
                vcpkg_list(APPEND list "${item}")
            endforeach()
        endif()
    endif()
    set("${out_var}" "${list}" PARENT_SCOPE)
endfunction()

# Expand gn targets for installable components.
function(z_vcpkg_gn_expand_targets targets_var desc_var source_path)
    set(vcpkg_gn_targets_components "")
    set(vcpkg_gn_targets_visited "")
    set(vcpkg_gn_targets_recurse 1)
    foreach(gn_target IN LISTS "${targets_var}")
        z_vcpkg_gn_expand_targets_recurse("${gn_target}" "${desc_var}" "${source_path}")
    endforeach()
    set("${targets_var}" "${vcpkg_gn_targets_components}" PARENT_SCOPE)
endfunction()

# Private helper for z_vcpkg_gn_expand_targets.
# Cf. https://gn.googlesource.com/gn/+/master/docs/reference.md#details-of-dependency-propagation
function(z_vcpkg_gn_expand_targets_recurse gn_target desc_var source_path)
    # shortcuts
    if(gn_target IN_LIST vcpkg_gn_targets_components)
        return()
    elseif(gn_target IN_LIST vcpkg_gn_targets_visited)
        return()
    endif()
    list(APPEND vcpkg_gn_targets_visited "${gn_target}")

    # current target
    string(JSON current_json GET "${${desc_var}}" targets "${gn_target}")
    string(JSON target_type GET "${current_json}" "type")
    if(target_type STREQUAL "static_library")
        list(APPEND vcpkg_gn_targets_components "${gn_target}")
        string(JSON complete_static_lib ERROR_VARIABLE error GET "${current_json}" "complete_static_lib")
        if(NOT error AND complete_static_lib)
            set(vcpkg_gn_targets_recurse 0)
        endif()
    elseif(target_type MATCHES "^(executable|loadable_module|shared_library)\$")
        list(APPEND vcpkg_gn_targets_components "${gn_target}")
        set(vcpkg_gn_targets_recurse "RUNTIME")
    elseif(NOT target_type MATCHES "^(group|source_set)\$")
        set(vcpkg_gn_targets_recurse 0)
    endif()

    if(vcpkg_gn_targets_recurse STREQUAL "RUNTIME")
        # tbd
    elseif(vcpkg_gn_targets_recurse)
        z_vcpkg_gn_list_from_json(deps "${current_json}" "deps")
        foreach(dep IN LISTS deps)
            z_vcpkg_gn_expand_targets_recurse("${dep}" "${desc_var}" "${source_path}")
        endforeach()
    endif()

    set(vcpkg_gn_targets_components "${vcpkg_gn_targets_components}" PARENT_SCOPE)
    set(vcpkg_gn_targets_visited "${vcpkg_gn_targets_visited}" PARENT_SCOPE)
endfunction()
