#[===[.md:
# z_vcpkg_apply_patches

**Only for internal use in vcpkg helpers. Behavior and arguments will change without notice.**

Apply a set of patches to a source tree.

```cmake
z_vcpkg_apply_patches(
    SOURCE_PATH <path-to-source>
    [QUIET]
    PATCHES <patch>...
)
```

The `<path-to-source>` should be set to `${SOURCE_PATH}` by convention,
and is the path to apply the patches in.

`z_vcpkg_apply_patches` will take the list of `<patch>`es,
which are by default relative to the port directory,
and apply them in order using `git apply`.
Generally, these `<patch>`es take the form of `some.patch`
to select patches in the port directory.
One may also download patches and use `${VCPKG_DOWNLOADS}/path/to/some.patch`.

If `QUIET` is not passed, it is a fatal error for a patch to fail to apply;
otherwise, if `QUIET` is passed, no message is printed.
This should only be used for edge cases, such as patches that are known to fail even on a clean source tree.
#]===]

function(z_vcpkg_apply_patches)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "QUIET" "SOURCE_PATH" "PATCHES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "internal error: z_vcpkg_apply_patches was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    find_program(GIT NAMES git git.cmd REQUIRED)
    if(DEFINED ENV{GIT_CONFIG_NOSYSTEM})
        set(git_config_nosystem_backup "$ENV{GIT_CONFIG_NOSYSTEM}")
    else()
        unset(git_config_nosystem_backup)
    endif()

    set(ENV{GIT_CONFIG_NOSYSTEM} 1)
    set(patchnum 0)
    foreach(patch IN LISTS arg_PATCHES)
        get_filename_component(absolute_patch "${patch}" ABSOLUTE BASE_DIR "${CURRENT_PORT_DIR}")
        message(STATUS "Applying patch ${patch}")
        set(logname "patch-${TARGET_TRIPLET}-${patchnum}")
        vcpkg_execute_in_download_mode(
            COMMAND "${GIT}" -c core.longpaths=true -c core.autocrlf=false --work-tree=. --git-dir=.git apply "${absolute_patch}" --ignore-whitespace --whitespace=nowarn --verbose
            OUTPUT_FILE "${CURRENT_BUILDTREES_DIR}/${logname}-out.log"
            ERROR_VARIABLE error
            WORKING_DIRECTORY "${arg_SOURCE_PATH}"
            RESULT_VARIABLE error_code
        )
        file(WRITE "${CURRENT_BUILDTREES_DIR}/${logname}-err.log" "${error}")

        if(error_code)
            if(arg_QUIET)
                message(STATUS "Applying patch ${patch} - failure silenced")
            else()
                message(FATAL_ERROR "Applying patch failed: ${error}")
            endif()
        endif()

        math(EXPR patchnum "${patchnum} + 1")
    endforeach()
    if(DEFINED git_config_nosystem_backup)
        set(ENV{GIT_CONFIG_NOSYSTEM} "${git_config_nosystem_backup}")
    else()
        unset(ENV{GIT_CONFIG_NOSYSTEM})
    endif()
endfunction()
