# Vcpkg: export Android prefab Archives (AAR files)

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

Vcpkg can export android archives ([AAR files](https://developer.android.com/studio/projects/android-library)). Once an archive is created, it can imported in Android Studio as a native dependent.  The archive is automatically consumed using [android studio's prefab tool](https://github.com/google/prefab). 

For more information on Prefab, refer to:
* The [official prefab documentation](https://google.github.io/prefab).
* a blog post from Android developers blog: [Native Dependencies in Android Studio 4.0](https://android-developers.googleblog.com/2020/02/native-dependencies-in-android-studio-40.html) 

_Note for Android Studio users: prefab packages are supported on Android Studio 4+_

## Requirements

1. `ndk <required>`

Set environment variable `ANDROID_NDK_HOME` to your android ndk installation. For example:

````
export ANDROID_NDK_HOME=/home/your-account/Android/Sdk/ndk-bundle
````

2. `7zip <required on windows>` or `zip <required on linux>`

3. `maven <optional>`

4. Android triplets

See [android.md](../users/android.md) for instructions on how to install the triplets.

*Please note that in order to use "prefab" (see below), the four architectures are required. If any is missing the export will fail*


## Example exporting [jsoncpp]

First "vcpkg install" the 4 android architectures (it is mandatory to export all 4 of them)

````
./vcpkg install jsoncpp:arm-android  jsoncpp:arm64-android  jsoncpp:x64-android  jsoncpp:x86-android
````


Then, export the prefab:

Note:
* The `--prefab-maven` flag is optional. Call it if you maven is installed.
* The `--prefab-debug` flag will output instructions on how to use the prefab archive via gradle.

```
./vcpkg export --triplet x64-android jsoncpp --prefab --prefab-maven --prefab-debug
```

You will see an output like this:
```
The following packages are already built and will be exported:
    jsoncpp:arm64-android

Exporting package jsoncpp...
[DEBUG] Found 4 triplets
	arm64-android
	x64-android
	x86-android
	arm-android

...
... Lots of output...
...

[INFO] Scanning for projects...
Downloading from central: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-clean-plugin/2.5/maven-clean-plugin-2.5.pom

...
... Lots of output...
...

[INFO] BUILD SUCCESS
[INFO] Total time:  2.207 s
[INFO] Finished at: 2020-05-10T14:42:28+02:00


...
... Lots of output...
...

[DEBUG] Configuration properties in Android Studio
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

Successfully exported jsoncpp. Checkout .../vcpkg/prefab 

```

#### The output directory after export

````
prefab
└── jsoncpp/
    ├── aar/
    │   ├── AndroidManifest.xml
    │   ├── META-INF/
    │   │   └── LICENSE
    │   └── prefab/
    │       ├── modules/
    │       │   └── jsoncpp/
    │       │       ├── libs/
    │       │       │   ├── android.arm64-v8a/
    │       │       │   │   ├── abi.json
    │       │       │   │   ├── include/
    │       │       │   │   │   └── json/
    │       │       │   │   │       ├── json.h
    │       │       │   │   │       └── ....
    │       │       │   │   └── libjsoncpp.so
    │       │       │   ├── android.armeabi-v7a/
    │       │       │   │   ├── abi.json
    │       │       │   │   ├── include/
    │       │       │   │   │   └── json/
    │       │       │   │   │       ├── json.h
    │       │       │   │   │       └── ....
    │       │       │   │   └── libjsoncpp.so
    │       │       │   ├── android.x86/
    │       │       │   │   ├── abi.json
    │       │       │   │   ├── include/
    │       │       │   │   │   └── json/
    │       │       │   │   │       ├── json.h
    │       │       │   │   │       └── ....
    │       │       │   │   └── libjsoncpp.so
    │       │       │   └── android.x86_64/
    │       │       │       ├── abi.json
    │       │       │       ├── include/
    │       │       │       │   └── json/
    │       │       │   │   │       ├── json.h
    │       │       │   │   │       └── ....
    │       │       │       └── libjsoncpp.so
    │       │       └── module.json
    │       └── prefab.json
    ├── jsoncpp-1.9.2.aar
    └── pom.xml
````

## Example consuming [jsoncpp] via vcpkg and prefab

See the example repo here:

https://github.com/atkawa7/prefab-vpkg-integration-sample
