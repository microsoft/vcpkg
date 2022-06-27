# Pin old Boost versions
This document will teach you how to set versions of meta-packages like `boost` or `qt5`.

**What is a meta-package?**
In vcpkg we call meta-packages to ports that by themselves don't install anything but that instead forward installation to another port or ports. The reasons for these meta-packages to exist are plenty: to install different versions of a library depending on platform or to conveniently install/uninstall a catalog of related packages (Boost and Qt).

In the case of Boost, it is unlikely that a user requires all of the 140+ Boost libraries in their project. For the sake of convenience, vcpkg splits Boost into multiple sub-packages broken down to individual libraries. By doing so, users can limit the subset of Boost libraries that they depend on.

If a user wants to install all of the Boost libraries available in vcpkg, they can do so by installing the `boost` meta-package.

Due to the nature of meta-packages, some unexpected issues arise when trying to use them with versioning. If a user writes the following manifest file:

`vcpkg.json`
```json
{
    "name": "demo",
    "version": "1.0.0",
    "builtin-baseline": "787fe1418ea968913cc6daf11855ffd8b0b5e9d4",
    "dependencies": [ "boost-tuple" ],
    "overrides": [
        { "name": "boost", "version": "1.72.0" }
    ]
}
```

The resulting installation plan is:
```
The following packages will be built and installed:
    boost-assert[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-assert\3393715b4ebe30fe1c3b68acf7f84363e611f156
    boost-compatibility[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-compatibility\cda5675366367789659c59aca65fc57d03c51deb
    boost-config[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-config\ca82ca1b9c1739c91f3cf42c68cee56c896ae6bd
    boost-container-hash[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-container-hash\bf472c23d29c3d80b562c43471eb92cea998f372
    boost-core[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-core\20a19f6ece37686a02eed33e1f58add8b7a2582a
    boost-detail[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-detail\96744251f025f9b3c856a275dfc338031876777b
    boost-integer[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-integer\de70ce0d1500df1eda3496c4f98f42f5db256b4a
    boost-io[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-io\7bf3407372f8fc2a99321d24a0e952d44fe25bf3
    boost-preprocessor[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-preprocessor\8d78b8ba2e9f54cb00137115ddd2ffec1c63c149
    boost-static-assert[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-static-assert\2a41c4703c7122de25b1c60510c43edc9371f63d
    boost-throw-exception[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-throw-exception\b13bdf32a20786a0165cc20205ef63765cac0627
    boost-tuple[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-tuple\22e3d000a178a88992c430d8ae8a0244c7dea674
    boost-type-traits[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-type-traits\8829793f6c6c913257314caa317599f8d253a5ca
    boost-uninstall[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-uninstall\08933bad27b6d41caef0940c31e2069ecb6a079c
    boost-utility[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-utility\47572946bf6a63c731b9c4142eecb8bef3d3b270
    boost-vcpkg-helpers[core]:x64-windows -> 7#2 -- D:\vcpkg\buildtrees\versioning\versions\boost-vcpkg-helpers\2a21e5ab45d1ce41c185faf85dff0670ea6def1d
```

It is reasonable to expect that overriding `boost` to version 1.72.0 results in all Boost packages being pinned to version 1.72.0. **However, vcpkg does not treat the `boost` meta-package any differently that any other port.** In other words, vcpkg has no notion that `boost` is related to all the other `boost-*` libraries, other than it depends on all of them. For this reason, all the other boost packages are installed at version 1.75.0, which is the baseline version.

Below, we describe two methods to pin down Boost versions effectively.

## Method 1: Pin specific packages
Use `"overrides"` to force specific versions in a package-by-package basis.

`vcpkg.json`
```json
{
    "name": "demo",
    "version": "1.0.0",
    "builtin-baseline": "787fe1418ea968913cc6daf11855ffd8b0b5e9d4",
    "dependencies": [ "boost-tuple" ],
    "overrides": [
        { "name": "boost-core", "version": "1.72" },
        { "name": "boost-integer", "version": "1.72" },
        { "name": "boost-io", "version": "1.72" },
        { "name": "boost-tuple", "version": "1.72" }
    ]
}
```

This method allows you to quickly set the specific versions you want, but you will need to write an override for each package. Boost libraries are also heavily interdependent, which means that you may end up writing a lot of override lines.

The second method makes it easy to pin the entire Boost collection and end up with a very simple manifest file.

## Method 2: Modify baseline
An easy way to set the version for the entirety of boost is to use the `"builtin-baseline"` property.

As of right now, it is only possible to go back to Boost version `1.75.0` using a baseline, since that was the contemporary Boost version when the versioning feature was merged. **But, it is possible to modify the baseline to whatever you like and use that instead.**

### Step 1: Create a new branch
As described in the versioning documentation. The value that goes in `"builtin-baseline"` is a git commit in the microsoft/vcpkg repository's history. If you want to customize the baseline and have control over the vcpkg instance, you can create a new commit with said custom baseline.

Let's start by creating a new branch to hold our modified baseline.

In the directory containing your clone of the vcpkg Git repository run:

```
git checkout -b custom-boost-baseline
```

This will create a new branch named `custom-boost-baseline` and check it out immediately.

### Step 2: Modify the baseline
The next step is to modify the baseline file, open the file in your editor of choice and modify the entries for the Boost libraries.

Change the `"baseline"` version to your desired version.
_NOTE: Remember to also set the port versions to 0 (or your desired version)._

`${vcpkg-root}/versions/baseline.json`
```diff
...
     "boost": {
-      "baseline": "1.75.0",
+      "baseline": "1.72.0",
       "port-version": 0
     },
     "boost-accumulators": {
-      "baseline": "1.75.0",
-      "port-version": 1
+      "baseline": "1.72.0",
+      "port-version": 0
     },
     "boost-algorithm": {
-      "baseline": "1.75.0",
+      "baseline": "1.72.0",
       "port-version": 0
     },
     "boost-align": {
-      "baseline": "1.75.0",
+      "baseline": "1.72.0",
       "port-version": 0
     },
...
    "boost-uninstall: {
        "baseline": "1.75.0",
        "port-version": 0
    },
...
```

Some `boost-` packages are helpers used by vcpkg and are not part of Boost. For example, `"boost-uninstall"` is a vcpkg helper to conveniently uninstall all Boost libraries, but it didn't exist for Boost version `1.72.0`, in this case it is fine to leave it at `1.75.0` to avoid baseline errors (since all versions in `baseline.json` must have existed).

### Step 3: Commit your changes
After saving your modified file, run these commands to commit your changes:

```
git add versions/baseline.json
git commit -m "Baseline Boost 1.72.0"
```

You can set the commit message to whatever you want, just make it useful for you.

### Step 4: Get your baseline commit SHA
Once all your changes are ready, you can get the commit SHA by running:
```
git rev-parse HEAD
```

The output of that command will be the commit SHA you need to put as the `"builtin-baseline"` in your project's manifest file. Copy the 40-hex digits and save them to use later in your manifest file.

### Step 5: (Optional) Go back to the main repository branch
Once your changes have been committed locally, you can refer to the commit SHA regardless of the repository branch you're working on. So, let's go back to the main vcpkg repository branch.

```
git checkout master
```

### Step 6: Create your manifest file with your custom baseline

```json
{
    "name": "demo",
    "version": "1.0.0",
    "builtin-baseline": "9b5cf7c3d9376ddf43429671282972ec4f99aa85",
    "dependencies": [ "boost-tuple" ]
}
```

In this example, commit SHA `9b5cf7c3d9376ddf43429671282972ec4f99aa85` is the commit ID with the modified baseline. Even when a different branch (`master` in this case) is checked out, Git is able to find the commit as long as the branch with the modified baseline exists (the `custom-boost-baseline` branch we created in step 1).

We run `vcpkg install` in the directory containing our manifest file and the output looks like this:

```
The following packages will be built and installed:
    boost-assert[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-assert\6754398591f48435b28014ca0d60e5375a4c04d1
    boost-compatibility[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-compatibility\9893ff3c554575bc712df4108a949e07b269f401
    boost-config[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-config\de2784767046b06ec31eb718f10df512e51f2aad
    boost-container-hash[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-container-hash\cc19fb0154bbef188f309f49b2664ec7623b96b6
    boost-core[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-core\0eb5e20df9e267e9eca325be946f52ceb8a60229
    boost-detail[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-detail\759d7c6a3f9dbaed0b0c69fa0bb764f7606bb02d
    boost-integer[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-integer\173956c61a26e83b0f8b58b0baf60f06aeee637c
    boost-preprocessor[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-preprocessor\86eb3938b7875f124feb845331dbe84cbab5d1c6
    boost-static-assert[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-static-assert\e82d8f7f3ee07e927dc374f5a08ed6d6f4ef81f4
    boost-throw-exception[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-throw-exception\64df295f7df41de4fcb219834889b126b5020def
    boost-tuple[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-tuple\b3e1b01ffce6e367e4fed0a5538a8546abacb6b2
    boost-type-traits[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-type-traits\5e44ec657660eccf4d3b2710b092dd238e1e7a2d
    boost-uninstall[core]:x64-windows -> 1.75.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-uninstall\08933bad27b6d41caef0940c31e2069ecb6a079c
    boost-utility[core]:x64-windows -> 1.72.0 -- D:\vcpkg\buildtrees\versioning\versions\boost-utility\7d721b2458d5d595ac341eb54883274f38a4b8c2
    boost-vcpkg-helpers[core]:x64-windows -> 7#2 -- D:\vcpkg\buildtrees\versioning\versions\boost-vcpkg-helpers\2a21e5ab45d1ce41c185faf85dff0670ea6def1d
```

Notice how simple our manifest file has become, instead of having a multitude of `"overrides"` you can pin down all Boost packages just by setting the `"builtin-baseline"` to be your modified baseline commit SHA.
