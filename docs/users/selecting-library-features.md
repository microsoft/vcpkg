# Selecting library features

## Installing a library

By now you have tried out installing some library with `vcpkg`. We will look at [llvm](https://llvm.org/) as an example.
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

You can read more about [triplets](https://vcpkg.readthedocs.io/en/latest/users/triplets/) here.
Sadly currently we can't choose build type `debug` or `release` using command line switches.

With llvm installed, if we try to execute:

```powershell
# llc takes llvm IR and generates machine code
.\packages\llvm_x64-windows-static\bin\llc.exe --version
```

we see:

```powershell
  Registered Targets:
    x86    - 32-bit X86: Pentium-Pro and above
    x86-64 - 64-bit X86: EM64T and AMD64
```

## Installing additional features

But [llvm (10) supports many more targets](https://llvm.org/docs/GettingStarted.html#local-llvm-configuration), `AArch64, AMDGPU, ARM, BPF, Hexagon, Mips, MSP430, NVPTX, PowerPC, Sparc, SystemZ, X86, XCore`.
How can we have arm target?

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

We can install "feature":

```powershell
.\vcpkg install --triplet x64-windows-static llvm[target-arm]
```

## Opting out of default feature
When we installed llvm, we also got [clang](https://clang.llvm.org/) `.\packages\llvm_x64-windows-static\bin\clang.exe`. But what if we are not interested pre-bundled `clang`
"c" language frontend (to convert c/c++ to llvm-ir)?
We can only install llvm as:
```powershell
.\vcpkg install --triplet x64-windows-static llvm[core]
```

and later add targets and clang as desired.

# Further reading
- [Feature Packages](specifications/feature-packages.md)
