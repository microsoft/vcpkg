# Community Triplets

This folder contains triplet files that are not tested by continuous integration.

The triplets contained here are for configurations commonly requested by the community, but for which we lack the resources to properly test.

Port updates may break compatibility with community triplets, such regressions won't get caught by our testing pipelines. Because of this, community involvement is paramount!

We will gladly accept and review contributions that aim to solve issues with these triplets.

## Usage

Community Triplets are not enabled by default, to use them you need to add the `--overlay-triplets` option to your commands; commands that accept the `--overlay-triplets` option are:
* `install`
* `remove`
* `upgrade`
* `ci`
* `export`
* `depend-info`

## Examples

### Install a package

```cmake
D:\vcpkg> ./vcpkg install sqlite3:x86-windows-static --overlay-triplets=triplets/community
```

### Update packages 

When updating packages, the `--overlay-triplets` option is only required on the `vcpkg upgrade` command.

```cmake
D:\vcpkg> ./vcpkg update
D:\vcpkg> ./vcpkg upgrade --no-dry-run --overlay-triplets=triplets/community
```
