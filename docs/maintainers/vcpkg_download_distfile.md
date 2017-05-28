# vcpkg_download_distfile

Download and cache a file needed for this port.

## Usage
```cmake
vcpkg_download_distfile(
    <OUT_VARIABLE>
    URLS <http://mainUrl> <http://mirror1>...
    FILENAME <output.zip>
    SHA512 <5981de...>
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

## Notes
The command [`vcpkg_from_github`](vcpkg_from_github.md) should be used instead of this for downloading the main archive for GitHub projects.

## Examples

* [boost](https://github.com/Microsoft/vcpkg/blob/master/ports/boost/portfile.cmake)
* [fontconfig](https://github.com/Microsoft/vcpkg/blob/master/ports/fontconfig/portfile.cmake)
* [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)

## Source
[scripts/cmake/vcpkg_download_distfile.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_download_distfile.cmake)
