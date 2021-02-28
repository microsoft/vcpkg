# Selecting library features

## Installing a library

We will look at [llvm](https://llvm.org/) as an example.
LLVM is a compiler infrasture. It supports optimizing llvm-ir and generating machine code.
You could install it using:

```powershell
> .\vcpkg install llvm
```

On Windows, this will install the 32-bit x86 LLVM, since that's the default triplet on Windows.
If you are building for 64-bit Windows instead, you can use the following command to change the default triplet:

```powershell
> .\vcpkg install --triplet x64-windows llvm
```

We have more documentation on triplets [here](triplets.md).
Currently we can't choose build type `debug` or `release` using command line switches.

With llvm now installed, we can execute:

```powershell
> # llc takes llvm IR and generates machine code
> .\installed\x86-windows\bin\llc.exe --version # or x86-windows, or replace with the actual triplet
```

we see:

```powershell
  Registered Targets:
    x86    - 32-bit X86: Pentium-Pro and above
    x86-64 - 64-bit X86: EM64T and AMD64
```

## Installing additional features

But [llvm supports many more targets](https://llvm.org/docs/GettingStarted.html#local-llvm-configuration), from ARM to SPARC to SystemZ.
However, clearly our current installation doesn't include ARM as a target;
thus, we need to learn how vcpkg allows us to install other LLVM targets.
The llvm port allows this via the "target-*" features.

If we do:

```powershell
.\vcpkg search llvm
```

We can see:

```
llvm                 10.0.0#6         The LLVM Compiler Infrastructure
llvm[clang]                           Build C Language Family Front-end.
llvm[clang-tools-extra]               Build Clang tools.
...
llvm[target-all]                      Build with all backends.
llvm[target-amdgpu]                   Build with AMDGPU backend.
llvm[target-arm]                      Build with ARM backend.
...
```

We can install any of these targets by using the install-feature syntax:

```powershell
> .\vcpkg install llvm[target-arm] # Installs LLVM with the ARM target
```

## Opting out of default feature
The llvm port includes a few default features that you as a user may not want: for example,
the `clang` feature is default, which means that `vcpkg install llvm` will also build and install clang.
If you are writing a compiler that uses LLVM as a backend,
you're likely not interested in installing clang as well,
and we can do that by disabling default features with the special `core` "feature":
```powershell
> .\vcpkg install llvm[core,default-targets] # removing the default-feature with "core" also removes all of the default targets you get
```

# Further reading
- The [Feature Packages](specifications/feature-packages.md) specification was the initial design for features.
