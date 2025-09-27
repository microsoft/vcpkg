Owners DB helpers
=================

Summary
-------
This directory contains two small Node.js CLI helpers used by the Azure Pipelines owners-db step to build two plain-text database files used by downstream tooling:

- `file_script.ts` — builds databases from a local `info` directory (used in CI runs where vcpkg is installed locally).
- `file_script_from_cache.ts` — builds databases by downloading package ZIPs from a binary cache (used in PR runs that can consult prebuilt artifacts).

Both scripts produce the same output file formats described below:

- `VCPKGDatabase.txt` — a newline-separated list of entries of the form `port:triplet:/path/inside/package`.
- `VCPKGHeadersDatabase.txt` — a newline-separated list of entries of the form `port:triplet:relative/header/path`

These files are emitted to `--out-dir` (default `scripts/list_files`).

Usage
-----

file_script.ts (local info-dir mode)

```text
file_script.ts --info-dir <path-to-info-dir> [--out-dir <path>]
```

Behavior and input format:

- `--info-dir <path>` should point at a directory containing vcpkg-generated `.list` files (the same layout created by `vcpkg` under `installed/<triplet>/vcpkg/info/`).
- Each file in that directory is expected to follow the filename convention used by vcpkg info files. The script parses the filename by splitting on underscores and constructs a package identifier using the first and third components:

	<package>_<...>_<triplet>.list  --> package id = `<package>:<triplet>`

- Each `.list` file is plain text with one relative file path per line. Lines that are empty, or which end in `/` are ignored. If a line contains any prefix before a `/`, the script strips the prefix and uses only the path starting at the first `/`.

Examples of lines processed from `.list` files:

- `share/zlib/include/zlib.h` -> entry `zlib:x64-windows:/share/zlib/include/zlib.h`
- `someprefix/share/zlib/include/zlib.h` -> same as above (prefix before first `/` is dropped)

file_script_from_cache.ts (PR cache mode)

```text
file_script_from_cache.ts --pr-hashes <pr-hashes.json> --blob-base-url <blob-base-url> [--target-branch <branch>] [--out-dir <path>]
```

Required inputs:

- `--pr-hashes <pr-hashes.json>` is a JSON file produced by the vcpkg tooling that lists changed ports and their ABIs. The script expects a top-level JSON array of objects where each object contains at least the following fields:

	{
		"name": "<port-name>",
		"triplet": "<triplet>",
		"state": "<state>",
		"abi": "<sha>"
	}

	Important: in this script the `abi` field is expected to be the 64-hex SHA string used to name the ZIP blob in the binary cache (the script validates `abi` against `/^[a-f0-9]{64}$/`).

- `--blob-base-url <blob-base-url>` should be a URL that points to a binary cache container and include any required SAS token (for example: `https://<account>.blob.core.windows.net/cache?<sas>`). The script will insert `/<sha>.zip` into that base URL to download the package ZIP for each port/abi pair and then enumerate files inside each ZIP.

Output file formats
-------------------

Both scripts write two files into the chosen `--out-dir` (default `scripts/list_files`):

- `VCPKGDatabase.txt`
	- Each line has the form: `<port>:<triplet>:<filepath>`
	- `<filepath>` begins with a leading `/` when sourced from `.list` files or ZIP entries; it is the path inside the package (for example `/share/zlib/include/zlib.h`).

- `VCPKGHeadersDatabase.txt`
	- Each line has the form: `<port>:<triplet>:<relative/header/path>`
	- Only files whose path starts with `/include/` are recorded here and the `/include/` prefix is removed from the path. For example, an entry for `/include/zlib.h` will produce `zlib:x64-windows:zlib.h`.

Exit codes and errors
---------------------

- Both scripts print an error and exit non-zero on fatal problems (invalid arguments, invalid `pr-hashes.json`, or failed git diff in the cache variant).
- `file_script_from_cache.ts` will attempt to download each expected ZIP; failures to download or process a single package are reported as warnings and the script continues — missing entries will simply be absent from the output.

Examples
--------

Local info-dir:

```sh
npx ts-node ./file_script.ts --info-dir /mnt/vcpkg-ci/installed/vcpkg/info --out-dir ./scripts/list_files
```

PR cache mode (pipeline example using `BCACHE_SAS_TOKEN` set as a secret variable):

```sh
# pipeline constructs the URL from the secret token and passes it to the script
blob="https://vcpkgbinarycachewus.blob.core.windows.net/cache?${BCACHE_SAS_TOKEN}"
npx --yes ts-node ./file_script_from_cache.ts --pr-hashes /path/to/pr-hashes.json --blob-base-url "$blob" --target-branch origin/master --out-dir ./scripts/list_files
```
