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
work if they respond to GET and PUT requests of the form: `<url><sha512><sas>`. As an example, if you set
`X_VCPKG_ASSET_SOURCES` to `x-azurl,https://mydomain.com/vcpkg/,token=abc123,readwrite` your server should respond to
`GET` and `PUT` requests of the form `https://mydomain.com/vcpkg/<sha512>?token=abc123`.

You can also use the filesystem (e.g. a network drive) via `file://` as asset cache. For example you then set
`X_VCPKG_ASSET_SOURCES` to `x-azurl,file:///Z:/vcpkg/assetcache/,,readwrite` when you have a network folder mounted at
`Z:/`.

The workflow of this asset source is:

1. Attemp to read from the mirror
2. (If step 1 failed) Read from the original url
3. (If step 2 succeeded) Write back to the mirror

You can enable/disable steps 1 and 3 via the [`<rw>`](#valid-source-strings) specifier and you can disable step 2 via
`x-block-origin` below.

See also the [binary caching documentation for Azure Blob Storage](binarycaching.md#azure-blob-storage-experimental) for
more information on how to set up an `x-azurl` source.

#### `x-block-origin`

Syntax: `x-block-origin`

Disables use of the original URLs in case the mirror does not have the file available.
