# Asset Caching

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/assetcaching.md).**

**Experimental feature: this may change or be removed at any time**

Vcpkg can utilize mirrors to cache downloaded assets, ensuring continued operation even if the original source changes
or disappears.

In-tool help is available via `vcpkg help assetcaching`.

## Configuration

Asset caching can be configured by setting the environment variable `X_VCPKG_ASSET_SOURCES` to a semicolon-delimited
list of source strings. Characters can be escaped using backtick (\`).

### Valid source strings

The `<rw>` optional parameter for certain strings controls how they will be accessed. It can be specified as `read`,
`write`, or `readwrite` and defaults to `read`.

#### `clear`

Syntax: `clear`

Removes all previous sources

#### `x-azurl`

Syntax: `x-azurl,<url>[,<sas>[,<rw>]]`

Adds an Azure Blob Storage source, optionally using Shared Access Signature validation. URL should include the container
path and be terminated with a trailing `/`. SAS, if defined, should be prefixed with a `?`. Non-Azure servers will also
work if they respond to GET and PUT requests of the form: `<url><sha512><sas>`.

See also the [binary caching documentation for Azure Blob Storage](binarycaching.md#azure-blob-storage-experimental) for
more information on how to set up an `x-azurl` source.

#### `x-block-origin`

Syntax: `x-block-origin`

Disables use of the original URLs in case the mirror does not have the file available.
