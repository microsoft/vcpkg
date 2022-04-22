#[===[.md:
# vcpkg_extract_source_archive

Extract an archive into the source directory.

## Usage
There are two "overloads" of this function. The first is deprecated:

```cmake
vcpkg_extract_source_archive(<${ARCHIVE}> [<${TARGET_DIRECTORY}>])
```

This overload should not be used.

The latter is suggested to use for all future `vcpkg_extract_source_archive`s.

```cmake
vcpkg_extract_source_archive(<out-var>
    ARCHIVE <path>
    [NO_REMOVE_ONE_LEVEL]
    [SKIP_PATCH_CHECK]
    [PATCHES <patch>...]
    [SOURCE_BASE <base>]
    [BASE_DIRECTORY <relative-path> | WORKING_DIRECTORY <absolute-path>]
)
```

`vcpkg_extract_source_archive` takes an archive and extracts it.
It replaces existing uses of `vcpkg_extract_source_archive_ex`.
The simplest use of it is:

```cmake
vcpkg_download_distfile(archive ...)
vcpkg_extract_source_archive(source_path ARCHIVE "${archive}")
```

The general expectation is that an archives are laid out with a base directory,
and all the actual files underneath that directory; in other words, if you
extract the archive, you'll get something that looks like:

```
zlib-1.2.11/
    doc/
        ...
    examples/
        ...
    ChangeLog
    CMakeLists.txt
    README
    zlib.h
    ...
```

`vcpkg_extract_source_archive` automatically removes this directory,
and gives you the items under it directly. However, this only works
when there is exactly one item in the top level of an archive.
Otherwise, you'll have to pass the `NO_REMOVE_ONE_LEVEL` argument to
prevent `vcpkg_extract_source_archive` from performing this transformation.

If the source needs to be patched in some way, the `PATCHES` argument
allows one to do this, just like other `vcpkg_from_*` functions.
Additionally, the `SKIP_PATCH_CHECK` is provided for `--head` mode -
this allows patches to fail to apply silently.
This argument should _only_ be used when installing a `--head` library,
since otherwise we want a patch failing to appply to be a hard error.

`vcpkg_extract_source_archive` extracts the files to
`${CURRENT_BUILDTREES_DIR}/<base-directory>/<source-base>-<hash>.clean`.
When in editable mode, no `.clean` is appended,
to allow for a user to modify the sources.
`base-directory` defaults to `src`,
and `source-base` defaults to the stem of `<archive>`.
You can change these via the `BASE_DIRECTORY` and `SOURCE_BASE` arguments
respectively.
If you need to extract to a location that is not based in `CURRENT_BUILDTREES_DIR`,
you can use the `WORKING_DIRECTORY` argument to do the same.

## Examples

* [libraw](https://github.com/Microsoft/vcpkg/blob/master/ports/libraw/portfile.cmake)
* [protobuf](https://github.com/Microsoft/vcpkg/blob/master/ports/protobuf/portfile.cmake)
* [msgpack](https://github.com/Microsoft/vcpkg/blob/master/ports/msgpack/portfile.cmake)
#]===]

function(z_vcpkg_extract_source_archive_deprecated_mode archive working_directory)
    cmake_path(GET archive FILENAME archive_filename)
    if(NOT EXISTS "${working_directory}/${archive_filename}.extracted")
        message(STATUS "Extracting source ${archive}")
        file(MAKE_DIRECTORY "${working_directory}")
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND "${CMAKE_COMMAND}" -E tar xjf "${archive}"
            WORKING_DIRECTORY "${working_directory}"
            LOGNAME extract
        )
        file(TOUCH "${working_directory}/${archive_filename}.extracted")
    endif()
endfunction()

function(vcpkg_extract_source_archive)
    if(ARGC LESS_EQUAL "2")
        z_vcpkg_deprecation_message( "Deprecated form of vcpkg_extract_source_archive used:
    Please use the `vcpkg_extract_source_archive(<out-var> ARCHIVE <archive>)` form.")
        if(ARGC EQUAL "0")
            message(FATAL_ERROR "vcpkg_extract_source_archive requires at least one argument.")
        endif()

        set(archive "${ARGV0}")
        if(ARGC EQUAL "1")
            set(working_directory "${CURRENT_BUILDTREES_DIR}/src")
        else()
            set(working_directory "${ARGV1}")
        endif()

        z_vcpkg_extract_source_archive_deprecated_mode("${archive}" "${working_directory}")
        return()
    endif()

    set(out_source_path "${ARGV0}")
    cmake_parse_arguments(PARSE_ARGV 1 "arg"
        "NO_REMOVE_ONE_LEVEL;SKIP_PATCH_CHECK;Z_ALLOW_OLD_PARAMETER_NAMES"
        "ARCHIVE;SOURCE_BASE;BASE_DIRECTORY;WORKING_DIRECTORY;REF"
        "PATCHES"
    )

    if(DEFINED arg_REF)
        if(NOT arg_Z_ALLOW_OLD_PARAMETER_NAMES)
            message(FATAL_ERROR "Unexpected argument REF")
        elseif(DEFINED arg_SOURCE_BASE)
            message(FATAL_ERROR "Cannot specify both REF and SOURCE_BASE")
        else()
            string(REPLACE "/" "-" arg_SOURCE_BASE "${arg_REF}")
        endif()
    endif()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_ARCHIVE)
        message(FATAL_ERROR "ARCHIVE must be specified")
    endif()

    if(DEFINED arg_WORKING_DIRECTORY)
        if(DEFINED arg_BASE_DIRECTORY)
            message(FATAL_ERROR "Cannot specify both BASE_DIRECTORY and WORKING_DIRECTORY")
        elseif(NOT IS_ABSOLUTE "${arg_WORKING_DIRECTORY}")
            message(FATAL_ERROR "WORKING_DIRECTORY (${arg_WORKING_DIRECTORY}) must be an absolute path")
        endif()
        set(working_directory "${arg_WORKING_DIRECTORY}")
    else()
        if(NOT DEFINED arg_BASE_DIRECTORY)
            set(arg_BASE_DIRECTORY "src")
        elseif(IS_ABSOLUTE "${arg_BASE_DIRECTORY}")
            message(FATAL_ERROR "BASE_DIRECTORY (${arg_BASE_DIRECTORY}) must be a relative path")
        endif()
        cmake_path(APPEND CURRENT_BUILDTREES_DIR "${arg_BASE_DIRECTORY}"
            OUTPUT_VARIABLE working_directory)
    endif()

    if(NOT DEFINED arg_SOURCE_BASE)
        cmake_path(GET arg_ARCHIVE STEM arg_SOURCE_BASE)
    elseif(arg_SOURCE_BASE MATCHES [[\\|/]])
        message(FATAL_ERROR "SOURCE_BASE (${arg_SOURCE_BASE}) must not contain slashes")
    endif()

    # Take the last 10 chars of the base
    set(base_max_length 10)
    string(LENGTH "${arg_SOURCE_BASE}" source_base_length)
    if(source_base_length GREATER base_max_length)
        math(EXPR start "${source_base_length} - ${base_max_length}")
        string(SUBSTRING "${arg_SOURCE_BASE}" "${start}" -1 arg_SOURCE_BASE)
    endif()

    # Hash the archive hash along with the patches. Take the first 10 chars of the hash
    file(SHA512 "${arg_ARCHIVE}" patchset_hash)
    foreach(patch IN LISTS arg_PATCHES)
        cmake_path(ABSOLUTE_PATH patch
            BASE_DIRECTORY "${CURRENT_PORT_DIR}"
            OUTPUT_VARIABLE absolute_patch
        )
        if(NOT EXISTS "${absolute_patch}")
            message(FATAL_ERROR "Could not find patch: '${patch}'")
        endif()
        file(SHA512 "${absolute_patch}" current_hash)
        string(APPEND patchset_hash "${current_hash}")
    endforeach()

    string(SHA512 patchset_hash "${patchset_hash}")
    string(SUBSTRING "${patchset_hash}" 0 10 patchset_hash)
    cmake_path(APPEND working_directory "${arg_SOURCE_BASE}-${patchset_hash}"
        OUTPUT_VARIABLE source_path
    )

    if(_VCPKG_EDITABLE AND EXISTS "${source_path}")
        set("${out_source_path}" "${source_path}" PARENT_SCOPE)
        message(STATUS "Using source at ${source_path}")
        return()
    elseif(NOT _VCPKG_EDITABLE)
        cmake_path(APPEND_STRING source_path ".clean")
        if(EXISTS "${source_path}")
            message(STATUS "Cleaning sources at ${source_path}. Use --editable to skip cleaning for the packages you specify.")
            file(REMOVE_RECURSE "${source_path}")
        endif()
    endif()

    message(STATUS "Extracting source ${arg_ARCHIVE}")
    cmake_path(APPEND_STRING source_path ".tmp" OUTPUT_VARIABLE temp_dir)
    file(REMOVE_RECURSE "${temp_dir}")
    file(MAKE_DIRECTORY "${temp_dir}")
    vcpkg_execute_required_process(
        ALLOW_IN_DOWNLOAD_MODE
        COMMAND "${CMAKE_COMMAND}" -E tar xjf "${arg_ARCHIVE}"
        WORKING_DIRECTORY "${temp_dir}"
        LOGNAME extract
    )

    if(arg_NO_REMOVE_ONE_LEVEL)
        cmake_path(SET temp_source_path "${temp_dir}")
    else()
        file(GLOB archive_directory "${temp_dir}/*")
        # make sure `archive_directory` is only a single file
        if(NOT archive_directory MATCHES ";" AND IS_DIRECTORY "${archive_directory}")
            cmake_path(SET temp_source_path "${archive_directory}")
        else()
            message(FATAL_ERROR "Could not unwrap top level directory from archive. Pass NO_REMOVE_ONE_LEVEL to disable this.")
        endif()
    endif()

    if (arg_SKIP_PATCH_CHECK)
        set(quiet_param QUIET)
    else()
        set(quiet_param "")
    endif()

    z_vcpkg_apply_patches(
        SOURCE_PATH "${temp_source_path}"
        PATCHES ${arg_PATCHES}
        ${quiet_param}
    )

    file(RENAME "${temp_source_path}" "${source_path}")
    file(REMOVE_RECURSE "${temp_dir}")

    set("${out_source_path}" "${source_path}" PARENT_SCOPE)
    message(STATUS "Using source at ${source_path}")
endfunction()
