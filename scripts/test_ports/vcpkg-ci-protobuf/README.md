# Protobuf runtime feature validation

The `protobuf` core package provides `protobuf::libprotobuf-lite`. Consumers of
reflection, descriptors, text/JSON conversion, or full generated messages request
`protobuf[full-runtime]`. This feature is opt-in and is not a default feature.
`libprotoc` and `zlib` require it explicitly.

```json
{
  "name": "protobuf",
  "version>=": "7.36.1",
  "default-features": false,
  "features": ["full-runtime"]
}
```

Lite consumers use generated messages with `option optimize_for = LITE_RUNTIME;`
and link `protobuf::libprotobuf-lite`. A simple application is not automatically
a lite consumer: its generated code, imported schemas, API use, and transitive
dependencies determine its runtime requirements.
With a versioned manifest, require `7.36.1` or later for the lite-target
behavior; older protobuf port revisions still provide full in core.

The compiler remains an automatic host dependency. Host and target requests for
the same port and triplet share the union of their features. Therefore, equal
host/target triplets still install the full runtime. Different triplets allow a
lite target, including different Windows linkage triplets on the same machine.
A full-runtime request from another consumer also promotes the target to full.

The implementation uses the `protobuf_BUILD_LIBPROTOBUF` option provided by
the released Protobuf 7.36.1 source. It does not require a runtime-selection
backport. The upstream release update is a separate prerequisite. Existing
registry consumers retain their previous full-runtime dependency; adopting lite
in each consumer requires separate source and build validation.

Although features remain additive, removing the full runtime from core changes
the existing consumer contract. External projects that link the full runtime
must also request `full-runtime` when adopting this port revision. Migrating the
registry consumers does not update application manifests outside the registry.
The installed `share/protobuf/usage` file explains the manifest and CMake
migration at the point of consumption. Request `libprotoc` explicitly when
building a plugin that links the compiler library; installing the host `protoc`
executable alone does not provide that target library.

## Build the consumers

Run from the repository root with an initialized compiler environment. The
examples deliberately use distinct target and host triplets. Set
`VCPKG_MAX_CONCURRENCY=1` when preserving machine responsiveness is necessary.

```text
vcpkg install vcpkg-ci-protobuf[core]:x64-windows-static --host-triplet=x64-windows --overlay-ports=scripts/test_ports
vcpkg install vcpkg-ci-protobuf[core,full-runtime]:x64-windows-static --host-triplet=x64-windows --overlay-ports=scripts/test_ports
vcpkg install vcpkg-ci-protobuf[core,libprotoc,zlib]:x64-windows-static --host-triplet=x64-windows --overlay-ports=scripts/test_ports
```

Use an isolated installation for this test matrix. vcpkg features accumulate in
classic mode, so a previously installed full package is not a lite-only test.
For each case, inspect the installed package and the resolved plan. A lite target
has `protobuf-lite.pc` and the lite library, with no target `libprotobuf`,
`libprotoc`, `libupb`, or `protobuf.pc`. Tools copied from the host are separate
from this target-runtime assertion.

Verify the isolated core installation before moving to the full cases. Reuse
the test-port build directory created by the first installation:

```text
cmake -S scripts/test_ports/vcpkg-ci-protobuf/project -B buildtrees/vcpkg-ci-protobuf/x64-windows-static-rel -DPROTOBUF_TEST_LITE_ONLY=ON -DPROTOBUF_TEST_FULL=OFF -DPROTOBUF_TEST_LIBPROTOC=OFF -DPROTOBUF_TEST_ZLIB=OFF -DPROTOBUF_TEST_PACKAGE_NAME=Protobuf
```

This must fail if a previously installed full package, a native host request,
or another consumer has brought full into the target. The expected diagnostic
names the unexpected target. Repeat with `-DPROTOBUF_TEST_PACKAGE_NAME=protobuf`
to verify first discovery using the other spelling. Separate CMake invocations
prevent the first successful lookup from hiding a failure in the other spelling.
Repeat for the Debug build directory when present.

For full and mixed-graph validation, set `PROTOBUF_TEST_LITE_ONLY=OFF`. The
project also builds the full consumer whenever the full target is present,
even when `PROTOBUF_TEST_FULL=OFF`, so a transitive full-runtime request tests
both libraries. Requesting `PROTOBUF_TEST_LIBPROTOC=ON` without the compiler
library must report the missing `libprotoc` target.

The test port builds executables for:

- Host-generated lite messages with integer, string, byte, repeated, and map
  fields; binary serialization and parsing must preserve their values.
- Full-runtime reflection and text-format serialization.
- Importing a schema and running a custom generator through the public target
  `libprotoc` API.
- Gzip stream compression and decompression.

It also checks CONFIG discovery with both `protobuf` and `Protobuf` spellings,
and legacy module variables when the full runtime is requested. Lite CONFIG
discovery does not alias `protobuf::libprotobuf` to the lite library. Explicit
module compatibility on a lite installation produces a missing-package
diagnostic explaining the `full-runtime` requirement.

CI's shared installation may contain full because another port requested it.
Successfully building the core test port in that graph proves that its lite
consumer still works with full installed; it does not prove a lite-only package.
The isolated installation, strict target check, and package inspection above
are required evidence for that claim. The test port compiles the consumers;
runtime execution is a separate CTest step.

On a machine that can execute the selected target, run CTest in the existing
test-port build directories:

```text
ctest --test-dir buildtrees/vcpkg-ci-protobuf/x64-windows-static-rel --output-on-failure
ctest --test-dir buildtrees/vcpkg-ci-protobuf/x64-windows-static-dbg --output-on-failure
```

For dynamic linkage, make the corresponding target `bin` or `debug/bin`
directory available to the process running the tests. Do not attempt to execute
cross-architecture binaries on an incompatible host. Repeat the core case with
dynamic target linkage and different host/target triplets to exercise DLL
exports. Native full builds alone cannot validate lite-only packaging.

## Benchmark boundaries

Compare the same source release, compiler, target triplet, build configurations,
dependencies, concurrency, and cache policy. The full target baseline excludes
target compiler libraries, matching the existing non-native port behavior.
Measure the lite target with the same host compiler already installed.

Report these costs separately:

1. Host compiler and its dependencies from a cold build.
2. Target dependency preparation.
3. Target protobuf configure, build, install, and package fixup.
4. Runtime library bytes, debug symbols, headers, and copied host tools.
5. Binary-cache restoration, if explicitly measured.

Disable binary-cache restoration for source-build timing. `--no-downloads`
requires the necessary source archives and tools to be cached already. Record
failures and retries separately from successful measurement samples. A single
sample is descriptive evidence for that machine, not a statistical estimate or
a promise of the same percentage for complete dependency installations.
