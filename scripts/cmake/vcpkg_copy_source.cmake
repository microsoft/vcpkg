#[===[.md:
# vcpkg_configure_make

Configure configure for Debug and Release builds of a project.

## Usage
```cmake
vcpkg_copy_source(
    SOURCE_PATH <${SOURCE_PATH}>
    DEST_PATH <${DEST_PATH}>
)
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the `configure`/`configure.ac`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### DEST_PATH
Specifies the directory containing the ``configure`/`configure.ac`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
#]===]

function(vcpkg_copy_source)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _vcs "CLEAN_BEFORE_BUILD" "SOURCE_PATH;DEST_PATH" "")

    set(TAR_DIR "${CURRENT_BUILDTREES_DIR}/${_vcs_DEST_PATH}")
    if (NOT EXISTS "${TAR_DIR}")
        file(MAKE_DIRECTORY "${TAR_DIR}")
    endif()
    
    file(COPY "${_vcs_SOURCE_PATH}/" DESTINATION "${TAR_DIR}")
endfunction()
