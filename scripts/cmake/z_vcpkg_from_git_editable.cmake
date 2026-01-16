# Internal helper for editable mode in vcpkg_from_git/github/gitlab
# This function handles cloning and patching for editable ports.
# Supports multiple source downloads via numbered subdirectories (src1, src2, etc.)
#
# Prerequisites (caller must check before calling):
#   _VCPKG_EDITABLE must be TRUE
#   _VCPKG_EDITABLE_SOURCES_PATH must be defined
#
# Arguments:
#   URL           - Git URL to clone from
#   REF           - Git ref (commit/tag/branch) to checkout
#   OUT_SOURCE_PATH - Variable name to set with the source path
#   PATCHES       - List of patches to apply
#
# Sets in PARENT_SCOPE:
#   ${OUT_SOURCE_PATH} - Path to the editable source (e.g., sources/src1)
#
# Uses CACHE variables:
#   _VCPKG_EDITABLE_SOURCE_COUNT - Counter for multiple source downloads

function(z_vcpkg_from_git_editable)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "URL;REF;OUT_SOURCE_PATH"
        "PATCHES"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "z_vcpkg_from_git_editable was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    # Increment source counter (starts at 0, so first call gets src1)
    if(NOT DEFINED _VCPKG_EDITABLE_SOURCE_COUNT)
        set(_VCPKG_EDITABLE_SOURCE_COUNT 0 CACHE INTERNAL "Editable source download counter")
    endif()
    math(EXPR _new_count "${_VCPKG_EDITABLE_SOURCE_COUNT} + 1")
    set(_VCPKG_EDITABLE_SOURCE_COUNT ${_new_count} CACHE INTERNAL "Editable source download counter" FORCE)

    # Compute source path: sources/src1, sources/src2, etc.
    set(_editable_source_path "${_VCPKG_EDITABLE_SOURCES_PATH}/src${_new_count}")

    # Source already exists - use it as-is
    if(EXISTS "${_editable_source_path}/.git")
        message(STATUS "Editable mode: using existing source at ${_editable_source_path}")
        set("${arg_OUT_SOURCE_PATH}" "${_editable_source_path}" PARENT_SCOPE)
        return()
    endif()

    # Validate required arguments
    if(NOT DEFINED arg_URL)
        message(FATAL_ERROR "z_vcpkg_from_git_editable: URL must be specified")
    endif()
    if(NOT DEFINED arg_REF)
        message(FATAL_ERROR "z_vcpkg_from_git_editable: REF must be specified")
    endif()

    find_program(GIT NAMES git git.cmd REQUIRED)

    # Ensure parent directory exists
    get_filename_component(_editable_parent "${_editable_source_path}" DIRECTORY)
    file(MAKE_DIRECTORY "${_editable_parent}")

    # Full clone (not shallow, not single-branch) to enable proper git workflow
    message(STATUS "Editable mode: cloning ${arg_URL} to ${_editable_source_path}")
    vcpkg_execute_in_download_mode(
        COMMAND "${GIT}" clone "${arg_URL}" "${_editable_source_path}"
        WORKING_DIRECTORY "${_editable_parent}"
        RESULT_VARIABLE _git_clone_result
    )
    if(NOT _git_clone_result EQUAL 0)
        message(FATAL_ERROR "Editable mode: git clone failed for ${arg_URL}")
    endif()

    # Checkout specific ref
    vcpkg_execute_in_download_mode(
        COMMAND "${GIT}" checkout "${arg_REF}"
        WORKING_DIRECTORY "${_editable_source_path}"
        RESULT_VARIABLE _git_checkout_result
    )
    if(NOT _git_checkout_result EQUAL 0)
        message(WARNING "Editable mode: git checkout ${arg_REF} failed, using default branch")
    endif()

    # Apply patches one by one, committing each
    foreach(_patch IN LISTS arg_PATCHES)
        get_filename_component(_patch_path "${_patch}" ABSOLUTE BASE_DIR "${CURRENT_PORT_DIR}")
        
        if(NOT EXISTS "${_patch_path}")
            message(WARNING "Editable mode: patch file not found: ${_patch_path}")
            continue()
        endif()

        message(STATUS "Editable mode: applying patch ${_patch}")

        # Use z_vcpkg_apply_patches for single patch
        z_vcpkg_apply_patches(
            SOURCE_PATH "${_editable_source_path}"
            PATCHES "${_patch_path}"
        )

        # Stage and commit the patch
        vcpkg_execute_in_download_mode(
            COMMAND "${GIT}" add -A
            WORKING_DIRECTORY "${_editable_source_path}"
            RESULT_VARIABLE _git_add_result
        )
        if(NOT _git_add_result EQUAL 0)
            message(WARNING "Editable mode: git add failed after applying ${_patch}")
        endif()

        # Extract patch filename for commit message
        get_filename_component(_patch_name "${_patch}" NAME)
        vcpkg_execute_in_download_mode(
            COMMAND "${GIT}" commit -m "Apply vcpkg patch: ${_patch_name}"
            WORKING_DIRECTORY "${_editable_source_path}"
            RESULT_VARIABLE _git_commit_result
        )
        if(NOT _git_commit_result EQUAL 0)
            # Commit might fail if patch made no changes - that's OK
            message(STATUS "Editable mode: no changes to commit for patch ${_patch_name}")
        endif()
    endforeach()

    message(STATUS "Editable mode: source ready at ${_editable_source_path}")
    set("${arg_OUT_SOURCE_PATH}" "${_editable_source_path}" PARENT_SCOPE)
endfunction()
