## Exporting to Android Archives (AAR files)

Vcpkg current supports exporting to android archive files([AAR files](https://developer.android.com/studio/projects/android-library)). Once the archive is created it can imported in Android Studio as a native dependent.  The archive is automatically consumed using [android studio's prefab tool](https://github.com/google/prefab). For more information on Prefab checkout the following article ["Native Dependencies in Android Studio 4.0"](https://android-developers.googleblog.com/2020/02/native-dependencies-in-android-studio-40.html) and the documentation on how to use prefab on [https://google.github.io/prefab/](https://google.github.io/prefab).

#### To support export to android the following tools should be available;

- `maven <optional>`
- `ndk <required>`
- `7zip <required on windows>` or `zip <required on linux>`

**Android triplets that support the following architectures arm64-v8a, armeabi-v7a, x86_64 x86 must be present**

#### An example of a triplet configuration targeting android would be

```cmake
set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CMAKE_SYSTEM_NAME Android)
```

The following table outlines the mapping from vcpkg architectures to android architectures

|vcpkg architecture | android architecture |
|-------------------|----------------------|
|arm64              | arm64-v8a            |
|arm                | armeabi-v7a          |
|x64                | x86_64               |
|x86                | x86                  |

**Please note the four architectures are required. If any is missing the export will fail**
**To export the following environment `ANDROID_NDK_HOME` variable is required for exporting**

#### Example exporting [jsoncpp]
The `--prefab-maven` flag is option. Only call it when you have maven installed
```
./vcpkg export --triplet x64-android jsoncpp --prefab --prefab-maven
```

```
The following packages are already built and will be exported:
    jsoncpp:x86-android
Exporting package jsoncpp...
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------< org.apache.maven:standalone-pom >-------------------
[INFO] Building Maven Stub Project (No POM) 1
[INFO] --------------------------------[ pom ]---------------------------------
[INFO]
[INFO] --- maven-install-plugin:2.4:install-file (default-cli) @ standalone-pom ---
[INFO] Installing<root>/prefab/jsoncpp/jsoncpp-1.9.2.aar to /.m2/repository/com/vcpkg/ndk/support/jsoncpp/1.9.2/jsoncpp-1.9.2.aar
[INFO] Installing <vcpkg_root>/prefab/jsoncpp/pom.xml to /.m2/repository/com/vcpkg/ndk/support/jsoncpp/1.9.2/jsoncpp-1.9.2.pom
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  0.301 s
[INFO] Finished at: 2020-03-01T10:18:15Z
[INFO] ------------------------------------------------------------------------
In app/build.gradle

    com.vcpkg.ndk.support:jsoncpp:1.9.2

And cmake flags

    externalNativeBuild {
                cmake {
                    arguments '-DANDROID_STL=c++_shared'
                    cppFlags "-std=c++17"
                }
            }

In gradle.properties

    android.enablePrefab=true
    android.enableParallelJsonGen=false
    android.prefabVersion=${prefab.version}

Successfuly exported jsoncpp. Checkout <vcpkg_root>/prefab/jsoncpp/aar
```

#### The output directory after export
```
prefab
└── jsoncpp
    ├── aar
    │   ├── AndroidManifest.xml
    │   ├── META-INF
    │   │   └── LICENCE
    │   └── prefab
    │       ├── modules
    │       │   └── jsoncpp
    │       │       ├── include
    │       │       │   └── json
    │       │       │       ├── allocator.h
    │       │       │       ├── assertions.h
    │       │       │       ├── autolink.h
    │       │       │       ├── config.h
    │       │       │       ├── forwards.h
    │       │       │       ├── json.h
    │       │       │       ├── json_features.h
    │       │       │       ├── reader.h
    │       │       │       ├── value.h
    │       │       │       ├── version.h
    │       │       │       └── writer.h
    │       │       ├── libs
    │       │       │   ├── android.arm64-v8a
    │       │       │   │   ├── abi.json
    │       │       │   │   └── libjsoncpp.so
    │       │       │   ├── android.armeabi-v7a
    │       │       │   │   ├── abi.json
    │       │       │   │   └── libjsoncpp.so
    │       │       │   ├── android.x86
    │       │       │   │   ├── abi.json
    │       │       │   │   └── libjsoncpp.so
    │       │       │   └── android.x86_64
    │       │       │       ├── abi.json
    │       │       │       └── libjsoncpp.so
    │       │       └── module.json
    │       └── prefab.json
    ├── jsoncpp-1.9.2.aar
    └── pom.xml

13 directories, 25 files
```
