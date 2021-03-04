#[===[.md:
# vcpkg_buildpath_length_warning

Warns the user if their vcpkg installation path might be too long for the package they're installing.

```cmake
vcpkg_buildpath_length_warning(<N>)
```

`vcpkg_buildpath_length_warning` warns the user if the number of bytes in the
path to `buildtrees` is bigger than `N`. Note that this is simply a warning,
and isn't relied on for correctness.
#]===]

function(vcpkg_buildpath_length_warning warning_length)
    string(LENGTH "${CURRENT_BUILDTREES_DIR}" buildtrees_path_length)
    if(buildtrees_path_length GREATER warning_length AND CMAKE_HOST_WIN32)
            message(WARNING "${PORT}'s buildsystem uses very long paths and may fail on your system.\n"
                "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
            )
    endif()
endfunction()
