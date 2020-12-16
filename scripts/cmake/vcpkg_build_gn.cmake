#[===[.md:
# vcpkg_build_gn

Build a GN project

## Usage:
```cmake
vcpkg_build_gn(
    [TARGETS <target>...]
)
```

## Parameters:
### TARGETS
Only build the specified targets.
#]===]

function(vcpkg_build_gn)
    vcpkg_build_ninja(${ARGN})
endfunction()
