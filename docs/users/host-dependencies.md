# Host Dependencies

Tools used at build time by other ports to generate code or implement a custom build system can be packaged inside vcpkg.

## Consuming

When consuming a port as a tool, you must set the dependency's `"host"` field to true. For example:
```json
{
    "name": "contoso-http-library",
    "version-string": "1.0.0",
    "description": "Contoso's http runtime library",
    "dependencies": [
        "contoso-core-library",
        {
            "name": "contoso-code-generator",
            "host": true
        },
        {
            "name": "contoso-build-system",
            "host": true
        }
    ]
}
```
In this case, the `contoso-code-generator` and `contoso-build-system` (including any transitive dependencies) will be built and installed for the host triplet before `contoso-http-library` is built.

>Note: Consumers must use `vcpkg.json` instead of `CONTROL` as their metadata format. You can easily convert an existing `CONTROL` file using `vcpkg format-manifest /path/to/CONTROL`.

Then, within the portfile of the consumer (`contoso-http-library` in the example), the CMake variable `CURRENT_HOST_INSTALLED_DIR` will be defined to `installed/<host-triplet>` and should be used to locate any required assets. In the example, `contoso-code-generator` might have installed `tools/contoso-code-generator/ccg.exe` which the consumer would add to its local path via
```cmake
# ports/contoso-http-library/portfile.cmake
vcpkg_add_to_path(${CURRENT_HOST_INSTALLED_DIR}/tools/contoso-code-generator)
```

## Specifying the Host Triplet

The default host triplets are chosen based on the host architecture and operating system, for example `x64-windows`, `x64-linux`, or `x64-osx`. They can be overridden via:

1. In CMake-based manifest mode, calling `set(VCPKG_HOST_TRIPLET "<triplet>" CACHE STRING "")` before the first `project()` directive
2. In MSBuild-based manifest mode, setting the `VcpkgHostTriplet` property
3. On the command line, via the flag `--host-triplet=...`
4. The `VCPKG_DEFAULT_HOST_TRIPLET` environment variable

## Producing

Producing a tool has no special requirements; tools should be authored as a standard port, following all the normal policies and practices. Notably, they should build against `TARGET_TRIPLET`, not `HOST_TRIPLET` within the context of their portfile.

Sometimes, it can be useful to determine whether the current context is a cross-compiling one or not. This should be done by comparing the strings `TARGET_TRIPLET` and `HOST_TRIPLET`. For example:

```cmake
string(COMPARE EQUAL "${TARGET_TRIPLET}" "${HOST_TRIPLET}" I_AM_NOT_CROSSCOMPILING)

if(TARGET_TRIPLET STREQUAL HOST_TRIPLET)
    # This is a native build
else()
    # This is a cross build
endif()
```
