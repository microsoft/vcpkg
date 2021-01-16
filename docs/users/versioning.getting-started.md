# Getting started with versioning

Vcpkg lets you take control of which version of packages to install in your projects using manifests. 

## Enabling versions

To start using the versioning feature first you need to enable the `versions` feature flag in any of the following manners:

* Setting the `VCPKG_FEATURE_FLAGS` environment variable.

```PowerShell
# Example for PowerShell
$env:VCPKG_FEATURE_FLAGS="versions"
./vcpkg install
```

* Passing the feature flags in the vcpkg command line.
```PowerShell
./vcpkg --feature-flags="versions" install
```

## Using versions with manifests

With the `versions` feature flag enabled you can now start addding version constraints to your dependencies.

Let's start with creating a simple CMake project that depends on `fmt`.

Create a folder with the following files:

**vcpkg.json**
```
{
    "name": "versions-test",
    "version": "1.0.0",
    "dependencies": [
        {
            "name": "fmt",
            "version>=": "7.1.3"
        }, 
        "zlib"
    ],
    "builtin-baseline": "b60f003ccf5fe8613d029f49f835c8929a66eb61"
}
```

**main.cpp**
```c++
#include <fmt/core.h>

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

project(versions-test CXX)

add_executable(main main.cpp)

find_package(ZLIB REQUIRED)
find_package(fmt CONFIG REQUIRED)
target_link_libraries(main PRIVATE ZLIB::ZLIB fmt::fmt)
```

And now we build and run our project with CMake:

1. Create the build directory for the project:
```
PS D:\versions-test> mkdir build
PS D:\versions-test> cd build
```

2. Configure CMake:  
```
PS D:\versions-test\build> cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=D:/vcpkg/scripts/buildsystems/vcpkg.cmake ..
-- Running vcpkg install
Detecting compiler hash for triplet x86-windows...
The following packages will be built and installed:
    fmt[core]:x86-windows -> 7.1.3 -- D:\vcpkg\buildtrees\versioning\versions\fmt\dd8cf5e1a2dce2680189a0744102d4b0f1cfb8b6
    zlib[core]:x86-windows -> 1.2.11#9 -- D:\vcpkg\buildtrees\versioning\versions\zlib\827111046e37c98153d9d82bb6fa4183b6d728e4
...
```

3. Build the project
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

You will notice that the output has also changed:

```
fmt[core]:x86-windows -> 7.1.3 -- D:\vcpkg\buildtrees\versioning\versions\fmt\dd8cf5e1a2dce2680189a0744102d4b0f1cfb8b6
zlib[core]:x86-windows -> 1.2.11#9 -- D:\vcpkg\buildtrees\versioning\versions\zlib\827111046e37c98153d9d82bb6fa4183b6d728e4
```

Instead of using the portfiles in `ports/`; vcpkg is checking out the files for each version in `buildtrees/versioning/versions/`.  The files in `ports/` are still used when running vcpkg in classic mode or when the `versions` feature flag is disabled. 

### Manifest changes
If you have used manifests before you will notice that there are also a couple of new fields. Let's analyze these changes:

* **`version>=`** 
```
"dependencies": [
    {
        "name": "fmt",
        "version>=": "7.1.3"
    }, 
    "zlib"
],
```

This field is used to express minimum version constraints, it is allowed only as part of the `"dependencies"` declarations. In our example we set an explicit constraint on version `7.1.3` of `fmt`. 

Vcpkg is allowed to upgrade this constraint if a transitive dependency requires a newer version. For example, if `zlib` were to declare a dependency on `fmt` version `7.1.4` then vcpkg would install `7.1.4` instead.

Vcpkg uses a minimum version approach, in our example, even if `fmt` version `8.0.0` were to be released, vcpkg will still install version `7.1.3` as that is the minimum version that satisfies the constraint. The advantages of this approach are that you don't get unexpected dependency upgrades when you update vcpkg and you get reproducible builds, in terms of version used, as long as you use the same manifest. 

If you want to upgrade your dependencies, you can bump the minimum version constraint or use any of the methods described below.

* **`builtin-baseline`**

```
"builtin-baseline": "b60f003ccf5fe8613d029f49f835c8929a66eb61"
```

This field declares the versioning baseline for all ports. But what is a baseline? What does it do? Why is the value a SHA? 

From the [versioning documentation](versioning.md):

> The baseline references a commit within the vcpkg repository that
establishes a minimum version on every dependency in the graph. If
no other constraints are specified (directly or transitively),
then the version from the baseline of the top level manifest will
be used.

In our example, you can notice that we do not declare a version constraint for `zlib`; instead, the version is taken from the baseline. Internally, vcpkg will look in commit `b60f003ccf5fe8613d029f49f835c8929a66eb61` to find out what version of `zlib` was the latest at that point in time (in our case this was `1.2.11#9`).

Baseline versions are treated as minimum version constraints when resolving versions. If you declare an explicit constraint that is lower than a baseline version, the explicit constraint will be upgraded to the baseline version. 

For example, if we modified our dependencies like this:
```
"dependencies": [
    {
        "name": "fmt",
        "version>=": "7.1.3"
    },
    {
        "name": "zlib",
        "version>=": "1.2.11#7"
    }
]
```

_NOTE: The value `1.2.11#7` represents version `1.2.11`, port version `7`._

Since the baseline introduces a minimum version constraint for `zlib` at `1.2.11#9` and a higher version does satisfy the minimum version constraint for `1.2.11#7`, vcpkg is allowed to upgrade it. 

Baseline are also a convenient mechanism to upgrade multiple versions at a time, for example, if you wanted to depend on multiple `boost` libraries, it is more convenient to set the `baseline` once than declaring a version constraint on each package.

But what if you want to specify a version older than the baseline? 

* **`overrides`**

Since baselines establish a version floor for all packages and explicit constraints get upgraded when they are lower than the baseline, we need another mechanism to downgrade versions past the baseline.

The mechanism vcpkg provides for that scenario is `overrides`. When an override is declared on a package, vcpkg will ignore all other version constraints either directly declared in the manifest or from transitive dependencies. In short, `overrides` will force vcpkg to use the exact version declared, period.

Let's modify our example once more, this time to force vcpkg to use version `6.0.0` of `fmt`.

```
{
    "name": "versions-test",
    "version": "1.0.0",
    "dependencies": [
        {
            "name": "fmt",
            "version>=": "7.1.3"
        },
        {
            "name": "zlib",
            "version>=": "1.2.11#7"
        }
    ],
    "builtin-baseline": "b60f003ccf5fe8613d029f49f835c8929a66eb61",
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

## Versions and overlay ports

The last thing to discuss is how overlay ports interact with versioning resolution. The answer is: they don't. 

Going into more detail, when you provide an overlay for a port, vcpkg will always use the overlay port without caring what version is contained in the overlayed port. 

The reason is that overlay ports do not contain (and are not expected to) provide enough information to power vcpkg's versioning features. If you're interesting in delving deeper into the details of how versioning works in vcpkg it is recommended that you read the [versioning specification](../specifications/versioning.md).

If you want to have port customization with versioning features enabled, you should look into making your own custom registry. See our [registries specification for more details](../specifications/registries.md).


See also:

* [Versioning docs](versioning.md)
* [Original specification](../specifications/versioning.md)
* **[TBR]** [Version files](../versioning.version-files.md)
* **[TBR]** [Versioning implementation details](../versioning.implementation-details.md)
