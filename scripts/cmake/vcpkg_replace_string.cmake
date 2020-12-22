#[===[.md:
# vcpkg_replace_string

Replace a string in a file.

```cmake
vcpkg_replace_string(filename match_string replace_string)
```

#]===]

function(vcpkg_replace_string filename match_string replace_string)
    file(READ ${filename} _contents)
    string(REPLACE "${match_string}" "${replace_string}" _contents "${_contents}")
    file(WRITE ${filename} "${_contents}")
endfunction()
