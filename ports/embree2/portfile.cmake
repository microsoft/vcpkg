set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

message(FATAL_ERROR [=[
The embree2 port is no longer updated and does not build with current tbb versions.
Use embree3 instead.
If you must use this port in your project, pin an older version of this port via a manifest file.
See https://vcpkg.io/en/docs/examples/versioning.getting-started.html for instructions.
]=])
