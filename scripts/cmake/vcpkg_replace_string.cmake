#[===[.md:
# vcpkg_replace_string

Replace a string in a file.

```cmake
vcpkg_replace_string(<filename> <match> <replace>)
```
#]===]

function(vcpkg_replace_string filename match replace)
    file(READ "${filename}" contents)
    string(REPLACE "${match}" "${replace}" contents "${contents}")
    file(WRITE "${filename}" "${contents}")
endfunction()
