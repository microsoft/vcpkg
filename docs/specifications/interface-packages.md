# Proposal: Interface Packages (Aug 02 2017)

## 1. Motivation

Some libraries do have dependencies to not one specific library but rather to a (sometimes standardized) interface that can be implemented by multiple different libraries. Examples are BLAS, MPI or SSL. While a library consuming BLAS in general does not care how the required functions are implemented there are many different vendor implementations where each of them has some advantages and disadvantages over the other ones (OpenBLAS, Intel MKL, reference (netlib) BLAS/LAPACK, ...).

It should be possible for the user to specify which implementation of an interface he wants to use.

## 2. Other design concerns

- While giving the possibility to ports to depend on just an interface, it should still be possible for a port to request a specific implementation, if it has to.
- If the user does not care which implementation should be used for an interface, a reasonable default should be installed automatically.
- To simplify handling dependencies and maintain a correct install/uninstall order, this proposal depends on feature-packages (#1205) being implemented first.

## 3. Proposed solution

- In the CONTROL file of a port, we add an additional group called `Provides`. Under this group a port can specify which interfaces it implements. E.g.
```
# ports/openssl/CONTROL
Source: openssl
Version: 1.0.2l-1
Description: OpenSSL is an open source project ...
Provides: ssl
```
- Other ports can now depend on the abstract interface `ssl` instead of the specific implementation. E.g.:
```
# ports/libpq/CONTROL
Source: libpq
Version: 9.6.1
Description: The official database access API of postgresql
Build-Depends: ssl
```
- Each interface gets an own empty port with a feature for each implementation providing it and a default feature set. E.g.:
```
# ports/ssl/CONTROL
Source: ssl
Version: 1
Description: Metapackage for the OpenSSL interface
Default-Features: openssl

Feature: openssl
Description: OpenSSL implementation for the SSL metapackage
Build-Depends: openssl

Feature: libressl
Description: LibreSSL implementation for the SSL metapackage
Build-Depends: libressl
```
- Whenever a port is installed that depends on an interface (e.g. `libpq`) and the interface is not yet installed, the default feature dependency will install the default implementation (e.g. `vcpkg install ssl` will install `ssl[openssl]` and hence `openssl`).
- When a port is installed that provides an interface (e.g. `libressl`) and the interface is not yet installed, it will be installed automatically, with itself as feature, and the default feature deactivated (e.g. `vcpkg install libressl` will install `ssl[core, libressl]`).


## 4. Proposed User experience

### i. A user who has not installed any packages yet wants to install `libpq` and does not care about which SSL implementation is being used

```
>>> vcpkg install libpq
  installing openssl...
  installing ssl[openssl]...
  installing libpq...
>>> vcpkg list
  openssl
  ssl[openssl]
  libpq
```

### ii. A user who has not installed any packages yet wants to install `libpq` and wants to use `libressl` as SSL implementation

```
>>> vcpkg install libressl libpq
  installing libressl...
  installing ssl[libressl]...
  installing libpq...
>>> vcpkg list
  libressl
  ssl[libressl]
  libpq
```

### iii. A user who has installed `openssl` wants to install `libpq` and wants to use `libressl` as SSL implementation

Since openssl and libressl are conflicting (provide the same header files), they cannot be installed at the same time. The user has to remove openssl first:

```
>>> vcpkg list
  openssl
  ssl[openssl]
  libpq
>>> vcpkg install libressl libpq
  installing libressl...
  FAILED: conflicting header between openssl and libressl. Uninstall openssl first.
>>> vcpkg remove openssl
  removing libpq...
  removing ssl[openssl]...
  removing openssl...
>>> vcpkg list
>>> vcpkg install libressl libpq
  installing libressl...
  installing ssl[libressl]...
  installing libpq...
>>> vcpkg list
  libressl
  ssl[libressl]
  libpq
```

## 5. Technical model

- The interfaces assume that the features defined in it are mutually exclusive due to header conflicts. If that would not be the case it would be possible to install two implementations of the same interface at the same time. In general this assumption should hold true, since two implementations have to install the same header files to be consumed by a third library via one predefined interface. Maybe conflicts have to be detected on a symbol level, if a libraries comes without any headers (e.g. BLAS libraries without the cblas interface usually do not have any headers).
- The interface files have to provide a feature for each port that provides it. This may be not perfect, since we would have to define the interface<->implementation relationship at redundantly at two different locations, but this approach reduces the magic that is necessary to implement this feature. Please keep in mind that it is not easily possible for a new port `X` that provides an interface `I` to forget to add itself to the interface port. If that would be case, when installing `X` vcpkg would automatically try to install `I[X]` which immediately fail if `I` does not have such a feature. On the other hand, having the possible implementations being written down in the interface makes it easy for a user to figure out which ports he can choose to meet an interface dependency via the `search` command even if the ports do not have the interface in their name:
```
>>> vcpkg search blas
  blas                 v1.0             Metapackage for the BLAS interface
  blas[openblas]                        OpenBLAS implementation for the BLAS metapackage
  blas[mkl]                             MKL implementation for the BLAS metapackage
  openblas             v0.2.19-1        OpenBLAS is an optimized BLAS library based on Go...
```