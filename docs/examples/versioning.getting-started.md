# Getting started with versioning

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/examples/versioning.getting-started.md).**

Vcpkg lets you take control of which version of packages to install in your projects using manifests. 

## Using versions with manifests

Let's start with creating a simple CMake project that depends on `fmt` and `zlib`.

Create a folder with the following files:

**vcpkg.json**
```json
{
    "name": "versions-test",
    "version": "1.0.0",
    "dependencies": [
        {
            "name": "fmt",
            "version>=": "7.1.3#1"
        }, 
        "zlib"
    ],
    "builtin-baseline": "3426db05b996481ca31e95fff3734cf23e0f51bc"
}
```

**main.cpp**
```c++
#include <fmt/core.h>
#include <zlib.h>

int main()
{
    fmt::print("fmt version is {}\n"
               "zlib version is {}\n", 
               FMT_VERSION, ZLIB_VERSION);
    return 0;
}
```

**CMakeLists.txt**
```CMake
cmake_minimum_required(VERSION 3.18)

project(versionstest CXX)

add_executable(main main.cpp)

find_package(ZLIB REQUIRED)
find_package(fmt CONFIG REQUIRED)
target_link_libraries(main PRIVATE ZLIB::ZLIB fmt::fmt)
```

And now we build and run our project with CMake:

1. Create the build directory for the project.
```
PS D:\versions-test> mkdir build
PS D:\versions-test> cd build
```

2. Configure CMake.  
```
PS D:\versions-test\build> cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=D:/vcpkg/scripts/buildsystems/vcpkg.cmake ..
-- Running vcpkg install
Detecting compiler hash for triplet x86-windows...
The following packages will be built and installed:
    fmt[core]:x64-windows -> 7.1.3#1 -- D:\Work\viromer\vcpkg\buildtrees\versioning\versions\fmt\4f8427eb0bd40da1856d4e67bde39a4fda689d72
    vcpkg-cmake[core]:x64-windows -> 2021-02-26 -- D:\Work\viromer\vcpkg\buildtrees\versioning\versions\vcpkg-cmake\51896aa8073adb5c8450daa423d03eedf0dfc61f
    vcpkg-cmake-config[core]:x64-windows -> 2021-02-26 -- D:\Work\viromer\vcpkg\buildtrees\versioning\versions\vcpkg-cmake-config\d255b3d566a8861dcc99a958240463e678528066
    zlib[core]:x64-windows -> 1.2.11#9 -- D:\Work\viromer\vcpkg\buildtrees\versioning\versions\zlib\827111046e37c98153d9d82bb6fa4183b6d728e4
...
```

3. Build the project.
```
PS D:\versions-test\build> cmake --build .
[2/2] Linking CXX executable main.exe
```

4. Run it!
```
PS D:\versions-test\build> ./main.exe
fmt version is 70103
zlib version is 1.2.11
```

Take a look at the output:

```
fmt[core]:x86-windows -> 7.1.3#1 -- D:\vcpkg\buildtrees\versioning\versions\fmt\4f8427eb0bd40da1856d4e67bde39a4fda689d72
...
zlib[core]:x86-windows -> 1.2.11#9 -- D:\vcpkg\buildtrees\versioning\versions\zlib\827111046e37c98153d9d82bb6fa4183b6d728e4
```

Instead of using the portfiles in `ports/`, vcpkg is checking out the files for each version in `buildtrees/versioning/versions/`. The files in `ports/` are still used when running vcpkg in classic mode.

_NOTE: Output from vcpkg while configuring CMake is only available when using CMake version `3.18` or newer. If you're using an older CMake you can check the `vcpkg-manifest-install.log` file in your build directory instead._

Read our [manifests announcement blog post](https://devblogs.microsoft.com/cppblog/vcpkg-accelerate-your-team-development-environment-with-binary-caching-and-manifests/#using-manifests-with-msbuild-projects) to learn how to use manifests with MSBuild.

### Manifest changes
If you have used manifests before you will notice that there are some new JSON properties. Let's review these changes:

#### **`version`**
```json
{
    "name": "versions-test",
    "version": "1.0.0"
}
```

This is your project's version declaration. Previously, you could only declare versions for your projects using the `version-string` property. Now that versioning has come around, vcpkg is aware of some new versioning schemes.

Version scheme   | Description
---------------- | ---------------
`version`        | Dot-separated numerics: `1.0.0.5`.
`version-semver` | Compliant [semantic versions](https://semver.org): `1.2.0` and `1.2.0-rc`.
`version-date`   | Dates in `YYYY-MM-DD` format: `2021-01-01`
`version-string` | Arbitrary strings: `vista`, `candy`.

#### **`version>=`** 
```json
{
    "dependencies": [
        { "name": "fmt", "version>=": "7.1.3" },
        "zlib"
    ]
}
```

This property is used to express minimum version constraints, it is allowed only as part of the `"dependencies"` declarations. In our example we set an explicit constraint on version `7.1.3#1` of `fmt`. 

Vcpkg is allowed to upgrade this constraint if a transitive dependency requires a newer version. For example, if `zlib` were to declare a dependency on `fmt` version `7.1.4` then vcpkg would install `7.1.4` instead.

Vcpkg uses a minimum version approach, in our example, even if `fmt` version `8.0.0` were to be released, vcpkg would still install version `7.1.3#1` as that is the minimum version that satisfies the constraint. The advantages of this approach are that you don't get unexpected dependency upgrades when you update vcpkg and you get reproducible builds (in terms of version used) as long as you use the same manifest. 

If you want to upgrade your dependencies, you can bump the minimum version constraint or use a newer baseline.

#### **`builtin-baseline`**

```json
{ "builtin-baseline": "3426db05b996481ca31e95fff3734cf23e0f51bc" }
```

This field declares the versioning baseline for all ports. Setting a baseline is required to enable versioning, otherwise you will get the current versions on the ports directory. You can run 'git rev-parse HEAD' to get the current commit of vcpkg and set it as the builtin-baseline. See the [`builtin-baseline` documentation](../users/versioning.md#builtin-baseline) for more information.

In our example, you can notice that we do not declare a version constraint for `zlib`; instead, the version is taken from the baseline. Internally, vcpkg will look in commit `3426db05b996481ca31e95fff3734cf23e0f51bc` to find out what version of `zlib` was the latest at that point in time (in our case it was `1.2.11#9`).

During version resolution, baseline versions are treated as minimum version constraints. If you declare an explicit constraint that is lower than a baseline version, the explicit constraint will be upgraded to the baseline version. 

For example, if we modified our dependencies like this:
```json
{ "dependencies": [
    {
        "name": "fmt",
        "version>=": "7.1.3#1"
    },
    {
        "name": "zlib",
        "version>=": "1.2.11#7"
    }
] }
```

_NOTE: The value `1.2.11#7` represents version `1.2.11`, port version `7`._

Since the baseline introduces a minimum version constraint for `zlib` at `1.2.11#9` and a higher version does satisfy the minimum version constraint for `1.2.11#7`, vcpkg is allowed to upgrade it. 

Baselines are also a convenient mechanism to upgrade multiple versions at a time, for example, if you wanted to depend on multiple `boost` libraries, it is more convenient to set the `baseline` once than declaring a version constraint on each package.

But what if you want to pin a version older than the baseline? 

#### **`overrides`**

Since baselines establish a version floor for all packages and explicit constraints get upgraded when they are lower than the baseline, we need another mechanism to downgrade versions past the baseline.

The mechanism vcpkg provides for that scenario is `overrides`. When an override is declared on a package, vcpkg will ignore all other version constraints either directly declared in the manifest or from transitive dependencies. In short, `overrides` will force vcpkg to use the exact version declared, period.

Let's modify our example once more, this time to force vcpkg to use version `6.0.0` of `fmt`.

```json
{
    "name": "versions-test",
    "version": "1.0.0",
    "dependencies": [
        {
            "name": "fmt",
            "version>=": "7.1.3#1"
        },
        {
            "name": "zlib",
            "version>=": "1.2.11#7"
        }
    ],
    "builtin-baseline": "3426db05b996481ca31e95fff3734cf23e0f51bc",
    "overrides": [
        {
            "name": "fmt",
            "version": "6.0.0"
        }
    ]
}
```

Rebuild our project:

```
PS D:\versions-test\build> rm ./CMakeCache.txt
PS D:\versions-test\build> rm -r ./vcpkg_installed
PS D:\versions-test\build> cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=D:/vcpkg/scripts/buildsystems/vcpkg.cmake ..
-- Running vcpkg install
Detecting compiler hash for triplet x86-windows...
The following packages will be built and installed:
    fmt[core]:x86-windows -> 6.0.0 -- D:\vcpkg\buildtrees\versioning\versions\fmt\d99b6a35e1406ba6b6e09d719bebd086f83ed5f3
    zlib[core]:x86-windows -> 1.2.11#9 -- D:\vcpkg\buildtrees\versioning\versions\zlib\827111046e37c98153d9d82bb6fa4183b6d728e4
...
PS D:\versions-test\build> cmake --build .
[2/2] Linking CXX executable main.exe
```

And run it!
```
PS D:\versions-test\build> .\main.exe
fmt version is 60000
zlib version is 1.2.11
```

Notice how the `fmt` is now at version `6.0.0` just like we wanted.

## Versions and custom ports

The last thing to discuss is how overlay ports interact with versioning resolution. The answer is: they don't.

Going into more detail, when you provide an overlay for a port, vcpkg will always use the overlay port without caring what version is contained in it. The reasons are two-fold: (1) it is consistent with the existing behavior of overlay ports of completely masking the existing port, and (2) overlay ports do not (and are not expected to) provide enough information to power vcpkg's versioning feature.

If you want to have flexible port customization along with versioning, you should consider making your own custom registry. See our [registries specification for more details](../specifications/registries.md).

## Further reading

If you're interested in delving deeper into the details of how versioning works we recommended that you read the [original versioning specification](../specifications/versioning.md) and the [implementation details](../users/versioning.implementation-details.md).

See also:

* [Versioning docs](../users/versioning.md)
* [Original specification](../specifications/versioning.md)
* [Versioning implementation details](../users/versioning.implementation-details.md)
