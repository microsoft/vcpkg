# External project and exported binary Import (Mar 3, 2018)

## 1. Motivation

### A. Quick port of external MSBuild projects

Vcpkg ports developers want to be able to bulid their project on `vcpkg` quickly. Therefore, there is a
value to import external MSBuild project into `vcpkg` as new ports.

### B. Build once, and re-use it again and again

Customers and vcpkg ports developers want to be able to build their set of required libraries once,
and then put the resulting binaries on somewhere accesible and use it on their project repeatedly.
Typical use case is;

- CI for Vcpkg Ports development, in which vcpkg ports developer want to test their updated script quickly
  on CI on a cloud-based farm of build machines.

Building once and sharing ensures that everyone gets exactly the same binaries, isolates the building effort to a small number of people and minimizes friction to obtain them.
If we can re-import an exported binaries, vcpkg developer be also happier. 
Therefore, there is value in enabling users to easily import to `vcpkg`.

### C. Very large libraries

Libraries like [Qt][] can take a very long time to build (5+ hours). Therefore, having the ability to build them and then distribute the binaries and re-import it can save a lot of time.

## 2. Proposed solution

This document proposes the extenstion of `vcpkg import` command not only import from external project but also
import exported binary package by `vcpkg export`. 

## 3. Command Lines

### A. Import external project

```
> vcpkg import --ext --control C:\path\to\CONTROLfile --include C:\path\to\includedir --project C:\path\to\projectdir
```

### B. Import exported package file

```
> vcpkg import --vc --pkg c:\path\to\exported_package_file.7z
```