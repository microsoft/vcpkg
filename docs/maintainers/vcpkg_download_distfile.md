# vcpkg_download_distfile

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_download_distfile.md).

Download and cache a file needed for this port.

This helper should always be used instead of CMake's built-in `file(DOWNLOAD)` command.

## Usage
```cmake
vcpkg_download_distfile(
    <OUT_VARIABLE>
    URLS <http://mainUrl> <http://mirror1>...
    FILENAME <output.zip>
    SHA512 <5981de...>
    [ALWAYS_REDOWNLOAD]
)
```
## Parameters
### OUT_VARIABLE
This variable will be set to the full path to the downloaded file. This can then immediately be passed in to [`vcpkg_extract_source_archive`](vcpkg_extract_source_archive.md) for sources.

### URLS
A list of URLs to be consulted. They will be tried in order until one of the downloaded files successfully matches the SHA512 given.

### FILENAME
The local name for the file. Files are shared between ports, so the file may need to be renamed to make it clearly attributed to this port and avoid conflicts.

### SHA512
The expected hash for the file.

If this doesn't match the downloaded version, the build will be terminated with a message describing the mismatch.

### QUIET
Suppress output on cache hit

### SKIP_SHA512
Skip SHA512 hash check for file.

This switch is only valid when building with the `--head` command line flag.

### ALWAYS_REDOWNLOAD
Avoid caching; this is a REST call or otherwise unstable.

Requires `SKIP_SHA512`.

### HEADERS
A list of headers to append to the download request. This can be used for authentication during a download.

Headers should be specified as "<header-name>: <header-value>".

## Notes
The helper [`vcpkg_from_github`](vcpkg_from_github.md) should be used for downloading from GitHub projects.

## Examples

* [apr](https://github.com/Microsoft/vcpkg/blob/master/ports/apr/portfile.cmake)
* [fontconfig](https://github.com/Microsoft/vcpkg/blob/master/ports/fontconfig/portfile.cmake)
* [freetype](https://github.com/Microsoft/vcpkg/blob/master/ports/freetype/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_download\_distfile.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_download_distfile.cmake)
