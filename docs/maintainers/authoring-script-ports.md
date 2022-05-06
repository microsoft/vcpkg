# Authoring Script Ports

Ports can expose functions for other ports to consume during their build. For
example, the `vcpkg-cmake` helper port exposes the `vcpkg_cmake_configure()`
helper function. Packaging common scripts into a shared helper port makes
maintenance easier because all consumers can be updated from a single place.
Because the scripts come from a port, they can be versioned and depended upon
via all the same mechanisms as any other port.

Script ports are implemented via the `vcpkg-port-config.cmake` extension
mechanism. Before invoking the `portfile.cmake` of a port, vcpkg will first
import `share/<port>/vcpkg-port-config.cmake` from each direct dependency. If
the direct dependency is a host dependency, the import will be performed in the
host installed tree (e.g.
`${HOST_INSTALLED_DIR}/share/<port>/vcpkg-port-config.cmake`).

Only direct dependencies are considered for `vcpkg-port-config.cmake` inclusion.
This means that if a script port relies on another script port, it must
explicitly import the `vcpkg-port-config.cmake` of its dependency.

Script-to-script dependencies should not be marked as host. The dependency from
a target port to a script should be marked host, which means that scripts should
always already be natively compiling. By making script-to-script dependencies
`"host": false`, it ensures that one script can depend upon the other being in
its same install directory.

Ports should never provide a `vcpkg-port-config.cmake` file under a different
`share/` subdirectory than the current port (`${PORT}`).

## Example

```cmake
# ${CURRENT_PACKAGES_DIR}/share/my-helper/vcpkg-port-config.cmake

# This include guard ensures the file will be loaded only once
include_guard(GLOBAL)

# This is how you could pull in a transitive dependency
include("${CMAKE_CURRENT_LIST_DIR}/../my-other-helper/vcpkg-port-config.cmake")

# Finally, it is convention to put each public function into a separate file with a matching name
include("${CMAKE_CURRENT_LIST_DIR}/my_helper_function_01.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/my_helper_function_02.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/my_helper_function_03.cmake")
```
