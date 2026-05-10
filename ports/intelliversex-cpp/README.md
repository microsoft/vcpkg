# intelliversex-cpp vcpkg port

This port packages the IntelliVerseX C/C++ SDK for vcpkg.

## Dependency

- **nakama-sdk**: Not in the main vcpkg registry. Use one of:
  - [Heroic Labs nakama-vcpkg-registry](https://github.com/heroiclabs/nakama-vcpkg-registry) (add as a custom registry), or
  - Overlay port for nakama-sdk when submitting to vcpkg.

### Using Heroic's registry

Create or edit `vcpkg-configuration.json` in your project root (or vcpkg root when testing from vcpkg) with:

```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/heroiclabs/nakama-vcpkg-registry",
      "reference": "master",
      "baseline": "60dd370a544846b8b88ba231c8635537d3d1016b",
      "packages": ["nakama-sdk", "wslay", "nakama-test", "ms-quic"]
    }
  ]
}
```

Then run `vcpkg install intelliversex-cpp`. Update the `baseline` to a newer commit from [nakama-vcpkg-registry](https://github.com/heroiclabs/nakama-vcpkg-registry) if desired.

## Local / overlay use

1. Clone vcpkg (or your fork).
2. Copy this folder into `vcpkg/ports/intelliversex-cpp/`.
3. Add Heroic's registry to `vcpkg-configuration.json` so `nakama-sdk` is available (see above), or add nakama-sdk as an overlay port.
4. Install:  
   `vcpkg install intelliversex-cpp`

## Before submitting a PR to vcpkg

1. Ensure a release tag (e.g. `v5.1.0`) exists in the IntelliVerseX repo.
2. From vcpkg repo root, run:  
   `vcpkg x-add-version intelliversex-cpp`  
   to update the versions database and SHA512.
3. Commit the new/updated files under `ports/intelliversex-cpp/` and `versions/`.
4. Open a PR to [microsoft/vcpkg](https://github.com/microsoft/vcpkg). In the description, note that `nakama-sdk` is required and suggest using the [Heroic Labs vcpkg registry](https://github.com/heroiclabs/nakama-vcpkg-registry) or an overlay until/unless nakama-sdk is in the main registry.
