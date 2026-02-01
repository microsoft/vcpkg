file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
set(pc_file_release "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/unit-test-cmake.pc")
if(NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    set(pc_file_debug "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/unit-test-cmake.pc")
endif()
set(reload_pc_strings 0)

function(write_pkgconfig)
    file(WRITE "${pc_file_release}" ${ARGN})
    if(NOT VCPKG_BUILD_TYPE)
        file(WRITE "${pc_file_debug}" ${ARGN})
    endif()
    file(STRINGS "${pc_file_release}" pc_strings_input)
    set(pc_strings_INPUT "${pc_strings_input}" PARENT_SCOPE)
    set(reload_pc_strings 1 PARENT_SCOPE)
endfunction()

function(unit_test_pkgconfig_check_find build_types)
    if(NOT build_types)
        message(SEND_ERROR "The build_type parameter must be list of debug;release.")
    endif()
    if(VCPKG_BUILD_TYPE)
        list(REMOVE_ITEM build_types debug)
    endif()
    if(NOT build_types)
        return()
    endif()

    foreach(build_type IN LISTS build_types)
        cmake_pkg_config(IMPORT unit-test-cmake)
        if (NOT ${PKGCONFIG_unit-test-cmake_FOUND})
            set_has_error()
            return()
        endif()
    endforeach()
endfunction()

# line continuations
write_pkgconfig([[
Libs: -L"${prefix}/lib" \
      -l"aaa"
]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_find("debug;release")

file(REMOVE_RECURSE "${pc_file_release}" "${pc_file_debug}")
